### 一 Runtime简介

Objective-C是动态语言，它不仅需要一个编译器，也需要一个运行时系统来动态的创建类和对象、进行消息传递和转发。

Objc在三种层面上与Runtime系统进行交互：

#### 1、通过Objective-C源代码

一般情况下开发者只需要编写OC代码即可，Runtime系统自动在幕后把我们写的源代码在编译阶段转换成运行时代码，在运行时确定对应的数据结构和调用具体哪个方法。Runtime库是在app启动时main()函数执行之前加载进来的。

#### 2、通过对Runtime库函数的直接调用

定义在头文件<objc/runtime.h>中

#### 3、通过Foundation框架的NSObject类定义的方法

在Foundation框架下NSObject和NSProxy两个基类，定义了类层次结构中该类下所有类的公共接口和行为。除了NSProxy，所有的类都是NSObject的子类，NSProxy是专门用于实现代理对象的类。

~~在NSObject协议中，以下5个方法时可以从Runtime中获取信息，让对象进行自我检查。~~



类（Class）是什么？它是一个指向结构体的指针

```objective-c
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;
```

而objc_class又是什么？

```objective-c
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */

```

- 1、`isa`所有的类自身也是一个对象，这个对象的Class里也有isa指针，它指向元类（metaClass）

- 2、`super_class`指向父类，如果是最顶层的类（如NSObject或NSProxy，则为NULL）

- 3、`objc_ivar_list`

  ```objective-c
  struct objc_ivar_list {
      int ivar_count                                           OBJC2_UNAVAILABLE;
  #ifdef __LP64__
      int space                                                OBJC2_UNAVAILABLE;
  #endif
      /* variable length structure */
      struct objc_ivar ivar_list[1]                            OBJC2_UNAVAILABLE;
  }     
  
  struct objc_ivar {
      char * _Nullable ivar_name                               OBJC2_UNAVAILABLE;
      char * _Nullable ivar_type                               OBJC2_UNAVAILABLE;
      int ivar_offset                                          OBJC2_UNAVAILABLE;
  #ifdef __LP64__
      int space                                                OBJC2_UNAVAILABLE;
  #endif
  } 
  ```

  `ivar_offset`基地址偏移量，在获取实例变量的时候，是通过地址偏移量offset找到的

  `objc_property_t`属性类型，是指向objc_property的指针

  ```objective-c
  typedef struct objc_property *objc_property_t;
  ```

  `objc_property_attribute_t`定义了属性的特性(`attribute`)，它是一个结构体，定义如下：

  ```objective-c
  typedef struct {
      const char *name;           // 特性名
      const char *value;          // 特性值
  } objc_property_attribute_t;
  ```

  

  **关联对象（Associate Object)**

  在OC的分类中，我们只能添加方法（类方法、实例方法）和协议，但不能添加成员变量。但是可以通过关联对象的方式，另辟蹊径给分类添加"成员变量"。那么是怎么实现的呢？我们做法如下：

  关联对象：

  ```
  static char theKey;
  objc_setAssociatedObject(self, &theKey, anObject, OBJC_ASSOCIATION_RETAIN);
  ```

  

  我们通过给定的key，runtime会将对象关联到实例上，key是一个Void指针（const void*），指定一个内存管理策略，告诉Runtime内存的管理方式。有如下几种：

  ```objective-c
  /* Associative References */
  
  /**
   * Policies related to associative references.
   * These are options to objc_setAssociatedObject()
   */
  typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
      OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
      OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                              *   The association is not made atomically. */
      OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                              *   The association is not made atomically. */
      OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                              *   The association is made atomically. */
      OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                              *   The association is made atomically. */
  };
  
  ```

  另外：如果这里的对象`self`用同一个`key`又关联了另外一个对象，之前关联的对象会被移除掉。

  取出对象：

  ```objective-c
  id anObject = objc_getAssociatedObject(self, &theKey);
  ```

  

- 4、`objc_method_list`

  ```objective-c
  struct objc_method_list {
      struct objc_method_list * _Nullable obsolete             OBJC2_UNAVAILABLE;
  
      int method_count                                         OBJC2_UNAVAILABLE;
  #ifdef __LP64__
      int space                                                OBJC2_UNAVAILABLE;
  #endif
      /* variable length structure */
      struct objc_method method_list[1]                        OBJC2_UNAVAILABLE;
  }                                                            OBJC2_UNAVAILABLE;
  
  struct objc_method {
      SEL _Nonnull method_name                                 OBJC2_UNAVAILABLE;
      char * _Nullable method_types                            OBJC2_UNAVAILABLE;
      IMP _Nonnull method_imp                                  OBJC2_UNAVAILABLE;
  }
  ```

  `objc_method`中，SEL表示选择器，是表示一个方法的selector的指针，定义如下：

  ```objective-c
  typedef struct objc_selector *SEL;
  ```

  在编译时，编译器会根据每个方法的名字、参数序列，生成一个唯一的整形标识(Int类型的地址)，这个标识就是SEL。两个类之间，不管是不是继承关系，只要方法名相同，SEL就是一样的，和参数无关。不同 的类可以拥有相同的selector，不同类的实例对象执行相同的selector时，会在各自的方法列表中根据selector去寻找对应的`IMP`

  > SEL只是一个指向方法的指针（只是一个根据方法名hash化了的key值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度



`IMP`是一个函数指针，指向方法实现的首地址，定义：

```objective-c
id (*IMP)(id, SEL, ...)
```

第一个参数指向self的指针（如果是实例方法，则指向类实例的内存地址；如果是类方法，则指向元类的指针），第二个参数指向selector，后面是参数列表。



我们可以通过取得IMP，跳过Runtime的消息传递机制，直接执行IMP执行的函数实现，比向对象发送消息更加高效。

- 5、cache用于缓存最近使用过的方法。

- 6、`objc_protocol_list`协议列表

  ```objective-c
  struct objc_protocol_list {
      struct objc_protocol_list * _Nullable next;
      long count;
      __unsafe_unretained Protocol * _Nullable list[1];
  };
  
  typedef struct objc_object Protocol;
  ```

  可以看到，Protocol实际上是一个表示实例的结构体。需要强调的是，协议一旦注册后就不可再修改，即无法再通过调用`protocol_addMethodDescription`、`protocol_addProtocol`和`protocol_addProperty`往协议中添加方法等。



NSObject定义：

```objective-c
@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}

+ (void)load;

+ (void)initialize;
- (instancetype)init
#if NS_ENFORCE_NSOBJECT_DESIGNATED_INITIALIZER
    NS_DESIGNATED_INITIALIZER
#endif
    ;

+ (instancetype)new OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
+ (instancetype)allocWithZone:(struct _NSZone *)zone OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
+ (instancetype)alloc OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
- (void)dealloc OBJC_SWIFT_UNAVAILABLE("use 'deinit' to define a de-initializer");

- (void)finalize OBJC_DEPRECATED("Objective-C garbage collection is no longer supported");

- (id)copy;
- (id)mutableCopy;

+ (id)copyWithZone:(struct _NSZone *)zone OBJC_ARC_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone OBJC_ARC_UNAVAILABLE;

+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
+ (BOOL)conformsToProtocol:(Protocol *)protocol;
- (IMP)methodForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;
- (void)doesNotRecognizeSelector:(SEL)aSelector;

- (id)forwardingTargetForSelector:(SEL)aSelector OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
- (void)forwardInvocation:(NSInvocation *)anInvocation OBJC_SWIFT_UNAVAILABLE("");
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector OBJC_SWIFT_UNAVAILABLE("");

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector OBJC_SWIFT_UNAVAILABLE("");

- (BOOL)allowsWeakReference UNAVAILABLE_ATTRIBUTE;
- (BOOL)retainWeakReference UNAVAILABLE_ATTRIBUTE;

+ (BOOL)isSubclassOfClass:(Class)aClass;

+ (BOOL)resolveClassMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
+ (BOOL)resolveInstanceMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

+ (NSUInteger)hash;
+ (Class)superclass;
+ (Class)class OBJC_SWIFT_UNAVAILABLE("use 'aClass.self' instead");
+ (NSString *)description;
+ (NSString *)debugDescription;

@end
```

- `Class isa`可以根据实例的isa找到实例所属的类，但是已被废弃掉

- `+load`在App启动pre-main阶段，加载runtime库时，会调用类的`+load`方法，是个空方法

  ```objective-c
  + (void)load {}
  ```

- `+initialize`在类或者子类收到第一条消息（包括类的实例方法和类方法）之前调用，它是以懒加载方法被调用

  **+load和+initialize的区别详细可见：**[Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/)

​	

我们在初始化一个类实例的时候，类似于：[[Cls alloc] init];

- `+alloc`分配内存

  创建对象，包括：分配足够的内存保存对象，将isa指向类，初始化引用计数，重置所有实例变量

  ```
  + (id)alloc {
      return _objc_rootAlloc(self);
  }
  // Base class implementation of +alloc. cls is not nil.
  // Calls [cls allocWithZone:nil].
  id
  _objc_rootAlloc(Class cls)
  {
      return callAlloc(cls, false/*checkNil*/, true/*allocWithZone*/);
  }
  ```

  

- `-init`初始化

  初始化对象，此时对象才处于可用状态，即所有的实例变量会被赋予合理有效值

  ```objective-c
  - (id)init {
      return _objc_rootInit(self);
  }
  
  id
  _objc_rootInit(id obj)
  {
      // In practice, it will be hard to rely on this function.
      // Many classes do not properly chain -init calls.
      return obj;
  }
  ```

  我们在重写一个对象的init方法时，都是如下格式：

  ```objective-c
  - (instancetype)init {
      if (self = [super init]) {
          //TODO...
      }
      return self;
  }
  ```

  **init方法可以通过返回nil来告诉开发者, 初始化失败了**
  即, 如果你的超类初始化自己的时候失败了, 那么当前的类即处于一个**不稳定状态**,
  即有可能你的初始化成功, 也有可能失败.
  所以, 此时你的实现里不要再继续你的初始化并且要通过返回`nil`
  如果不这么做的话, 接下来的操作可能会操控一个不可用对象(即创建失败),
  这个行为是不可预测的, 有可能会导致**程序崩溃**.
  所以我们在重写`init`方法的时候, 要用以上的写法, 保证你的创建过程的容错性。

​		callAlloc函数的详细解析参照：[objc alloc](https://blog.csdn.net/qqq274628593/article/details/53023492)

- `+new`，实现过程综合了alloc、init

  ```objective-c
  + (id)new {
      return [callAlloc(self, false/*checkNil*/) init];
  }
  ```

- `-dealloc`

  1、销毁实例

  - 销毁实例，不释放内存
  - 调用c++ destructors
  - 清理ARC 实例变量
  - 移除相关的引用对象

  ```
  /***********************************************************************
  * objc_destructInstance
  * Destroys an instance without freeing memory. 
  * Calls C++ destructors.
  * Calls ARC ivar cleanup.
  * Removes associative references.
  * Returns `obj`. Does nothing if `obj` is nil.
  **********************************************************************/
  void *objc_destructInstance(id obj) 
  {
      if (obj) {
          // Read all of the flags at once for performance.
          bool cxx = obj->hasCxxDtor();
          bool assoc = obj->hasAssociatedObjects();
  
          // This order is important.
          if (cxx) object_cxxDestruct(obj);
          if (assoc) _object_remove_assocations(obj);
          obj->clearDeallocating();
      }
  
      return obj;
  }
  ```

  2、释放内存

  ```c
   free(obj);
  ```

- `+instancesRespondToSelector`、`-methodForSelector`、`-instanceMethodForSelector`通过调用runtime库的函数实现

- `doesNotRecognizeSelector`直接抛出异常

- `resolveClassMethod`、`resolveInstanceMethod`用于消息动态解析

- `forwardingTargetForSelector`、`forwardInvocation`、`methodSignatureForSelector`、`instanceMethodSignatureForSelector`用于消息转发的阶段。

  **消息动态解析和转发详见（5）Runtime消息发送与转发**



NSObject类还实现了NSObject协议，协议定义：

```objective-c
@protocol NSObject

- (BOOL)isEqual:(id)object;
@property (readonly) NSUInteger hash;

@property (readonly) Class superclass;
- (Class)class OBJC_SWIFT_UNAVAILABLE("use 'type(of: anObject)' instead");
- (instancetype)self;

- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (BOOL)isProxy;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)respondsToSelector:(SEL)aSelector;

- (instancetype)retain OBJC_ARC_UNAVAILABLE;
- (oneway void)release OBJC_ARC_UNAVAILABLE;
- (instancetype)autorelease OBJC_ARC_UNAVAILABLE;
- (NSUInteger)retainCount OBJC_ARC_UNAVAILABLE;

- (struct _NSZone *)zone OBJC_ARC_UNAVAILABLE;

@property (readonly, copy) NSString *description;
@optional
@property (readonly, copy) NSString *debugDescription;

@end
```

- performSelector:的三个方法，都是直接调用objc_msgSend函数。

- isProxy会另外再讲

- 重点看几组方法

  先看几个重要方法的实现源码

  ```objective-c
  + (Class)class {
      return self;
  }
  
  - (Class)class {
      return object_getClass(self);
  }
  
  
  /***********************************************************************
  * object_getClass.
  * Locking: None. If you add locking, tell gdb (rdar://7516456).
  **********************************************************************/
  Class object_getClass(id obj)
  {
      if (obj) return obj->getIsa();
      else return Nil;
  }
  
  
  inline Class 
  objc_object::getIsa() 
  {
      if (!isTaggedPointer()) return ISA();
  
      uintptr_t ptr = (uintptr_t)this;
      if (isExtTaggedPointer()) {
          uintptr_t slot = 
              (ptr >> _OBJC_TAG_EXT_SLOT_SHIFT) & _OBJC_TAG_EXT_SLOT_MASK;
          return objc_tag_ext_classes[slot];
      } else {
          uintptr_t slot = 
              (ptr >> _OBJC_TAG_SLOT_SHIFT) & _OBJC_TAG_SLOT_MASK;
          return objc_tag_classes[slot];
      }
  }
  
  
  inline Class 
  objc_object::ISA() 
  {
      assert(!isTaggedPointer()); 
  #if SUPPORT_INDEXED_ISA
      if (isa.nonpointer) {
          uintptr_t slot = isa.indexcls;
          return classForIndex((unsigned)slot);
      }
      return (Class)isa.bits;
  #else
      return (Class)(isa.bits & ISA_MASK);
  #endif
  }
  ```

  从源码可以看出，类对象调用`class`返回的是类本身，而实例对象调用`class`是通过isa指针找到所属的类

  

  通过一张经典的图查看类与实例的继承关系及isa指针的指向(实线表示继承关系，虚线表示isa指向)

  ![class&meta_class](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/class&meta_class.jpg)

  

  

  - `conformsToProtocol:`

    ```objective-c
    + (BOOL)conformsToProtocol:(Protocol *)protocol {
        if (!protocol) return NO;
        for (Class tcls = self; tcls; tcls = tcls->superclass) {
            if (class_conformsToProtocol(tcls, protocol)) return YES;
        }
        return NO;
    }
    
    - (BOOL)conformsToProtocol:(Protocol *)protocol {
        if (!protocol) return NO;
        for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
            if (class_conformsToProtocol(tcls, protocol)) return YES;
        }
        return NO;
    }
    ```

    类对象是经过类本身的继承层次，去寻找实现的协议的过程；而实例对象首先找到实例所属的类对象，再去实现此过程。

  - `isMemberOfClass`

    ```objective-c
    + (BOOL)isMemberOfClass:(Class)cls {
        return object_getClass((id)self) == cls;
    }
    
    - (BOOL)isMemberOfClass:(Class)cls {
        return [self class] == cls;
    }
    ```

    类对象首先通过isa找到元类，再进行比较；而实例对象先通过isa找到所属的类对象，进行比较

    > 这里类对象中的self，指的是类，但是OC中，类对象本身又是元类的实例，所以可以通过id转化为实例对象，通过调用实例方法object_getClass获取到所属的类（这里是元类）

  - `isKindOfClass`

    ```objective-c
    + (BOOL)isKindOfClass:(Class)cls {
        for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
        }
        return NO;
    }
    
    - (BOOL)isKindOfClass:(Class)cls {
        for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
        }
        return NO;
    }
    ```

    类对象先通过isa找到所属的元类，再经过继承层次，进行比较；而实例对象通过isa找到所属的类，再经过继承层次，进行比较。



来看一个经典的场景：

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BOOL res1 = [(id)[NSObject class] isKindOfClass:[NSObject class]];
    BOOL res2 = [(id)[NSObject class] isMemberOfClass:[NSObject class]];
    BOOL res3 = [(id)[Son class] isKindOfClass:[Son class]];
    BOOL res4 = [(id)[son class] isMemberOfClass:[Son class]];
    
    NSLog(@"%d %d %d %d", res1, res2, res3, res4);
}	 
```

打印如下：

> **2019-06-02 07:41:24.178124+0800 Awesome[24097:4825747] 1 0 0 0**

+(BOOL)isKindOfClass:(Class)cls方法内部，会先去获得object_getClass的类，而object_getClass的源码实现是去调用当前类的obj_getIsa()，最后在ISA()方法中获得meta class的指针。

接着在isKindOfClass中有一个循环，先判断class是否等于meta class，不等就继续循环判断是否等于super class，不等再继续取super class，如此循环下去。

- [NSObject class]执行完之后调用isKindOfClass，第一次判断先判断NSObject 的meta class和NSObject是否相等，从上图中可以看出，NSObject的meta class与本身不等。接着第二次循环判断meta class的superclass和NSObject是否相等，从图中可以看到，Root class(meta)的superclass就是Root class(class)，也就是NSObject本身。所以第二次循环相等，res1 = YES。
- 同理，[Son class]执行完之后调用isKindClass，第一次循环，Son的meta class与[Son class]不等，第二次循环，Son meta class指向的是NSObject meta Class，和Son Class不相等。第三次for循环，NSObject meta Class的super class指向的是NSObject Class，和Son Class不相等，第四次循环，NSObject Class的super class指向nil，和Son Class不相等，第四次循环之后，退出循环，所以res3 = NO；

如果把这里的Son 改成它的实例对象，[son isKindOfClass:[Son class]]，那么就输出YES了。因为在isKindOfClass函数中，判断son的isa指向是否指向自己的类Son，第一次循环就输出YES了。

isMemberOfClass的源码实现是拿到自己的isa指针和自己比较，是否相等。

- **BOOL** res2 = [(**id**)[NSObject class] isMemberOfClass:[NSObject class]];相当于[NSObject isMemberOfClass:NSObject],而isMemberOfClass:实现是：NSObject的isa与NSObject本身对比，显然NSObject的isa指向metaClass，与NSObject不等
- BOOL res4 = [(id)[son class] isMemberOfClass:[Son class]];实现是[son class]是Son类，等同于[(id)[Son  isMemberOfClass: Son];而Son的isa指向meta Class，和Son Class也不等



#### NSObject 与 NSProxy

先看NSProxy类定义：

```objective-c
@interface NSProxy <NSObject> {
    Class	isa;
}

+ (id)alloc;
+ (id)allocWithZone:(nullable NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
+ (Class)class;

- (void)forwardInvocation:(NSInvocation *)invocation;
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel NS_SWIFT_UNAVAILABLE("NSInvocation and related APIs not available");
- (void)dealloc;
- (void)finalize;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
+ (BOOL)respondsToSelector:(SEL)aSelector;

- (BOOL)allowsWeakReference API_UNAVAILABLE(macos, ios, watchos, tvos);
- (BOOL)retainWeakReference API_UNAVAILABLE(macos, ios, watchos, tvos);

// - (id)forwardingTargetForSelector:(SEL)aSelector;

@end
```

相比NSObject，NSProxy类定义的接口很少，相对轻量级。

官方说明如下：

>| Summary                                                      |
>| ------------------------------------------------------------ |
>| An abstract superclass defining an API for objects that act as stand-ins for other objects or for objects that don’t exist yet. |
>| Declaration`@interface NSProxy`                              |
>| DiscussionTypically, a message to a proxy is forwarded to the real object or causes the proxy to load (or transform itself into) the real object. Subclasses of `NSProxy` can be used to implement transparent distributed messaging (for example, [NSDistantObject](apple-reference-documentation://hcjbKo5Y4O)) or for lazy instantiation of objects that are expensive to create.`NSProxy` implements the basic methods required of a root class, including those defined in the [NSObject](apple-reference-documentation://hcG_DhA_-L) protocol. However, as an abstract class it doesn’t provide an initialization method, and it raises an exception upon receiving any message it doesn’t respond to. A concrete subclass must therefore provide an initialization or creation method and override the [forwardInvocation:](apple-reference-documentation://hcINGMrSPT) and [methodSignatureForSelector:](apple-reference-documentation://hcI0I_Bfhp) methods to handle messages that it doesn’t implement itself. A subclass’s implementation of [forwardInvocation:](apple-reference-documentation://hcINGMrSPT) should do whatever is needed to process the invocation, such as forwarding the invocation over the network or loading the real object and passing it the invocation. [methodSignatureForSelector:](apple-reference-documentation://hcI0I_Bfhp) is required to provide argument type information for a given message; a subclass’s implementation should be able to determine the argument types for the messages it needs to forward and should construct an [NSMethodSignature](apple-reference-documentation://hcLJKSpwpo) object accordingly. See the [NSDistantObject](apple-reference-documentation://hcjbKo5Y4O), [NSInvocation](apple-reference-documentation://hcjVj4h-wP), and [NSMethodSignature](apple-reference-documentation://hcLJKSpwpo) class specifications for more information. |
>|                                                              |

意思是：NSProxy是个抽象的超类，为其他对象（或者不存在的对象）扮演替身的角色。通常，给proxy的消息被转发给实际对象或者导致proxy加载（转化它为）实际对象。NSProxy的子类能被用来实现透明的分布式消息(例如:NSDistantObject)或者延缓要花费昂贵代价创建的对象的实现。

注意：NSProxy不像NSObject，它没有定义默认的指定构造器方法（init方法）；



场景一（官方Demo）：多继承

我们知道OC不同于其他面向对象语言（如C++），有多重继承的特性。但是OC可以通过Runtime的消息转发特性实现多重继承。

```
@implementation TargetProxy

- (id)initWithTarget1:(id)t1 target2:(id)t2 {
    realObject1 = [t1 retain];
    realObject2 = [t2 retain];
    return self;
}

- (void)dealloc {
    [realObject1 release];
    [realObject2 release];
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig;
    sig = [realObject1 methodSignatureForSelector:aSelector];
    if (sig) return sig;
    sig = [realObject2 methodSignatureForSelector:aSelector];
    return sig;
}

// Invoke the invocation on whichever real object had a signature for it.
- (void)forwardInvocation:(NSInvocation *)invocation {
    id target = [realObject1 methodSignatureForSelector:[invocation selector]] ? realObject1 : realObject2;
    [invocation invokeWithTarget:target];
}

// Override some of NSProxy's implementations to forward them...
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([realObject1 respondsToSelector:aSelector]) return YES;
    if ([realObject2 respondsToSelector:aSelector]) return YES;
    return NO;
}

```

通过自定义init初始化方法，传进来两个对象，用于消息的转发过程中的接收对象。注意，此处两个对象类型是透明的。具体类型要看调用时的代码。

```objective-c
 // Create an empty mutable string, which will be one of the
    // real objects for the proxy.
    NSMutableString *string = [[NSMutableString alloc] init];

    // Create an empty mutable array, which will be the other
    // real object for the proxy.
    NSMutableArray *array = [[NSMutableArray alloc] init];

    // Create a proxy to wrap the real objects.  This is rather
    // artificial for the purposes of this example -- you'd rarely
    // have a single proxy covering two objects.  But it is possible.
    id proxy = [[TargetProxy alloc] initWithTarget1:string target2:array];

    // Note that we can't use appendFormat:, because vararg methods
    // cannot be forwarded!
    [proxy appendString:@"This "];
    [proxy appendString:@"is "];
    [proxy addObject:string];
    [proxy appendString:@"a "];
    [proxy appendString:@"test!"];

    NSLog(@"count should be 1, it is: %d", [proxy count]);
    
    if ([[proxy objectAtIndex:0] isEqualToString:@"This is a test!"]) {
        NSLog(@"Appending successful.got: '%@'", proxy);
    } else {
        NSLog(@"Appending failed, got: '%@'", proxy);
    }

    NSLog(@"Example finished without errors.");
```

输出：

>count should be 1, it is: 1
>
>Appending successful.got: '<TargetProxy: 0x10061a680>
>
>Example finished without errors.



此处，用于初始化proxy的两个对象类型是 NSMutableString和NSMutableArray，而用于转发的消息分别是appendString:和addObject：。当向TargetProxy实例发送消息时，它并没有具体实现，于是开始消息的转发过程，分别交由realObject1、realObject2去接收消息，实现：一个对象实现另外多个不同的对象的方法功能。

**注意：从NSProxy的定义可以看出，官方将消息转发的第一步forwardingTargetForSelector：注释掉了**，我将方法添加进去，可以实现同样的功能。如下：

```objective-c
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
    
    if ([realObject1 respondsToSelector:aSelector]) {
        return realObject1;
    }
    
    if ([realObject2 respondsToSelector:aSelector]) {
        return realObject2;
    }
    
    return nil;
}
```

输出：

>forwardingTargetForSelector
>
>forwardingTargetForSelector
>
> forwardingTargetForSelector
>
>forwardingTargetForSelector
>
> forwardingTargetForSelector
>
>forwardingTargetForSelector
>
> count should be 1, it is: 1
>
>forwardingTargetForSelector
>
>Appending successful.got: '<TargetProxy: 0x10181cb60>
>
>Example finished without errors.

那么官方为什么要注释掉这个方法，why？？？

> 猜测：在前面消息发送与转发中，如果在这个方法中返回的不是nil或者self，则有可能由于开发者的误操作，一直处于“消息发送->forwardingTargetForSelector：->消息发送 ”的无限循环中。所以官方干脆注释掉，不建议实现，直接进行消息转发的后面两步

如果返回错误的方法签名或者，invokeWithTarget时传入错误的target

```ocaml
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSLog(@"methodSignatureForSelector");
    
    NSObject *obj = [NSObject new];
    NSMethodSignature *sig = [obj methodSignatureForSelector:aSelector];
    return sig;
    
//    NSMethodSignature *sig;
//    sig = [realObject1 methodSignatureForSelector:aSelector];
//    if (sig) return sig;
//    sig = [realObject2 methodSignatureForSelector:aSelector];
//    return sig;
}
//----------------------

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSLog(@"forwardInvocation");
    
    id target = [realObject1 methodSignatureForSelector:[invocation selector]] ? realObject1 : realObject2;
    
    NSObject *obj = [NSObject new];
    [invocation invokeWithTarget:obj];
    
}
```

会直接导致崩溃：

> ***\** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[NSObject appendString:]: unrecognized selector sent to instance 0x100547520'**

这样会提高程序的健壮性。



场景二：利用代理打破引用循环（NSTimer与self的互相强引用）

思路是将self以弱引用的方式传递给proxy，然后将proxy设置为Timer的target，以打破循环引用。

主要代码如下：

```objective-c
@interface ZzProxy : NSProxy
/**
 *  代理的对象
 */
@property (nonatomic,weak)id obj;
@end

@implementation ZzProxy

/**
 这个函数让重载方有机会抛出一个函数的签名，再由后面的forwardInvocation:去执行
    为给定消息提供参数类型信息
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = nil;
    sig = [self.obj methodSignatureForSelector:aSelector];
    return sig;
}

/**
 *  NSInvocation封装了NSMethodSignature，通过invokeWithTarget方法将消息转发给其他对象.这里转发给控制器执行。
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [anInvocation invokeWithTarget:self.obj];
}
@end
```

调用如下：

```objective-c
self.timer = [NSTimer timerWithTimeInterval:1 target:self.proxy selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
```



场景三：借用其他类的方法实现本类没有实现的功能

```objective-c
//返回和参数的类型信息

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{

    NSString *sel = NSStringFromSelector(aSelector);

    if ([sel isEqualToString:@"run"]) {

        return [NSMethodSNSInvocationignature signatureWithObjCTypes:"v@:"];

    }

    return [super methodSignatureForSelector:aSelector];

    //引发NSInvalidArgumentException。在你具体子类中重写这个方法，为被给选择器和你的代理对象代表的类返回合适的NSMethodSignature对象

}

//加载对象，把对象传递给anInvocation

- (void)forwardInvocation:(NSInvocation *)anInvocation{

    SEL selector = [anInvocation selector];

    Car *car = [[Car alloc] init];

    if ([car respondsToSelector:selector]) {

        [anInvocation invokeWithTarget:car];//传递一个invocation给proxy代表的真的对象
    }
}
```













参考：

- [Objectvie-C](http://southpeak.github.io/categories/objectivec/)
- [刨根问底Objective－C Runtime](http://www.cocoachina.com/articles/10740)
- [Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/)