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



**`dyld`是苹果的动态链接器**

系统先读取App的可执行文件（Mach-O文件），从里面获得dyld的路径，然后加载dyld，dyld去初始化运行环境，开启缓存策略，加载程序相关依赖库(其中也包含我们的可执行文件)，并对这些库进行链接，最后调用每个依赖库的初始化方法，在这一步，runtime被初始化。当所有的依赖库初始化后，轮到最后一位(程序可执行文件)进行初始化，在这时runtime会对项目中所有类进行类结构初始化，然后调用所有的load方法。最后dyld返回main函数地址，main函数被调用，我们便来到了熟悉的程序入口。



**dyld共享库缓存**

当你构建一个真正的程序时，将会链接各种各样的库。它们又会依赖其他一些framework和动态库。需要加载的动态库会非常多。而对于相互依赖的符号就更多了。可能将会有上千个符号需要解析处理，这将花费很长的时间
**为了缩短这个处理过程所花费时间，OS X 和 iOS 上的动态链接器使用了共享缓存，OS X的共享缓存位于/private/var/db/dyld/，iOS的则在/System/Library/Caches/com.apple.dyld/。**

**对于每一种架构，操作系统都有一个单独的文件，文件中包含了绝大多数的动态库，这些库都已经链接为一个文件，并且已经处理好了它们之间的符号关系。当加载一个 Mach-O 文件 (一个可执行文件或者一个库) 时，动态链接器首先会检查共享缓存看看是否存在其中，如果存在，那么就直接从共享缓存中拿出来使用。每一个进程都把这个共享缓存映射到了自己的地址空间中。这个方法大大优化了 OS X 和 iOS 上程序的启动时间**



**dylib加载过程：**

- load dylibs image

  ```
  1、分析所依赖的动态库
  2、找到动态库的mach-O文件
  3、打开文件
  4、验证文件
  5、在系统核心注册文件
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



- 这里主要解决几个疑惑：

  > 1、ASLR（地址空间布局随机化）
  >
  > ​		1.传统方式下，进程每次启动采用的都是固定可预见的方式，这意味着一个给定的程序在给定的架构上的进程初始虚拟内存都是基本一致的，而且在进程正常运行的生命周期中，内存中的地址分布具有非常强的可预测性，这给了黑客很大的施展空间（代码注入，重写内存）；
  >
  > ​		2.如果采用ASLR，进程每次启动，地址空间都会被简单地随机化，但是只是偏移，不是搅乱。大体布局——程序文本、数据和库是一样的，但是具体的地址都不同了，可以阻挡黑客对地址的猜测 。
  >
  > 2、rebase：针对mach-o在加载到内存中不是固定的首地址 这一现象做数据修正的过程；
  >
  > 3、binding就是将这个二进制调用的外部符号进行绑定的过程。比如我们objc代码中需要使用到NSObject, 即符号`_OBJC_CLASS_$_NSObject`，但是这个符号又不在我们的二进制中，在系统库 `Foundation.framework`中，因此就需要binding这个操作将对应关系绑定到一起；
  >
  > 4、`lazyBinding`就是在加载动态库的时候不会立即binding, 当第一次调用这个方法的时候再实施binding。 做到的方法也很简单： 通过`dyld_stub_binder`这个符号来做。`lazyBinding`的方法第一次会调用到`dyld_stub_binder`, 然后`dyld_stub_binder`负责找到真实的方法，并且将地址bind到桩上，下一次就不用再bind了。



- Objc setup

  `Objc setup`主要是在`objc_init`完成的，`objc_init`是在`libsystem`中的一个`initialize`方法`libsystem_initializer`中初始化了`libdispatch`，然后`libdispatch_init`调用了`_os_object_init`， 最终调用了`_objc_init`。

  ![objc setup](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/objc setup.png)

  - dyld在binding结束后，会发出dyld_image_state_bound通知，然后与之绑定的回调函数map_2_images会被调用，主要做以下几件事来完成Objc setup:
    - 读取二进制文件的DATA段内容，找到与objc相关的信息
    - 注册Objc类
    - 确保selector的唯一性
    - 读取protocol以及category的信息
  - load_images函数作用就是调用Objc的load方法，它监听dyld_image_state_dependents_initialize通知
  - unmap_image可以理解为map_2_images的逆向操作

- Initializers

  动态调整，开始在堆和栈中写入内容，主要工作有：

  - Objc的+load()函数
  - C++的构造函数属性函数attribute((constructor))
  - 非基本类型的C++静态全局变量的创建（通常是类或结构体）

  Objc的load函数和C++的静态构造器采用由底向上的方式执行，保证每个执行的方法，都可以找到所依赖的动态库

  - dyld开始将程序二进制文件初始化

  - 交由ImageLoader读取Image，其中包含类、方法等各种符号

  - 由于runtime向dyld绑定了回调，当Image加载到内存后，dyld会通知runtime进行处理

  - runtime接手后调用mapImages做解析和处理，接下来loadimages中调用callloadmethods方法，遍历所有加载进来的Class，按继承层级依次调用Class的+load方法和其Category的+load方法

  - 全部加载完成后，dyld调用image中所有的constructor方法

    

    所有初始化工作结束后，dyld开始调用main()函数



**attribute黑魔法**

示例1：constructor / destructor

```objective-c
__attribute__((constructor))void beforeMain(){
    NSLog(@"beforeMain");
}

__attribute__((desctructor))void afterMain(){
    NSLog(@"afterMain");
}

int main(int argc, char * argv[]) {
    
    NSLog(@"Main");
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```

输出：

> beforeMain —> Main—>afterMain



###### pre-main阶段优化：

- 删除无用代码（未被调用的静态变量、类、方法）
- 抽象重复代码
- 优化+load方法，尽量延迟到+initialize中
- 优化或减少必要的framework



##### 4、main阶段(main到appDidFinishLaunchingWithOptions:)

项目中此阶段主要是做了以下工作：

- 配置App运行环境

- 集成第三方SDK
- 显示app的第一屏

![main](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/main.jpeg)

优化点：

- 不使用xib或storyboard，直接使用代码
- 对于`viewDidLoad`以及`viewWillAppear`方法中尽量去尝试少做，晚做，不做，或者采用异步的方式去做；
- 当首页逻辑比较复杂的时候：通过`instruments`的`Time Profiler`分析耗时瓶颈。



参考：

1、[iOS中触摸事件传递和响应原理](https://www.jianshu.com/p/4aeaf3aa0c7e)

2、iOS开发高手课：33|iOS系统内部XNU：App 如何加载？

3、[iOS启动优化](http://lingyuncxb.com/2018/01/30/iOS启动优化/)

4、[Clang Attibutes](http://blog.sunnyxx.com/2016/05/14/clang-attributes/)
