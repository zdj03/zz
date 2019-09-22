####App启动过程（冷启动，热启动暂不讨论）

##### 1、点击icon，系统响应阶段

- 手指触碰屏幕，系统将事件交给IOKit处理

- IOKit将触摸事件封装成IOHIDEvent对象，并通过mach port传递给SpringBoard进程

  >mach port是进程端口，各进程间通过它来通信。SpringBoard是一个系统进程，可以理解为桌面系统，可以统一管理和分发系统接收到的触摸事件。

- SpringBoard触发系统进程的主线程的runloop的source回调

  发送触摸事件的时候，如果App正在后台（即看到的是桌面），则触发SpringBoard主线程的runloop的source0回调，将桌面系统交由系统进程消耗；如果App在前台（即正在操作App内部），则将触摸事件通过IPC传递给前台App进程，后面便是App内部对触摸事件的响应。

##### 2、XNU加载App

XNU内部由Mach、BSD、驱动API IOKit组成，这些都依赖于libkern、libsa、Platform Expert。如下图：

![XNU架构](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/XNU.png)



> 加载App即加载App的Mach-O文件。

加载Mach-O文件，内核会fork进程，并对进程进行一些设置，如为进程分配虚拟内存、为进程创建主线程、代码签名等。用户态会对Mach-O文件做库加载和符号解析。流程概括为：

- fork新进程
- 为Mach-O分配内存
- 解析Mach-O
- 读取Mach-O头信息
- 遍历load command信息，将Mach-O映射到内存
- 启动dyld

##### 3、pre-main阶段

pre-main阶段：主要是系统dylib（动态链接库）和自身App可执行文件的加载

![pre-main](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/pre-main.jpeg)

> 在Xcode设置环境变量DYLD_PRINT_STATISTICS值为1，可以在控制台打印出pre-main各阶段的耗时

如下：

![DYLD_PRINT_STATISTICS](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/DYLD_PRINT_STATISTICS.jpeg)

打印结果如下：

![total pre-main time](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/total pre-main time.jpeg)

可以看到加载的相关动态链接库和加载时间。



使用命令：`OTool -L ZzMachO `可以查看相关动态库的信息：

![dylib](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/dylib.jpeg)





dylid加载过程：

- load dylibs image

  ```
  1、分析所依赖的动态库
  2、找到动态库的mach-O文件
  3、打开文件
  4、验证文件
  5、在系统核心注册文件前面
  6、对动态库的每个segment调用mmap()
  ```

- Rebase/Bind image

  由于ASLR(address space layout randomization)，可执行文件和动态链接库在虚拟内存中的加载地址每次不固定（只是一定偏移量），所以需要这2步来修复镜像中的资源指针，来指向正确的地址。 rebase修复的是指向当前镜像内部的资源指针； 而bind指向的是镜像外部的资源指针。

  >在iOS4.3前会把dylib加载到指定地址，所有指针和数据对于代码来说都是固定的，dyld 就无需做rebase/binding了。
  >
  >iOS4.3后引入了 ASLR ，dylib会被加载到随机地址，这个随机的地址跟代码和数据指向的旧地址会有偏差，dyld 需要修正这个偏差，做法就是将 dylib 内部的指针地址都加上这个偏移量，偏移量的计算方法如下：
  >
  >Slide = actual_address - preferred_address
  >
  >然后就是重复不断地对 __DATA 段中需要 rebase 的指针加上这个偏移量





- Objc setup

  `Objc setup`主要是在`objc_init`完成的，`objc_init`是在`libsystem`中的一个`initialize`方法`libsystem_initializer`中初始化了`libdispatch`，然后`libdispatch_init`调用了`_os_object_int`， 最终调用了`_objc_init`。

  ![objc setup](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/objc setup.png)

  - dyld在binding结束后，会发出dyld_image_state_bound通知，然后与之绑定的回调函数map_2_images会被调用，主要做以下几件事来完成Objc setup:
    - 读取二进制文件的DATA段内容，找到与objc相关的信息
    - 注册Objc类
    - 确保selector的唯一性
    - 读取protocol以及category的信息
  - load_images函数作用就是调用Objcd的load方法，它监听dyld_image_state_dependents_initialize通知
  - unmap_image可以理解为map_2_images的逆向操作

- Initializers

  动态调整，开始在堆和栈中写入内容，主要工作有：

  - Objc的+load()函数
  - C++的构造函数属性函数attribute((constructor))
  - 非基本类型的C++静态全局变量的创建（通常是类或结构体）

  Objc的load函数和C++的静态构造器采用由底向上的方式执行，保证每个执行的方法，都可以找到所依赖的动态库

  - dyld开始将程序二进制文件初始化

  - 交由ImageLoader读取Image，其中包含类、方法等各种符合

  - 由于runtime向dyld绑定了回调，当Image加载到内存后，dyld会通知runtime进行处理

  - runtime接手后调用mapImages做解析和处理，接下来loadimages中调用callloadmethods方法，遍历所有加载进来的Class，按继承层级依次调用Class的+load方法和其Category的+load方法

  - 全部加载完成后，dyld调用image中所有的constructor方法

    

    所有初始化工作结束后，dyld开始调用main()函数

###### pre-main阶段优化：

- 删除无用代码（未被调用的静态变量、类、方法）
- 抽象重复代码
- 优化+load方法，尽量延迟到+initialize中
- 优化或减少必要的framework



##### 4、main阶段(main到appDidFinishLaunchingWithOptions:)

![main](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/main.jpeg)

参考：

1、[iOS中触摸事件传递和响应原理](https://www.jianshu.com/p/4aeaf3aa0c7e)

2、iOS开发高手课：33|iOS系统内部XNU：App 如何加载？

3、[iOS启动优化](http://lingyuncxb.com/2018/01/30/iOS启动优化/)