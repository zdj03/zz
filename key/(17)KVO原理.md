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



