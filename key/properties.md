原子性: atomic(默认)，nonatomic。atomic读写线程安全，但效率低，而且不是绝对的安全，比如如果修饰的是数组，那么对数组的读写是安全的，但如果是操作数组进行添加移除其中对象的还，就不保证安全了。

**atomic的原子性和nonatomic的非原子性**

- atomic ：系统自动生成的getter/setter方法会进行加锁操作；可以理解过读写锁，可以保证读写安全；较耗时；
- nonatomic : 系统自动生成的getter/setter方法不会进行加锁操作；但速度会更快；\

下面是两个nonatomic和atomic修饰的变量，我们用代码掩饰其内部实现；

```javascript
@property (nonatomic) UIImage *nonImage;
@property (atomic) UIImage *atomicImage;

//nonatomic的setter和getter实现：
- (void)setNonImage:(UIImage *)nonImage
{
    _nonImage = nonImage;
}
- (UIImage *)nonImage
{
    return _nonImage;
}
//atomic的setter和getter实现：
- (void)setAtomicImage:(UIImage *)atomicImage
{
    @synchronized (self) {
        _atomicImage = atomicImage;
    }
}
- (UIImage *)atomicImage
{
    @synchronized (self) {
        return _atomicImage;
    }
}
```

**源代码分析atomic为什么不是线程安全**

其实现在一想很奇怪，为什么要把atomic和线程安全联系在一起去探究；atomic只是对属性的getter/setter方法进行了加锁操作，这种安全仅仅是get/set的读写安全，仅此之一，但是线程安全还有除了读写的其他操作,比如：当一个线程正在get/set时，另一个线程同时进行release操作，可能会直接crash。很明显atomic的读写锁不能保证线程安全。 下面两个例子写的就挺好，挺简单：

eg1：如果定义属性NSInteger i是原子的，对i进行i = i + 1操作就是不安全的； 因为原子性只能保证读写安全，而该表达式需要三步操作： 1、读取i的值存入寄存器； 2、将i加1； 3、修改i的值； 如果在第一步完成的时候，i被其他线程修改了，那么表达式执行的结果就与预期的不一样，也就是不安全的 eg2:

```javascript
    self.slice = 0;
    dispatch_queue_t queue = dispatch_queue_create("TestQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i=0; i<10000; i++) {
            self.slice = self.slice + 1;
        }
    });
    dispatch_async(queue, ^{
        for (int i=0; i<10000; i++) {
            self.slice = self.slice + 1;
        }
    });
```

结果可能是[10000,20000]之间的某个值，而我们想要的结果是20000；很明显这个例子就会引起线程隐患，而atomic并不能防止这个问题；所以我们说atomic不是线程安全； *所以要想真正理解atomic的非线程安全性，必须要去官网查找解释并通过源码分析才行；*在runtime时property的atomic是一个booleau值，是采用spinlock_t锁去实现的；

```javascript
id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic) {
    if (offset == 0) {
        return object_getClass(self);
    }

    // Retain release world
    id *slot = (id*) ((char*)self + offset);
    if (!atomic) return *slot;
        
    // Atomic retain release world
    spinlock_t& slotlock = PropertyLocks[slot];
    slotlock.lock();
    id value = objc_retain(*slot);
    slotlock.unlock();
    
    // for performance, we (safely) issue the autorelease OUTSIDE of the spinlock.
    return objc_autoreleaseReturnValue(value);
}
static inline void reallySetProperty(id self, SEL _cmd, id newValue, ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy)
{
    if (offset == 0) {
        object_setClass(self, newValue);
        return;
    }

    id oldValue;
    id *slot = (id*) ((char*)self + offset);

    if (copy) {
        newValue = [newValue copyWithZone:nil];
    } else if (mutableCopy) {
        newValue = [newValue mutableCopyWithZone:nil];
    } else {
        if (*slot == newValue) return;
        newValue = objc_retain(newValue);
    }

    if (!atomic) {
        oldValue = *slot;
        *slot = newValue;
    } else {
        spinlock_t& slotlock = PropertyLocks[slot];
        slotlock.lock();
        oldValue = *slot;
        *slot = newValue;        
        slotlock.unlock();
    }

    objc_release(oldValue);
}
```

很明显atomic属性的setter/getter方法都被加了spinlock自旋锁，需要注意的是spinlock已经由于存在优先级反转问题被弃用并用os_unfair_lock替代。既然被弃用了，这里为什么还在用；原因是进入spinlock去看会发现，底层已经被os_unfair_lick替换：

```javascript
using spinlock_t = mutex_tt<LOCKDEBUG>;
class mutex_tt : nocopy_t {
    os_unfair_lock mLock;
 public:
    constexpr mutex_tt() : mLock(OS_UNFAIR_LOCK_INIT) {
        lockdebug_remember_mutex(this);
    }

    constexpr mutex_tt(const fork_unsafe_lock_t unsafe) : mLock(OS_UNFAIR_LOCK_INIT) { }

    void lock() {
        lockdebug_mutex_lock(this);

        os_unfair_lock_lock_with_options_inline
        .
        .
        .
```

.引用计数：

- retain/strong
- assign：修饰基本数据类型，修饰对象类型时，不改变其引用计数，会产生悬垂指针，修饰的对象在被释放后，assign指针仍然指向原对象内存地址，如果使用assign指针继续访问原对象的话，就可能会导致内存泄漏或程序异常
- weak：不改变被修饰对象的引用计数，所指对象在被释放后，weak指针会自动置为nil
- copy：分为深拷贝和浅拷贝
  浅拷贝：对内存地址的复制，让目标对象指针和原对象指向同一片内存空间会增加引用计数
  深拷贝：对对象内容的复制，开辟新的内存空间

