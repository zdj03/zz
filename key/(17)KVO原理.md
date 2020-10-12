> KVO是为了监听一个对象的某个属性值是否发生变化。当属性值发生变化的时候，肯定会调用其setter方法。所以KVO的本质就是监听对象有没有调用被监听属性对应的setter方法。具体实现应该是重写其setter方法即可。

**KVO用到的技术—Isa Swizzling**

在@interface NSObject(NSKeyValueObserverRegistration)分类里，苹果定义了KVO的方法。

```objective-c
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;	
```

KVO 在调用addObserver方法之后，苹果的做法是在执行完addObserver:forKeyPath:options:context:之后，把isa指向到另外一个类去。

从以下代码可以发现：官方是如何实现重写监听类的setter方法的

```objective-c
Student *stu = [[Student alloc] init];
[stu addObServer:self forKeyPath:@"name" options:NSKeyValueObServingOptionsNew context:nil];
```

打印观察isa指针的指向：

```objective-c
2019-06-15 18:42:00.884035+0800 Awesome[7011:531929] sark->isa:Sark
2019-06-15 18:42:00.884250+0800 Awesome[7011:531929] sark class:Sark
2019-06-15 18:42:03.200507+0800 Awesome[7011:531929] ClassMethodNames = (
    speak,
    ".cxx_destruct",
    name,
    "setName:"
)
2019-06-15 18:42:03.201133+0800 Awesome[7011:531929] sark->isa:NSKVONotifying_Sark
2019-06-15 18:42:03.201497+0800 Awesome[7011:531929] sark class:Sark
2019-06-15 18:42:04.468779+0800 Awesome[7011:531929] ClassMethodNames = (
    "setName:",
    class,
    dealloc,
    "_isKVOA"
)
```

可以很明显的看到，被观察的对象的isa变了，变成了NSKVONotifying_Sark这个类了。

从这里可以看出object_getClass与class方法发区别：

```objective-c
- (Class)class{
    return object_getClass(self);
}

Class object_getClass(id obj){
    if(obj) return obj->getIsa();
    else return Nil;
}
```





在这个新类里面重写被观察的对象的4个方法：class、setter、dealloc、_isVKOA.

- 重写class方法是为了我们调用它的时候返回跟重写继承类之前同样的类容。

- 重写setter方法，是为了在set方法中增加另外两个方法的调用：

  ```objective-c
  - (void)willChangeValueForKey:(NSString *)key;
  - (void)didChangeValueForKey:(NSString *)key;
  ```

  在didChangeValueForKey:方法再调用

  ```objective-c
  - (void)observerValueForKeyPath:(NSString *)keyPath
  						ofObject:(id)object
  						change:(NSDictionary *)change
  						context:(void *)context;
  ```

  这里有几种情况需要说明一下：

  - 如果使用了KVC

    - 如果有访问器方法，则运行时会在setter方法中调用will/didChangeValueForKey:方法
    - 如果没有访问器方法，运行时会在setValue:forKey方法中调用will/didChangeValueForKey:方法

    所以这种情况下，KVO是奏效的

  - 有访问器方法

    - 运行时会重写访问器方法调用will/didChangeValueForKey:方法

    因此，直接调用访问器方法改变属性值时，KVO也能监听到

  - 直接调用will/didChangeValueForKey:方法

  综上所述，只要setter中重写will/didChangeValueForKey:方法就可以使用KVO了

- 重写dealloc方法

  销毁新生成的NSKVONotifying_类

- 重写_isKVOA方法

  这个私有方法估计可能是用来标识该类是一个KVO机制声明的类





Foundation提供了大部分基础数据类型的辅助函数（Objective C中的Boolean只是unsigned char的typedef,所以包括了，但没有C++中的bool），此外还包括一些常见的结构体如Point、Range、Rect、Size，这表明这些结构体也可以用于自动键值观察，但要注意除此之外的结构体就不能用于自动键值观察了。对于所有Objective C对象对应的是_NSSetObjectValueAndNotify方法。





KVC(Key-value coding)

-(id)valueForKey:(NSString *)key;

-(void)setValue:(id)value forKey:(NSString *)key;
KVC就是指iOS的开发中，可以允许开发者通过Key名直接访问对象的属性，或者给对象的属性赋值。而不需要调用明确的存取方法。这样就可以在运行时动态地访问和修改对象的属性。而不是在编译时确定，这也是iOS开发中的黑魔法之一。很多高级的iOS开发技巧都是基于KVC实现的

当调用setValue：属性值 forKey：@”name“的代码时，，底层的执行机制如下：

程序优先调用set<Key>:属性值方法，代码通过setter方法完成设置。注意，这里的<key>是指成员变量名，首字母大小写要符合KVC的命名规则，下同
如果没有找到setName：方法，KVC机制会检查+ (BOOL)accessInstanceVariablesDirectly方法有没有返回YES，默认该方法会返回YES，如果你重写了该方法让其返回NO的话，那么在这一步KVC会执行setValue：forUndefinedKey：方法，不过一般开发者不会这么做。所以KVC机制会搜索该类里面有没有名为<key>的成员变量，无论该变量是在类接口处定义，还是在类实现处定义，也无论用了什么样的访问修饰符，只在存在以<key>命名的变量，KVC都可以对该成员变量赋值。
如果该类即没有set<key>：方法，也没有_<key>成员变量，KVC机制会搜索_is<Key>的成员变量。
和上面一样，如果该类即没有set<Key>：方法，也没有_<key>和_is<Key>成员变量，KVC机制再会继续搜索<key>和is<Key>的成员变量。再给它们赋值。
如果上面列出的方法或者成员变量都不存在，系统将会执行该对象的setValue：forUndefinedKey：方法，默认是抛出异常。
即如果没有找到Set<Key>方法的话，会按照_key，_iskey，key，iskey的顺序搜索成员并进行赋值操作。

如果开发者想让这个类禁用KVC，那么重写+ (BOOL)accessInstanceVariablesDirectly方法让其返回NO即可，这样的话如果KVC没有找到set<Key>:属性名时，会直接用setValue：forUndefinedKey：方法。

当调用valueForKey：@”name“的代码时，KVC对key的搜索方式不同于setValue：属性值 forKey：@”name“，其搜索方式如下：

首先按get<Key>,<key>,is<Key>的顺序方法查找getter方法，找到的话会直接调用。如果是BOOL或者Int等值类型， 会将其包装成一个NSNumber对象。
如果上面的getter没有找到，KVC则会查找countOf<Key>,objectIn<Key>AtIndex或<Key>AtIndexes格式的方法。如果countOf<Key>方法和另外两个方法中的一个被找到，那么就会返回一个可以响应NSArray所有方法的代理集合(它是NSKeyValueArray，是NSArray的子类)，调用这个代理集合的方法，或者说给这个代理集合发送属于NSArray的方法，就会以countOf<Key>,objectIn<Key>AtIndex或<Key>AtIndexes这几个方法组合的形式调用。还有一个可选的get<Key>:range:方法。所以你想重新定义KVC的一些功能，你可以添加这些方法，需要注意的是你的方法名要符合KVC的标准命名方法，包括方法签名。
如果上面的方法没有找到，那么会同时查找countOf<Key>，enumeratorOf<Key>,memberOf<Key>格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所的方法的代理集合，和上面一样，给这个代理集合发NSSet的消息，就会以countOf<Key>，enumeratorOf<Key>,memberOf<Key>组合的形式调用。
如果还没有找到，再检查类方法+ (BOOL)accessInstanceVariablesDirectly,如果返回YES(默认行为)，那么和先前的设值一样，会按_<key>,_is<Key>,<key>,is<Key>的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱。如果重写了类方法+ (BOOL)accessInstanceVariablesDirectly返回NO的话，那么会直接调用valueForUndefinedKey:方法，默认是抛出异常。


