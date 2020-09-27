#### Category使用场景

- 把类的实现代码组织到不同的文件，好处：
  - 减少单个文件的体积
  - 把不同的功能组织到不同的category里
  - 可以由多个开发者共同完成一个类
  - 按需加载category
- 声明私有方法
- 模拟多继承
- 把framework的私有方法公开



#### category和extension

extension在编译器决议，它是类的一部分，随类一起产生消亡。extension一般用来隐藏类的私有信息，你必须有一个类的源码才能为一个类添加extension，所以无法为系统的类添加extension，比如NSString。

category是在运行期决议的，extension可以添加实例变量，而category无法做到，因为在运行期，对象的内存布局已经确定，如果添加成员变量就会破坏类的内存布局，这对编译型语言是灾难的。

#### category定义

定义：

```c
typedef struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
} category_t;
```

结构体包含：

- 名字
- 类
- 添加的实例方法
- 添加的类方法
- 实现的协议
- 添加的所有属性



被编译器编译后（使用命令clang -rewrite-objc MyClass.m）生成c++源码文件，可以看到)、首先编译器生成了实例方法列表*OBJC*$\_CATEGORY\_INSTANCE\_METHODSMyClass$\_MyAddition和属性列表*OBJC*$\_PROP\_LISTMyClass$\_MyAddition，两者的命名都遵循了公共前缀+类名+category名字的命名方式，而且实例方法列表里面填充的正是我们在MyAddition这个category里面写的方法printName，而属性列表里面填充的也正是我们在MyAddition里添加的name属性。还有一个需要注意到的事实就是category的名字用来给各种列表以及后面的category结构体本身命名，而且有static来修饰，所以在同一个编译单元里我们的category名不能重复，否则会出现编译错误。

2)、其次，编译器生成了category本身*OBJC*\_CATEGORY*MyClass*$\_MyAddition，并用前面生成的列表来初始化category本身。

3)、最后，编译器在**DATA段下的**objc_catlist section里保存了一个大小为1的category_t的数组L_OBJC_LABEL*CATEGORY*$（当然，如果有多个category，会生成对应长度的数组），用于运行期category的加载。



#### category加载

category被附加到类上面是在map_images的时候发生的，\_objc\_init里面调用map_images最终会调用objc_runtime_new.mm里面的\_read_images方法，主要做了几件事：

- 把category的实例方法、协议、属性添加到类上
- 把category的类方法、协议添加到类的metaclass上

注意：

- category的方法没有完全替换掉原来类的已经有的方法，如果类原来也有相同的方法，那么类的方法列表里会有多个相同的方法

- category的方法被放到了新方法列表的前面，而原来类的方法被放到了后面，这也就造成了“category的方法会覆盖掉来的方法”的现象，其实是运行时在查找方法的时候是顺着方法列表查找，第一次查找到就返回
- 但是对于类的多个category，则是找到最后一个编译的category的对应的方法



#### 调用类中被category覆盖掉的类实例方法

根据上面category的方法的驾照原理，可知，在类的方法列表里找到最后一个对应名字的方法，即可。



#### category和关联对象

在（6）Runtime与NSObject中讲解了使用关联对象的方法间接在category中添加实例变量（实际上不是真的添加成员变量），提到几种内存管理策略。

所有的关联对象都由AssociationsManager管理，AssociationsManager里面是一个静态的AssociationsHashMap来存储所有的关联对象，即把所有对象的关联对象存储在一个全局map。而map的key是这个对象的指针地址，value是另一个AssociationsHashMap（保存了关联对象的kv对）。

```objective-c
class AssociationsManager {
    static OSSpinLock _lock;
    static AssociationsHashMap *_map;               // associative references:  object pointer -> PtrPtrHashMap.
public:
    AssociationsManager()   { OSSpinLockLock(&_lock); }
    ~AssociationsManager()  { OSSpinLockUnlock(&_lock); }
    
    AssociationsHashMap &associations() {
        if (_map == NULL)
            _map = new AssociationsHashMap();
        return *_map;
    }
};
```

在对象的销毁逻辑里（objc_runtime-new.mm）

```objective-c
void *objc_destructInstance(id obj) 
{
    if (obj) {
        Class isa_gen = _object_getClass(obj);
        class_t *isa = newcls(isa_gen);

        // Read all of the flags at once for performance.
        bool cxx = hasCxxStructors(isa);
        bool assoc = !UseGC && _class_instancesHaveAssociatedObjects(isa_gen);

        // This order is important.
        if (cxx) object_cxxDestruct(obj);
        if (assoc) _object_remove_assocations(obj);
        
        if (!UseGC) objc_clear_deallocating(obj);
    }

    return obj;
}
```

runtime在销毁对象函数objc_destructInstance里面会判断这个对象有没有关联对象，如果有，会调用\_object_remove_associations做关联对象的清理工作(根据设置的内存管理策略)





参考：

- https://tech.meituan.com/2015/03/03/diveintocategory.html