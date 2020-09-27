使用的源码：[libdispatch-84.5.5](https://opensource.apple.com/tarballs/libdispatch/)



先看一个GCD的基本数据结构：

```c
typedef union {
    struct dispatch_object_s *_do;          // dispatch_object_s结构体，这个是 GCD 的基类
    struct dispatch_continuation_s *_dc;    // 任务类型，通常 dispatch_async内的block最终都会封装成这个数据类型
    struct dispatch_queue_s *_dq;           // 任务队列，我们创建的对列都是这个类型的，不管是串行队列还是并发队列
    struct dispatch_queue_attr_s *_dqa;     // 任务队列的属性，任务队列的属性里面包含了任务队列里面的一些操作函数，可以表明这个任务队列是串行还是并发队列
    struct dispatch_group_s *_dg;           // GCD的group
    struct dispatch_source_s *_ds;          // GCD的sourece ，可以监测内核事件，文件读写事件和 socket 通信事件等
    struct dispatch_source_attr_s *_dsa;    // sourece的属性。
    struct dispatch_semaphore_s *_dsema;    // 信号量，如果了解过 pthread 都知道，信号量可以用来调度线程
} dispatch_object_t __attribute__((transparent_union));
```

dispatch_object_t是一个联合体，所以当用dispatch_object_t 可以代表这个联合体内的所有数据类型。

**注意__attribute__((transparent_union))**是一种典型的 **透明联合体**，

透明联合类型削弱了C语言的类型检测机制。起到了类似强制类型转换的效果，通过透明联合体，使得`dispatch_object_s`就像C++中的基类，在函数参数类型的转换上，给C语言的参数传递带来极大的方便。

参考：[C语言共用体（C语言union用法）详解](http://c.biancheng.net/view/2035.html)



#### dispatch_once

dispatch_once如何在多线程情况下保证生成对象的唯一性？

在源码libdispatch/Source/once.c文件中，dispatch_once代码如下：

```c
void
dispatch_once(dispatch_once_t *val, void (^block)(void))
{
	struct Block_basic *bb = (void *)block;

	dispatch_once_f(val, block, (void *)bb->Block_invoke);
}

void
dispatch_once_f(dispatch_once_t *val, void *ctxt, void (*func)(void *))
{
	volatile long *vval = val;

	if (dispatch_atomic_cmpxchg(val, 0l, 1l)) {
		func(ctxt);
		dispatch_atomic_barrier();
		*val = ~0l;
	} else {
		do {
			_dispatch_hardware_pause();
		} while (*vval != ~0l);

		dispatch_atomic_barrier();
	}
}
```

可以看到，在dispatch_once中生成了Block_basic结构体指针，指向block，然后调用了dispatch_once_f函数，而传递的参数依次是：dispatch_once_t类型变量指针、block、Block_basic的Block_invoke函数指针。



dispatch_once_f执行过程如下：

- 将val赋值给long型指针vval，vval的指向的变量值用于else中do-while循环的判断条件

- 宏`dispatch_atomic_cmpxchg`的原型为：`__sync_bool_compare_and_swap((p), (o), (n))`，这是LOCKFree给予CAS的一种原子操作机制，原理是：如果p==o,将p设置为n，然后返回true；否则，不做任何处理返回false

  这里要插入几个关键词的解释：

  - volatile

    > 在现代处理器中，对于一个对齐的×××类型(×××或指针)，其读写操作是原子的，而对于现代编译器，用volatile修饰的基本类型正确对齐的保障，并且限制了编译器对其优化。这样通过对int变量加上volatile修饰，我们就能对该变量进行原子性读写。

  - LOCKFree与CAS

    CAS：Compare-And-Swap

    



- 在多线程环境中，如果某一个线程A首次进入dispatch_once_f，\*val==0,这时原子操作将\*val设为1,然后执行block，然后调用dispatch_atomic_barrier,最后将*val值修改为~0l。

- dispatch_atomic_barrier是一种内存屏障，从处理器角度说用来串行化读写操作，从软件角度说解决顺序一致性问题。只有等屏障前的指令执行完了，才执行屏障后的指令

  > 内存屏障，也称内存栅栏，内存栅障，屏障指令等，是一类同步屏障指令，是CPU或编译器在对内存随机访问的操作中的一个同步点，使得此点之前的所有读写操作都执行后才可以开始执行此点之后的操作。大多数现代计算机为了提高性能而采取乱序执行，这使得内存屏障成为必须。语义上，内存屏障之前的所有写操作都要写入内存；内存屏障之后的读操作都可以获得同步屏障之前的写操作的结果。因此，对于敏感的程序块，写操作之后、读操作之前可以插入内存屏障。

- 在线程A执行block的过程中，如果其他的线程也执行到dispatch_once_f，由于*val==1,这时执行的一定是else分支，于是执行do-while循环，直到首个线程执行完毕，将值修改为~0,调用dispatch_atomic_barrier退出。在执行do-while中，实际上是执行_dispatch_hardware_pause函数，实际上是延迟空等，这有助于提高性能和节省CPU耗电。

- 在A线程执行完毕后，由于*val=~0l，在有其他线程又进入的时候，由于不等于0，执行的也还是else分支。这就保证了dispatch_once_f的block仅执行了一次，对象执行的单例方法生成的实例是唯一的。



##### dispatch_once死锁

> - 死锁方式1：
>   1、某线程T1()调用单例A，且为应用生命周期内首次调用，需要使用dispatch_once(&token, block())初始化单例。
>   2、上述block()中的某个函数调用了dispatch_sync_safe，同步在T2线程执行代码
>   3、T2线程正在执行的某个函数需要调用到单例A，将会再次调用dispatch_once。
>   4、这样T1线程在等block执行完毕，它在等待T2线程执行完毕，而T2线程在等待T1线程的dispatch_once执行完毕，造成了相互等待，故而死锁
> - 死锁方式2：
>   1、某线程T1()调用单例A，且为应用生命周期内首次调用，需要使用dispatch_once(&token, block())初始化单例；
>   2、block中可能掉用到了B流程，B流程又调用了C流程，C流程可能调用到了单例A，将会再次调用dispatch_once；
>   3、这样又造成了相互等待。

所以在使用写单例时要注意：

- 1、初始化要尽量简单，不要太复杂；
- 2、尽量能保持自给自足，减少对别的模块或者类的依赖；
- 3、单例尽量考虑使用场景，不要随意实现单例，否则这些单例一旦初始化就会一直占着资源不能释放，造成大量的资源浪费。



生成单例便利代码见Demo中：`GCD`工程中`Singleton.h`文件。

在类的头文件中插入代码：`singleton_h`

实现文件中插入：`singleton_m`





参考：

1、[GCD源码分析](http://lingyuncxb.com/2018/01/31/GCD源码分析1%20——%20开篇/)

2、[说说无锁(Lock-Free)编程那些事](https://blog.51cto.com/13591395/2344220)

