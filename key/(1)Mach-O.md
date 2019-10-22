> 苹果的可执行文件和动态库的格式为Mach-O

#### 1、Mach-O文件格式

新建工程ZzMachO，找到编译后的IPA包，显示包内容，可以找到Mach-O文件。利用工具MachOView（[点击下载](https://sourceforge.net/projects/machoview/)）可以查看文件内容，如下：

![Mach-O](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/Mach-O.jpeg)

可知 Mach-O 文件包含了三部分内容：

- Header（头部），指明了 cpu 架构、大小端序、文件类型、Load Commands 个数等一些基本信息
- Load Commands（加载命令)，正如上图所示，描述了怎样加载每个 Segment 的信息。在 Mach-O 文件中可以有多个 Segment，每个 Segment 可能包含一个或多个 Section。
- Data（数据区），Segment 的具体数据，包含了代码和数据等。



Mach-O 文件的头部定义如下：

```C
/*
 * The 64-bit mach header appears at the very beginning of object files for
 * 64-bit architectures.
 */
struct mach_header_64 {
	uint32_t	magic;		/* mach magic number identifier */
	cpu_type_t	cputype;	/* cpu specifier */
	cpu_subtype_t	cpusubtype;	/* machine specifier */
	uint32_t	filetype;	/* type of file */
	uint32_t	ncmds;		/* number of load commands */
	uint32_t	sizeofcmds;	/* the size of all the load commands */
	uint32_t	flags;		/* flags */
	uint32_t	reserved;	/* reserved */
};

/* Constant for the magic field of the mach_header_64 (64-bit architectures) */
#define MH_MAGIC_64 0xfeedfacf /* the 64-bit mach magic number */
#define MH_CIGAM_64 0xcffaedfe /* NXSwapInt(MH_MAGIC_64) */
```

magic 标志符 0xfeedface 是 32 位， 0xfeedfacf 是 64 位。

cputype 和 cpusubtype 确定 cpu 类型、平台

filetype 文件类型，可执行文件、符号文件（DSYM）、内核扩展等

文件类型包括以下：

- OBJECT：.o文件或者.a文件
- EXECUTE：IPA拆包后的文件
- DYLIB：.dylib或.framework文件
- DYLINKER：动态链接器
- DSYM：保存有符号信息用于分析闪退信息的文件

ncmds 加载 Load Commands 的数量

flags dyld 加载的标志

- `MH_NOUNDEFS` 目标文件没有未定义的符号，
- `MH_DYLDLINK` 目标文件是动态链接输入文件，不能被再次静态链接,
- `MH_SPLIT_SEGS` 只读 segments 和 可读写 segments 分离，
- `MH_NO_HEAP_EXECUTION` 堆内存不可执行…

**Headers 能帮助校验 Mach-O 合法性和定位文件的运行环境。**



Load Commands 的定义:

```c
struct load_command {
	uint32_t cmd;		/* type of load command */
	uint32_t cmdsize;	/* total size of command in bytes */
};
```

cmd 字段，如上图它指出了 command 类型

- `LC_SEGMENT、LC_SEGMENT_64` 将 segment 映射到进程的内存空间，
- `LC_UUID` 二进制文件 id，与符号表 uuid 对应，可用作符号表匹配，
- `LC_LOAD_DYLINKER` 启动动态加载器，
- `LC_SYMTAB` 描述在 `__LINKEDIT` 段的哪找字符串表、符号表，
- `LC_CODE_SIGNATURE` 代码签名等

cmdsize 字段，主要用以计算出到下一个 command 的偏移量。



Segment & Section

segment 的定义：

```c
/*
 * The 64-bit segment load command indicates that a part of this file is to be
 * mapped into a 64-bit task's address space.  If the 64-bit segment has
 * sections then section_64 structures directly follow the 64-bit segment
 * command and their size is reflected in cmdsize.
 */
struct segment_command_64 { /* for 64-bit architectures */
	uint32_t	cmd;		/* LC_SEGMENT_64 */
	uint32_t	cmdsize;	/* includes sizeof section_64 structs */
	char		segname[16];	/* segment name */
	uint64_t	vmaddr;		/* memory address of this segment */
	uint64_t	vmsize;		/* memory size of this segment */
	uint64_t	fileoff;	/* file offset of this segment */
	uint64_t	filesize;	/* amount to map from the file */
	vm_prot_t	maxprot;	/* maximum VM protection */
	vm_prot_t	initprot;	/* initial VM protection */
	uint32_t	nsects;		/* number of sections in segment */
	uint32_t	flags;		/* flags */
};
```

cmd 就是上面分析的 command 类型

segname 在源码中定义的宏

- `#define SEG_PAGEZERO "__PAGEZERO" // 可执行文件捕获空指针的段`
- `#define SEG_TEXT "__TEXT" // 代码段，只读数据段`
- `#define SEG_DATA "__DATA" // 数据段`
- `#define SEG_LINKEDIT "__LINKEDIT" // 包含动态链接器所需的符号、字符串表等数据`

vmaddr 段的虚内存地址（未偏移），由于 ALSR，程序会在进程加上一段偏移量（slide），真实的地址 = vm address + slide

vmsize 段的虚内存大小

fileoff 段在文件的偏移

filesize 段在文件的大小

nsects 段中有多少个 section



section 的定义：

```c
struct section_64 { /* for 64-bit architectures */
	char		sectname[16];	/* name of this section */
	char		segname[16];	/* segment this section goes in */
	uint64_t	addr;		/* memory address of this section */
	uint64_t	size;		/* size in bytes of this section */
	uint32_t	offset;		/* file offset of this section */
	uint32_t	align;		/* section alignment (power of 2) */
	uint32_t	reloff;		/* file offset of relocation entries */
	uint32_t	nreloc;		/* number of relocation entries */
	uint32_t	flags;		/* flags (section type and attributes)*/
	uint32_t	reserved1;	/* reserved (for offset or index) */
	uint32_t	reserved2;	/* reserved (for count or sizeof) */
	uint32_t	reserved3;	/* reserved */
};
```

`__Text` 和 `__Data` 都有自己的 section

- segname 就是所在段的名称

- sectname section名称，部分列举：

  - `Text.__text` 主程序代码

  - `Text.__cstring` c 字符串

  - `Text.__stubs` 桩代码

  - `Text.__stub_helper`

  - `Data.__data` 初始化可变的数据

  - `Data.__objc_imageinfo`镜像信息 ，在运行时初始化`objc_init`调用`load_images`加载新的镜像到 infolist 中

    ![img](https://user-gold-cdn.xitu.io/2018/3/23/1625106b7f0b1a14?imageView2/0/w/1280/h/960/ignore-error/1)

  - `Data.__la_symbol_ptr`

  - `Data.__nl_symbol_ptr`

  - `Data.__objc_classlist` 类列表

  - `Data.__objc_classrefs` 引用的类

#### 2、编译

> 苹果使用的编译器是LLVM（Low Level Virtual Machine）,取代了GCC。

![LLVM架构](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/LLVM-architecture.jpg)



编译器对每个文件进行编译，生成Mach-O;

编译主要过程：

- LLVM预处理代码，比如嵌入宏到对应的位置
- LLVM对代码进行词法分析和语法分析，生成AST（抽象语法树），结构上比代码更精简，遍历起来更快，利用AST进行静态检查速度更快，能更快生成IR
- AST生成IR，通过IR可以生成适合不同平台的机器码。iOS系统IR生成的可执行文件就是Mach-O.



链接器将多个Mach-O文件合并成一个。

链接器的作用，就是完成变量、函数符号和地址的绑定，符号可理解为变量名和函数名。

链接器的主要操作：

- 去项目文件里查找目标代码文件里没有定义的变量
- 扫描项目中的不同文件，将所有符号定义和引用地址收集起来，并放到全局符号表中
- 计算合并后长度及位置，生成同类型的段进行合并，建立绑定
- 对项目中不同文件里的变量进行地址重定位

链接器在整理函数的调用关系时，会以 main 函数为源头，跟随每个引用，并将其标记为 live。跟随完成后，那些未被标记 live 的函数，就是无用函数。然后，链接器可以通过打开 Dead code stripping 开关，来开启自动去除无用代码的功能。并且，这个开关是默认开启的。



动态库链接

动态库是运行时链接的库，使用dyld（动态库链接器）可以实现动态加载。运行时通过 dlopen 和 dlsym 导入动态库时，先根据记录的库路径找到对应的库，再通过记录的名字符号找到绑定的地址。

示例如下：

```c

#import <dlfcn.h>

typedef int (*printf_func_pointer) (const char * __restrict, ...);

void dynamic_call_function(){
    
    //动态库路径
    char *dylib_path = "/usr/lib/libSystem.dylib";
    
    //打开动态库
    void *handle = dlopen(dylib_path, RTLD_GLOBAL | RTLD_NOW);
    if (handle == NULL) {
        //打开动态库出错
        fprintf(stderr, "%s\n", dlerror());
    } else {
        
        //获取 printf 地址
        printf_func_pointer printf_func = dlsym(handle, "printf");
        
        //地址获取成功则调用
        if (printf_func) {
            int num = 100;
            printf_func("Hello exchen.net %d\n", num);
            printf_func("printf function address 0x%lx\n", printf_func);
        }
        
        dlclose(handle); //关闭句柄
    }
}


int main(int argc, char * argv[]) {
    
    dynamic_call_function();

    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```

输出：

>Hello exchen.net 100
>
>printf function address 0x7fff510a4730



**Mach-O应用**

Weex库`WeexPluginLoader`，使用宏可方便注册组件，用法如下：

```
注册module
WX_PlUGIN_EXPORT_MODULE(test,WXTestModule)
注册component
WX_PlUGIN_EXPORT_COMPONENT(test,WXTestCompnonent)
注册handler
WX_PlUGIN_EXPORT_HANDLER(WXImgLoaderDefaultImpl,WXImgLoaderProtocol)
```

注册代码可直接写在组件代码，而无需写在工程业务代码，无需在appDelegate调用register相关的注册代码。

最终的调用实际上是下面的宏：

```
#define WeexPluginDATA __attribute((used, section("__DATA,WeexPlugin")))
```

实际上是将数据保存在WeexPlugin的section中。

我们使用宏实际上是：

```
#define WX_PlUGIN_EXPORT_MODULE_DATA(jsname,classname) \
char const * k##classname##Configuration WeexPluginDATA = WX_PLUGIN_NAME("module",jsname,classname);
```

调用了宏之后，与组件相关的信息被保存到section中，实际上是保存一个字符串，如：

```
module&test&WXTestModule
component&test&WXTestCompnonent
protocol&WXImgLoaderDefaultImpl&WXImgLoaderProtocol
```

那么，我们只需从WeexPluginsection中取出来这些字符串，即可完成自动自动注册。

Demo工程中（ZzMachO，我根据此原理写了相关类ZzWXPluginLoader，宏的定义参照WeexPluginLoader的定义），ZzWXPluginLoader类方法如下：

```objective-c

+ (NSArray<NSString *> *)readConfigFromSectionName:(NSString *)sectionName
{
    NSMutableArray *configs = [NSMutableArray array];
    if (sectionName.length)
    {
        if (machHeader == NULL)
        {
            //获取mach_headers信息
            Dl_info info;
            dladdr((__bridge const void *)(configuration), &info);
            machHeader = (struct mach_header*)info.dli_fbase;
        }
        unsigned long size = 0;
        //取得该section的数据
        uintptr_t *memory = (uintptr_t*)getsectiondata(machHeader, SEG_DATA, [sectionName UTF8String], & size);
        //获取该section每条信息
        NSUInteger counter = size/sizeof(void*);
        NSError *converError = nil;
        for(int idx = 0; idx < counter; ++idx){
            char *string = (char*)memory[idx];
            
            NSString *str = [NSString stringWithUTF8String:string];
            
            if (str || str.length > 0)
            {
                [configs addObject:str];
            }
        }
    }
    return configs;
}
```

根据app的启动机制，只需在该类的+load方法中调用此方法即可。具体实现见Demo。

输出结果：

>**2019-09-22 17:25:17.585408+0800 ZzMachO[23375:811862] register protocol:WXResourceRequestHandler with jsimpl:ZzHandler**
>
>**2019-09-22 17:25:17.588759+0800 ZzMachO[23375:811862] register component:ZzComponent with jsname:componentTest**
>
>**2019-09-22 17:25:17.621288+0800 ZzMachO[23375:811862] register module:ZzModuleTest with jsname:moduleTest**





参考：

1、[探秘 Mach-O 文件](https://juejin.im/post/5ab47ca1518825611a406a39)

2、iOS开发高手课：05|链接器：符号是怎么绑定到地址上的？

3、[LLVM](https://blog.csdn.net/xhhjin/article/details/81164076)

5、[Use Mach-O section as plist](https://www.jianshu.com/p/710f71f0247f)