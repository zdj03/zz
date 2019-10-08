#### Block定义

1、block是带有自动变量（局部变量）的匿名函数

```objc
void (^blk)(void) = ^{};
```

`=`的右边即是一个匿名的函数

2、block定义：

```objc
struct Block_layout{
void *isa;
int flags
int reserved;
void (*invoke)(void*,...);
struct Block_descriptor *descriptor;
/* Imported variables. */
}

struct Block_descriptor {
unsigned long int reserved;
unsigned long int size;
void (*copy)(void *dst, void *src);
void (*dispose)(void *);
}	
```

从定义中，可以看到block有isa成员，OC将block当做对象来处理

#### Block捕获外部变量实质

代码：

```objc
int global_i = 1;
static int static_global_j = 2;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        static int static_k = 3;
        int val = 4;
        
        void (^Myblock)(void) = ^ {
            global_i++;
            static_global_j++;
            static_k++;
            NSLog(@"Block中 global_i = %d,static_global_j = %d,static_k = %d,val = %d",global_i,static_global_j,static_k,val);
        };
        
        global_i++;
        static_global_j++;
        static_k++;
        val++;
        
        NSLog(@"Block外 global_i = %d,static_global_j = %d,static_k = %d,val = %d",global_i,static_global_j,static_k,val);
            
        Myblock();
        
    }
    return 0;
}
```

输出结果：

>**Block外 global_i = 2,static_global_j = 3,static_k = 4,val = 5**
>
>**Block中 global_i = 3,static_global_j = 4,static_k = 5,val = 4**

问题：

1、为什么在block外部的变量不加__block不允许更改变量？

2、为什么自动变量的值没有增加，而其他的全局变量、全局静态变量、静态变量增加了？自动变量是什么时候被捕获进去的？

C++代码？（只显示主要的用于分析问题）

```c++
int global_i = 1;
static int static_global_j = 2;


struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *static_k;
  int val;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_k, int _val, int flags=0) : static_k(_static_k), val(_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int *static_k = __cself->static_k; // bound by copy
  int val = __cself->val; // bound by copy

            global_i++;
            static_global_j++;
            (*static_k)++;
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_c76e33_mi_0,global_i,static_global_j,(*static_k),val);
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        static int static_k = 3;
        int val = 4;

        void (*Myblock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &static_k, val));

        global_i++;
        static_global_j++;
        static_k++;
        val++;

        NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_c76e33_mi_1,global_i,static_global_j,static_k,val);

        ((void (*)(__block_impl *))((__block_impl *)Myblock)->FuncPtr)((__block_impl *)Myblock);

    }
    return 0;
}
```

全局变量和全局静态变量作用域是全局的，捕获了后，可以更改并且值会保存下来。

从结构体__main_block_impl_0可以看出静态变量static_k和自动变量val被捕获进来，并且作为参数传到构造函数中

```c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *static_k;
  int val;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_k, int _val, int flags=0) : static_k(_static_k), val(_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

Block只会捕获内部使用到的变量。

看静态函数：__main_block_func_0

```c++
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int *static_k = __cself->static_k; // bound by copy
  int val = __cself->val; // bound by copy

            global_i++;
            static_global_j++;
            (*static_k)++;
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_c76e33_mi_0,global_i,static_global_j,(*static_k),val);
        }
```

可以看到**bound by copy**的注释。但val是通过__cself->val访问，仅仅捕获了val的值，而不是地址，所有即使在Block内部改了val的值，Block外部不受影响。而static_k是捕获的变量地址，所以在Block可以更改值，并保存下来。

总结：

数据区：

| （高地址）栈区--程序自动分配、释放 |
| ---------------------------------- |
| 堆区—开发者自己管理                |
| 数据区—全局区                      |
| （低地址）程序区--存放程序执行代码 |

1、静态全局变量、全局变量存放在全局区，可以在Block里面被改变

2、静态变量传递给Block的是内存地址，所有可以直接改变

#### Block的copy和release

Block有三种：**_NSConcreteStackBlock**、**_NSConcreteMallocBlock**、**_NSConcreteGlobalBlock**。

区别：

#####1、从捕获外部变量的角度看：

- **_NSConcreteStackBlock**：
  只用到外部局部变量、成员属性变量，且没有强指针引用的block都是stackBlock，stackblock的生命周期由系统控制，一旦返回就被销毁

- **_NSConcreteMallocBlock**

  有强指针引用或copy修饰的成员属性引用的block会被复制一份到堆中成为MallocBlock,没有强指针引用即销毁，生命周期由程序员控制

- **_NSConcreteGlobalBlock**

  没有用到外部变量或只用到全局变量、静态变量的block，生命周期从创建到应用结束。

  如：

  ```objc
  //没有用到外部变量
  void (^Myblock)(void) = ^ { };
  NSLog(@"myBlock:%@",Myblock);
  ```

  输出：

  >myBlock:<__NSGlobalBlock__: 0x100002070>

  ```objc
  //只用到全局变量、静态变量
  void (^Myblock)(void) = ^ {
              global_i++;
              static_global_j++;
              static_k++;
              NSLog(@"Block中 global_i = %d,static_global_j = %d,static_k = %d",global_i,static_global_j,static_k);
          };
  NSLog(@"myBlock:%@",Myblock);
  ```

  输出：

  >myBlock:<__NSGlobalBlock__: 0x100002070>
  >
  >2019-08-04 13:19:24.149372+0800 aa[11804:582241] Block中 global_i = 3,static_global_j = 4,static_k = 5

##### 2、从持有对象的角度看

- _NSConcreteStackBlock不持有对象（以下是在MRC下执行）

  ```objc
  int main(int argc, const char * argv[]) {
     
      NSObject *obj = [NSObject new];
      NSLog(@"1、Block外 obj = %lu",(unsigned long)obj.retainCount);
      
      void(^Myblock)(void) = ^{
          NSLog(@"Block中 obj = %lu",(unsigned long)obj.retainCount);
      };
      
      NSLog(@"2、Block外 obj = %lu",(unsigned long)obj.retainCount);
      
      Myblock();
      
      return 0;
  }
  ```

  输出：

  >1、Block外 obj = 1
  >
  >2、Block外 obj = 1
  >
  >Block中 obj = 1

  C++源码：

  ```c++
  struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    NSObject *obj;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSObject *_obj, int flags=0) : obj(_obj) {
      impl.isa = &_NSConcreteStackBlock;
      impl.Flags = flags;
      impl.FuncPtr = fp;
      Desc = desc;
    }
  };
  static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    NSObject *obj = __cself->obj; // bound by copy
  
          NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_db3503_mi_1,(unsigned long)((NSUInteger (*)(id, SEL))(void *)objc_msgSend)((id)obj, sel_registerName("retainCount")));
      }
  ```

  打印block：

  ```objc
  NSLog(@"Myblock:%@",Myblock);
  ```

  输出：

  > Myblock:<__NSStackBlock__: 0x7ffeefbff498>

- _NSConcreteMallocBlock持有对象

- ```objc
  int main(int argc, const char * argv[]) {
     
      NSObject *obj = [NSObject new];
      NSLog(@"1、Block外 obj = %lu",(unsigned long)obj.retainCount);
      
      void(^Myblock)(void) = [^{
          NSLog(@"Block中 obj = %lu",(unsigned long)obj.retainCount);
      } copy];
      
      NSLog(@"2、Block外 obj = %lu",(unsigned long)obj.retainCount);
      
      Myblock();
      
      return 0;
  }
  ```

  输出：

  > 1、Block外 obj = 1
  >
  > 2、Block外 obj = 2
  >
  > Block中 obj = 2

  C++源码

  ```c++
  struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    NSObject *obj;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSObject *_obj, int flags=0) : obj(_obj) {
      impl.isa = &_NSConcreteStackBlock;
      impl.Flags = flags;
      impl.FuncPtr = fp;
      Desc = desc;
    }
  };
  static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    NSObject *obj = __cself->obj; // bound by copy
  
          NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_214f63_mi_1,(unsigned long)((NSUInteger (*)(id, SEL))(void *)objc_msgSend)((id)obj, sel_registerName("retainCount")));
      }
  ```

  打印block：

  ```objc
  NSLog(@"Myblock:%@",Myblock);
  ```

  输出：

  > Myblock:<__NSMallocBlock__: 0x100662800>

  说明系统将block拷贝到了堆上

- _NSConcreteGlobalBlock也不持有对象

  ```c++
  int main(int argc, const char * argv[]) {
     
      void(^Myblock)(void) = ^{
          NSObject *obj = [NSObject new];
          NSLog(@"Block中 obj = %lu",(unsigned long)obj.retainCount);
      };
      
      Myblock();
      
      return 0;
  }
  ```

  输出：

  > Block中 obj = 1

  C++源码

  ```c++
  struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
      impl.isa = &_NSConcreteStackBlock;
      impl.Flags = flags;
      impl.FuncPtr = fp;
      Desc = desc;
    }
  };
  static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  
          NSObject *obj = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"));
          NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_05a758_mi_0,(unsigned long)((NSUInteger (*)(id, SEL))(void *)objc_msgSend)((id)obj, sel_registerName("retainCount")));
      }
  ```

  打印block：

  ```objc
  NSLog(@"Myblock:%@",Myblock);
  ```

  输出：

  > Myblock:<__NSGlobalBlock__: 0x100001030>

  由于_NSConcreteStackBlock作用域在栈上，一旦函数返回，该block将被销毁。在ARC环境下，以下情况，编译器会自动将block拷贝到堆上：

  - 手动调用copy
  - block是函数的返回值
  - block被强引用，block被赋值给__strong或id类型
  - 调用系统API入参中含有usingBlock的方法

  但是当block是函数（自定义方法传递参数）参数的时候，系统不会自动拷贝，需要手动copy到堆上。

  ##### 3、block copy：将block从栈区拷贝到堆区

  ```objc
  static void *_Block_copy_internal(const void *arg, const int flags) {
      struct Block_layout *aBlock;
      const bool wantsOne = (WANTS_ONE & flags) == WANTS_ONE;
      
      // 1--如果参数为NULL，直接返回NULL
      if (!arg) return NULL;
      
      // 2--将参数类型进行转换为结构体：Block_layout
      aBlock = (struct Block_layout *)arg;
      
      // 3--如果block的flags包含BLOCK_NEEDS_FREE，则block在堆上，此时将引用计数加1
      if (aBlock->flags & BLOCK_NEEDS_FREE) {
          // latches on high
          latching_incr_int(&aBlock->flags);
          return aBlock;
      }
      
      // 4--如果block是全局的，则直接返回此block(因为全局block实际上是单例类型)
      else if (aBlock->flags & BLOCK_IS_GLOBAL) {
          return aBlock;
      }
      
      // 5--此时block是在栈区分配地址的，此时需要将block拷贝到堆区；首先调用malloc函数根据block存储在descriptor结构体变量中的size分配内存地址，如果失败，返回NULL
      struct Block_layout *result = malloc(aBlock->descriptor->size);
      if (!result) return (void *)0;
      
      // 6--将栈区中block的元数据拷贝到上一步中分配的内存地址中
      memmove(result, aBlock, aBlock->descriptor->size); // bitcopy first
      
      // 7--更新flag：
    	//  1、确保引用计数为0
    	//  2、将flag设置为BLOCK_NEEDS_FREE，将block的引用计数设置为1
      result->flags &= ~(BLOCK_REFCOUNT_MASK);    // XXX not needed
      result->flags |= BLOCK_NEEDS_FREE | 1;
      
      // 8--设置isa为_NSConcreteMallocBlock，表示此block是堆block
      result->isa = _NSConcreteMallocBlock;
      
      // 9--如果block有copy方法，则调用copy
    	// 如果有必要，编译器会自动生成一个copy的辅助方法，block有必要捕获对象时，copy方法会引用捕获的对象
      if (result->flags & BLOCK_HAS_COPY_DISPOSE) {
          (*aBlock->descriptor->copy)(result, aBlock); // do fixup
      }
      
      return result;
  }
  ```

  

  ##### 4、block dispose

  ```objc
  void _Block_release(void *arg) {
      // 1--类型转换，如果转换为NULL，则直接返回
      struct Block_layout *aBlock = (struct Block_layout *)arg;
      if (!aBlock) return;
      
      // 2--将引用计数减1
      int32_t newCount;
      newCount = latching_decr_int(&aBlock->flags) & BLOCK_REFCOUNT_MASK;
      
      // 3--如果引用计数大于0，则无需销毁，直接返回
      if (newCount > 0) return;
      
      // 4--如果block的flags包含BLOCK_NEEDS_FREE，则表明是堆区block并且引用计数为0，则需要销毁。
    	// 1、调用block的dispose帮助方法
    	// 2、释放copy方法里引用的对象
    	// 3、销毁block，释放内存
      if (aBlock->flags & BLOCK_NEEDS_FREE) {
          if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE)(*aBlock->descriptor->dispose)(aBlock);
          _Block_deallocator(aBlock);
      }
      
      // 5--全局block，无需销毁
      else if (aBlock->flags & BLOCK_IS_GLOBAL) {
          ;
      }
      
      // 6--发生了意外情况，仅仅打印block的信息
      else {
          printf("Block_release called upon a stack Block: %p, ignored\n", (void *)aBlock);
      }
  }
  ```

  

  在C++源码中，会发现有一对方法：copy 、dispose

  ```objc
  static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->obj, (void*)src->obj, 3/*BLOCK_FIELD_IS_OBJECT*/);}
  
  static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->obj, 3/*BLOCK_FIELD_IS_OBJECT*/);}
  ```

  >在C语言的结构体中，编译器没法很好的进行初始化和销毁操作。所以在
  >
  >__main_block_desc_0结构体中增加了成员变量，利用OC的Runtime进行内存管理

  ```c++
  static struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
    void (*dispose)(struct __main_block_impl_0*);
  }
  ```

  这里的BLOCK_FIELD_IS_OBJECT对应着捕获对象时候的特殊表示，如果捕获的__block，则是BLOCK_FIELD_IS_BYREF。

#### Block中__block实现原理

#####1、数值类型变量

```objc
int main(int argc, const char * argv[]) {
   
    __block int i = 0;
    
    void(^Myblock)(void) = ^ {
        i++;
        NSLog(@"%d",i);
    };
    Myblock();
    
    return 0;
}
```

输出：

> 2019-08-04 15:20:27.612880+0800 aa[13596:671249] 1

C++源码：

```c++

struct __Block_byref_i_0 {
  void *__isa;
__Block_byref_i_0 *__forwarding;
 int __flags;
 int __size;
 int i;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_i_0 *i; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_i_0 *_i, int flags=0) : i(_i->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_i_0 *i = __cself->i; // bound by ref

        (i->__forwarding->i)++;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_a031ed_mi_0,(i->__forwarding->i));
    }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->i, (void*)src->i, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->i, 8/*BLOCK_FIELD_IS_BYREF*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
int main(int argc, const char * argv[]) {

    __attribute__((__blocks__(byref))) __Block_byref_i_0 i = {(void*)0,(__Block_byref_i_0 *)&i, 0, sizeof(__Block_byref_i_0), 0};

    void(*Myblock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_i_0 *)&i, 570425344));
    ((void (*)(__block_impl *))((__block_impl *)Myblock)->FuncPtr)((__block_impl *)Myblock);

    return 0;
}
```

从源码可以发现：__block变量转化成了结构体变量：__Block_byref_i_0

```c++
struct __Block_byref_i_0 {
  void *__isa;//isa指针
__Block_byref_i_0 *__forwarding;//指向自身类型的__forwarding指针
 int __flags;//标记flag
 int __size;//大小
 int i;//变量值，名字和变量名同名
};
```

源码中初始化i：__forwarding指针初始化传递的是自己（i）的地址

```c++
__attribute__((__blocks__(byref))) __Block_byref_i_0 i = {(void*)0,(__Block_byref_i_0 *)&i, 0, sizeof(__Block_byref_i_0), 0};
```

但是，__forwarding不是永远都指向自己的。

```objc
int main(int argc, const char * argv[]) {
   
    __block int i = 0;
    NSLog(@"%p",&i);
    
    void(^Myblock)(void) = [^ {
        i++;
        NSLog(@"%p",&i);
    } copy];
    Myblock();
    
    return 0;
}

```

输出：

>2019-08-04 15:30:29.933933+0800 aa[13747:678726] 0x7ffeefbff4c8
>
>2019-08-04 15:30:29.935016+0800 aa[13747:678726] 0x10070ffb8

可见，二者地址相差很大，说明**__forwarding**指针并没有指向之前的自己了。代码里调用了copy方法，将block拷贝到了堆上，那么在栈区和堆区都会有一份block，堆上的block也会继续持有该**__block**变量，当Block释放的时候，**__block**没有被任何对象引用，也会被释放销毁。

**这里__forwarding**指针把原来指向自己，改为指向堆上的block里的**__block**变量，然后堆上的变量的**__forwarding**再指向自己。这样不管**__block**复制到堆上还是在栈上，都可以通过(i->__forwarding->i)来访问到变量值。如以下源码所示：

```objc
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_i_0 *i = __cself->i; // bound by ref
  __Block_byref_j_1 *j = __cself->j; // bound by ref

        (i->__forwarding->i)++;
        (j->__forwarding->j)++;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_06b7dd_mi_0,(i->__forwarding->i));
    }
```

在ARC下，Block也是存在\_NSStackBlock，之所以打印出来是\_NSConcreteMallocBlock，是因为对block进行了赋值操作，会导致调用：objc_retainBlock->\_Block_copy->\_Block_copy_internal方法链，并导致\_\_NSStackBlock\_\_类型转换为\_\_NSMallockBlock\_\_

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block int i = 0;
       
        NSLog(@"%@",^{NSLog(@"%d  %p",i++, &i);});
    }   
    return 0;
}
```

输出：

> 2019-08-04 15:51:38.425485+0800 aa[14010:691652] <__NSStackBlock__: 0x7ffeefbff488>

在MRC下，只有copy，\__block才会被复制到堆上，否则，\_\_block一直都在栈上，block也只是\_\_NSStackBlock，\_\_forwarding指针指向自己



#####2、对象变量

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
            __block id block_obj = [NSObject new];
               id obj = [NSObject new];
               
               NSLog(@"block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);

               void(^Myblock)(void) = ^{
                   NSLog(@"***Block中****block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
               };
               Myblock();
    }
    
    return 0;
}
```

输出：

> block_obj = [<NSObject: 0x1007325d0> , 0x7ffeefbff4c8] , obj = [<NSObject: 0x10072f860> , 0x7ffeefbff498]
>
>\**\*Block中\**\**block_obj = [<NSObject: 0x1007325d0> , 0x102801c88] , obj = [<NSObject: 0x10072f860> , 0x102801c00]

C++源码：

```objc
struct __Block_byref_block_obj_0 {
  void *__isa;
__Block_byref_block_obj_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 id block_obj;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  id obj;
  __Block_byref_block_obj_0 *block_obj; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, id _obj, __Block_byref_block_obj_0 *_block_obj, int flags=0) : obj(_obj), block_obj(_block_obj->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_block_obj_0 *block_obj = __cself->block_obj; // bound by ref
  id obj = __cself->obj; // bound by copy

                   NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_29792f_mi_1,(block_obj->__forwarding->block_obj) , &(block_obj->__forwarding->block_obj) , obj , &obj);
               }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->block_obj, (void*)src->block_obj, 8/*BLOCK_FIELD_IS_BYREF*/);_Block_object_assign((void*)&dst->obj, (void*)src->obj, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->block_obj, 8/*BLOCK_FIELD_IS_BYREF*/);_Block_object_dispose((void*)src->obj, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
            __attribute__((__blocks__(byref))) __Block_byref_block_obj_0 block_obj = {(void*)0,(__Block_byref_block_obj_0 *)&block_obj, 33554432, sizeof(__Block_byref_block_obj_0), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"))};
               id obj = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"));

               NSLog((NSString *)&__NSConstantStringImpl__var_folders_gd_qcx3jzhx5x54hg2ls6n72qmc0000gn_T_main_29792f_mi_0,(block_obj.__forwarding->block_obj) , &(block_obj.__forwarding->block_obj) , obj , &obj);

               void(*Myblock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, obj, (__Block_byref_block_obj_0 *)&block_obj, 570425344));
               ((void (*)(__block_impl *))((__block_impl *)Myblock)->FuncPtr)((__block_impl *)Myblock);
    }

    return 0;
}
```

从源码可以看出，Block捕获了\_\_block并且强引用，在\_\_Block_byref_block_obj_0结构体中，有个变量是id block_obj，这个默认是\_\_strong所有权修饰符的

从打印结果看，ARC下，Block捕获外部对象变量，是copy一份，地址不同。只不过\_\_block修饰符的变量会被捕获到Block内部持有。

MRC下

```objc
int main(int argc, const char * argv[]) {
   // @autoreleasepool {
            __block id block_obj = [NSObject new];
               id obj = [NSObject new];
               
               NSLog(@"block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);

               void(^Myblock)(void) = ^{
                   NSLog(@"***Block中****block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
               };
               Myblock();
   // }
    
    return 0;
}

```

输出：

>block_obj = [<NSObject: 0x10063a1b0> , 0x7ffeefbff4c8] , obj = [<NSObject: 0x100637440> , 0x7ffeefbff498]
>
> \**\*Block中\**\**block_obj = [<NSObject: 0x10063a1b0> , 0x7ffeefbff4c8] , obj = [<NSObject: 0x100637440> , 0x7ffeefbff470]

打印二者的retainCount:

```objc
NSLog(@"block_obj_retainCount:%ld",block_obj.retainCount);
NSLog(@"obj_retainCount:%ld",obj.retainCount);
```

输出：

> block_obj_retainCount:1
>
>obj_retainCount:1

block调用copy方法后,block被copy到堆上，打印retainCount，输出：

> block_obj_retainCount:1
>
>obj_retainCount:2

### Block链式调用语法：

链式编程思想：将block作为方法的返回值，且返回值的类型为调用者本身，并将该方法以setter的形式返回。for example:

```objective-c
@implementation CalculateMaker

- (CalculateMaker * _Nonnull (^)(CGFloat))add{
    return ^CalculateMaker*(CGFloat num){
        self.result += num;
        return self;
    };
}

@end
  
  
CalculateMaker *make = CalculateMaker.new;
make.add(20).add(20);
```

上面调用的过程等同于：

```objc
CalculateMaker *make = CalculateMaker.new;
// 0：调用add，返回block
CalculateMaker*(^add_0)(CGFloat num) = make.add;
// 1：执行block，返回对象
CalculateMaker* make_add_0 = add_0(20);

// 以下两步重复上面
CalculateMaker*(^add_1)(CGFloat num) = make_add_0.add;
CalculateMaker* make_add_1 = add_1(20);

NSLog(@"result:%f",make_add_1.result);
```

打印maker的地址：

```objc
NSLog(@"make：%p", make);
NSLog(@"make_add_0：%p", make_add_0);
NSLog(@"make_add_1：%p", make_add_1);
```

输出结果如下，三者地址是一样的：

>2019-08-04 11:27:54.522056+0800 aa[10580:520503] make：0x100519e80
>
>2019-08-04 11:27:54.523339+0800 aa[10580:520503] make_add_0：0x100519e80
>
>2019-08-04 11:27:54.523904+0800 aa[10580:520503] make_add_1：0x100519e80

经典链式调用参考Masonry



参考：

1、Objective-C高级编程 iOS与OSX多线程和内存管理