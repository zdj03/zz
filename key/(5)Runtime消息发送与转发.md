####1、objc_msgSend

一个对象的方法像这样[obj foo]，会被编译器转化成消息发送

```objective-c
id objc_msgSend(id self, SEL op, ...);
```

这是一个可变参数函数。第二个参数类型是SEL，SEL在OC中是selector方法选择器。

```objective-c
typedef struct objc_selector *SEL;
```

objc_selector是一个映射到方法的C字符串。需要注意的是@selector()选择子只与函数名有关。不同类中相同名字的方法所对应的方法选择器是相同的，即使方法名字相同而变量类型不同也会导致它们具有相同的方法选择器。由于这点特性，导致OC不支持函数重载。

objc_msgSend处理消息分为：发送消息、消息转发两个阶段；

1、消息发送阶段：

- 检测这个selector是不是要忽略的，如在ARC中retain、release会被忽略
- 检查target是不是为nil

如果这里有相应的nil的处理函数就跳转到相应的函数中。如果没有处理nil的函数，就自动清理现场并返回。这一点就是为何在OC中给nil发送消息不会崩溃的原因。

- 通过obj的isa找到它的class；

- 在class的objc_cache中查找，如果没有找到，就进行下一步；

- 在class的method_list中找到foo；

- 如果找到就执行并缓存；如果class中没有找到foo，继续往它的superclass中的缓存和方法列表中找；

- 一旦找到foo这个函数，就去执行它的实现IMP（如果是在方法列表中找到的，则缓存）

- 一直到NSObject还没找到，就进行消息转发(因为NSObject的父类为nil)

  2、动态方法解析过程如下：

- 动态方法解析：Runtime调用类的实例方法+resolveInstanceMethod:或者类方法+resolveClassMethod:，让你有机会提供一个函数实现。如果添加函数并返回YES，Runtime就会重新启动一次消息发送的过程；

  3、方法转发：

- 如果返回NO，就会继续执行下一步：forwardingTargetForSelector:，Runtime这时就会调用此方法，把消息转发给其他对象；

- 如果还不能处理消息，那么就启动完整的消息转发机制。

- 首先会发送-methodSignatureForSelector:消息获得函数的参数和返回类型

- 如果上一步返回nil，Runtime会发出-doesNotRecognizeSelector:消息，程序会崩溃

- 如果返回一个函数签名，Runtime就会创建一个NSInvocation对象，就发送-forwardInvocation:消息给目标对象

- 实现此方法后，若发现某调用不应由本类处理，则会调用超类的同名方法。如此，继承体系中的每个类都有机会处理该方法调用的请求，一直到NSObject根类。如果NSObject也不能处理该条消息，那么就只能抛出doesNotRecognizeSelector:，程序会崩溃

整个消息转发过程如下图：

![消息转发](/Users/zhoudengjie/文档/awesome/pics/method Forwarding.png)



demo:

```objective-c

@interface NSObject(Sark)
+(void)foo;
@end
@implementation NSObject(Sark)
- (void)foo{
    NSLog(@"IMP: -[NSObject(Sark) foo]");
}
@end	
```

```objective-c
 int main(int argc, const char * argv[]) {
  @autoreleasepool {
      [NSObject foo];
      [[NSObject new] foo];
}
return 0;
}
```

输出结果：

```objective-c
@"IMP: -[NSObject(Sark) foo]"
@"IMP: -[NSObject(Sark) foo]"
```

OC在初始化的时候，会去加载map_images，map_images最终会调用objc-runtime-new.mm里面的_read_images方法。_read_images方法里面会去初始化内存中的map, 这个时候将会load所有的类，协议还有Category。NSObject的+load方法就是这个时候调用的。

加载完所有的category之后，就开始处理这些类别。大体思路还是分为2类来分开处理。

第一类是实例方法，添加到类的方法列表里

第二类是类方法，添加到metaClass的方法列表

处理完之后的结果
1)、把category的实例方法、协议以及属性添加到类上
2)、把category的类方法和协议添加到类的metaclass上

这两种情况里面的处理方式都差不多，先去调用addUnattachedCategoryForClass函数，申请内存，分配空间。remethodizeClass这个方法里面会调用attachCategories方法。

attachCategories方法代码就不贴了，有兴趣的可以自己去看看。这个方法里面会用头插法，把新加的方法从头插入方法链表中。并且最后还会flushCaches。

这也就是为什么我们可以在Category里面覆盖原有的方法的原因，因为头插法，新的方法在链表的前面，会优先被遍历到。

以上就是Category加载时候的流程。

再回到这道题目上面来，在加载NSObject的Category中，在编译期会提示我们没有实现+(void)foo的方法，因为在.m文件中并没有找到+方法的实现。

但是在实际加载Category的时候，会把-(void)foo加载进去，由于是实例方法，所以会放在NSObject的实例方法链表里面。

根据第二章分析的objc_msgSend源码实现，我们可以知道：

在调用[NSObject foo]的时候，会先在NSObject的meta-class中去查找foo方法的IMP，未找到，继续在superClass中去查找，NSObject的meta-class的superClass就是本身NSObject，于是又回到NSObject的类方法中查找foo方法，于是乎找到了，执行foo方法，输出：

```objective-c
IMP: -[NSObject(Sark) foo]
```

在调用[[NSObject new] foo]的时候，会先生成一个NSObject的实例，用这个NSObject实例再去调用foo方法的时候，会去NSObject的类方法里面去查找，找到，于是也会输出

```objective-c
IMP: -[NSObject(Sark) foo]	
```



####2、objc_msgSendSuper



#### 实例 

实例1：

```objective-c
@interface Father:NSObject
@end
@implementation Father
@end

@interface Son : Father
@end
@implementation Son

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@",NSStringFromClass([self class]));
        NSLog(@"%@",NSStringFromClass([super class]));
    }
    return self;
}
```

打印结果：

> 2019-06-01 14:00:17.302575+0800 Awesome[23547:4609268] Son
>
> 2019-06-01 14:00:35.047430+0800 Awesome[23547:4609268] Son

self和super的区别：

> self是类的一个隐藏参数，每个方法的实现的第一个参数即是self。
>
> super却不是隐藏参数，实际上只是一个编译器标识符，告诉编译器，当调用方法时，去调用父类的方法，而不是本类的方法。

[self class]是向当前类Son发送class消息，即objc_msgSend，沿着继承体系往上找到NSObject的类方法class，获取到当前类Son。

[super class]不是向类Father发送class消息，而是调用objc_msgSendSuper，该函数的定义如下：

```objective-c
objc_msgSendSuper(struct objc_super * _Nonnull super, SEL _Nonnull op, ...)
```

可以看到，传入的参数是objc_super的结构体，而不是父类。

objc_super结构体定义如下：

```objective-c
struct objc_super {
    /// Specifies an instance of a class.
    __unsafe_unretained _Nonnull id receiver;

    /// Specifies the particular superclass of the instance to message. 
#if !defined(__cplusplus)  &&  !__OBJC2__
    /* For compatibility with old objc-runtime.h header */
    __unsafe_unretained _Nonnull Class class;
#else
    __unsafe_unretained _Nonnull Class super_class;
#endif
    /* super_class is the first class to search */
};
```

结构体里变量分别表示：接收消息的receiver和当前类的父类super_class(在此即是Father)。

那么，该函数的工作原理是：

从objc_super结构体指向的superClass父类的方法列表里开始查找selector，找到以后objc-receiver去调用selector。注意最后的调用者是objc-receiver，而不是super_class.





参考：

1、[消息发送与转发](https://halfrost.com/objc_runtime_objc_msgsend/)

