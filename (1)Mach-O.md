> iOS和Mac OSX的可执行文件和动态库都是Mach-O格式

####1、Mach-O文件究竟是什么样的文件？（新建空工程ZzMachO）

编译后，使用工具MachOView（[需先安装](https://sourceforge.net/projects/machoview/)）打开ZzMachO文件（Products->ZzMachO.app->Show In Finder->显示包内容，即可找到）。

#####Mach-O文件包含三部分内容：(Mach-O各部分的定义在库文件#include <mach-o/loader.h>中)

- Header（头部），指明了 cpu 架构、大小端序、文件类型、Load Commands 个数等一些基本信息

  头部定义：

  ```c
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
  ```

  - magic 标志符 0xfeedface 是 32 位， 0xfeedfacf 是 64 位。

  - cputype 和 cpusubtype 确定 cpu 类型、平台

  - filetype 文件类型，可执行文件、符号文件（DSYM）、内核扩展等

  - ncmds 加载 Load Commands 的数量

  - flags dyld 加载的标志
    - `MH_NOUNDEFS` 目标文件没有未定义的符号，
    - `MH_DYLDLINK` 目标文件是动态链接输入文件，不能被再次静态链接,
    - `MH_SPLIT_SEGS` 只读 segments 和 可读写 segments 分离，
    - `MH_NO_HEAP_EXECUTION` 堆内存不可执行…

  **Headers 能帮助校验 Mach-O 合法性和定位文件的运行环境。**

- Load Commands（加载命令)，正如官方的图所示，描述了怎样加载每个 Segment 的信息。在 Mach-O 文件中可以有多个 Segment，每个 Segment 可能包含一个或多个 Section。

  定义：

  ```c
  struct load_command {
  	uint32_t cmd;		/* type of load command */
  	uint32_t cmdsize;	/* total size of command in bytes */
  };
  ```

  - cmd 字段，如上图它指出了 command 类型
    - `LC_SEGMENT、LC_SEGMENT_64` 将 segment 映射到进程的内存空间，
    - `LC_UUID` 二进制文件 id，与符号表 uuid 对应，可用作符号表匹配，
    - `LC_LOAD_DYLINKER` 启动动态加载器，
    - `LC_SYMTAB` 描述在 `__LINKEDIT` 段的哪找字符串表、符号表，
    - `LC_CODE_SIGNATURE` 代码签名等

  - cmdsize 字段，主要用以计算出到下一个 command 的偏移量。

- Data（数据区），Segment 的具体数据，包含了代码和数据等。

  segment定义：

  ```c
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

  - cmd 就是上面分析的 command 类型

  - segname 在源码中定义的宏
    - `#define SEG_PAGEZERO "__PAGEZERO" // 可执行文件捕获空指针的段`
    - `#define SEG_TEXT "__TEXT" // 代码段，只读数据段`
    - `#define SEG_DATA "__DATA" // 数据段`
    - `#define SEG_LINKEDIT "__LINKEDIT" // 包含动态链接器所需的符号、字符串表等数据`

  - vmaddr 段的虚存地址（未偏移），由于 ALSR，程序会在进程加上一段偏移量（slide），真实的地址 = vm address + slide

  - vmsize 段的虚存大小

  - fileoff 段在文件的偏移

  - filesize 段在文件的大小

  - nsects 段中有多少个 section

  section定义：

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

  segname 就是所在段的名称

  sectname section名称，部分列举：

  - `Text.__text` 主程序代码
  - `Text.__cstring` c 字符串
  - `Text.__stubs` 桩代码
  - `Text.__stub_helper`
  - `Data.__data` 初始化可变的数据
  - `Data.__objc_imageinfo` 镜像信息 ，在运行时初始化时 `objc_init`，调用 `load_images` 加载新的镜像到 infolist 中

  - `Data.__la_symbol_ptr`
  - `Data.__nl_symbol_ptr`
  - `Data.__objc_classlist` 类列表
  - `Data.__objc_classrefs` 引用的类

####2、编译

> 苹果使用的编译器是LLVM（Low level Virtual Machine），取代GCC，LLVM 是编译器工具链技术的一个集合。
>
> 动态链接器：dyld
>
> 编译器对每个文件进行编译，生成Mach-O；链接器将项目中的多个Machine-O文件合并成一个。
>
> LLVM架构：
>
> 前端
>
> Clang：负责词法分析、语法分析、语义解析和生成中间代码
>
> LLVM后端
>
> 优化器：代码优化
>
> 后端
>
> 生成目标程序

编译的主要过程：

- LLVM会预处理代码，比如嵌入宏到对于的位置
- 预处理万抽，LLVM会对代码进行此法分析和语法分析，生成AST。
- AST会生成IR，通过IR可以生成多份适合不同平台的机器码，对于iOS系统，IR生成的可执行文件就是Mach-O。

链接器的作用：完成变量、函数符号和其地址的绑定，符号可以理解为变量名和函数名。

链接器主要做：

- 去项目文件里查找目标代码文件里没有定义的变量
- 扫描项目中的不同文件，将所有符号定义和引用地址收集起来，并放到全局符号表中。
- 计算合并后长度及位置，生成同类型的段进行合并，建立绑定
- 对项目中不同文件里的变量进行地址重定位

链接器在整理函数的调用关系时，会以 main 函数为源头，跟随每个引用，并将其标记为live。未被标记为live的函数，就是无用函数。链接器可以通过打开 Dead code stripping 开关，来开启自动去除无用代码的功能



动态链接器dyld

动态库在运行时才会被链接，没有参与Mach-O文件的编译和链接，所以Mach-O文件中并没有包含动态库里的符号定义。这些符号会被显示为“未定义”，但他们的名字和对应的库的路径会被记录。运行时通过dlopen和dlsym导入动态库，先根据记录的库路径找到对应的库，再通过记录的名字符号找到绑定的地址。

dlopen和dlsym示例：

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
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        dynamic_call_function();
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```

输出：

>Hello exchen.net 100
>
>printf function address 0x7fff510a4730



参考：

1、[探秘 Mach-O 文件](https://juejin.im/post/5ab47ca1518825611a406a39)

2、[ [iOS Hacker] dlopen 和 dlsym 动态调用函数](https://www.exchen.net/ios-hacker-dlopen-和-dlsym-动态调用函数.html)

3、iOS开发高手课：链接器：符号是怎么绑定到地址上的？