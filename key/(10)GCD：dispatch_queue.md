#### dispatch_queue

1、定义：

```objective-c
struct dispatch_queue_s {
    DISPATCH_STRUCT_HEADER(dispatch_queue_s, dispatch_queue_vtable_s);
    DISPATCH_QUEUE_HEADER;
    char dq_label[DISPATCH_QUEUE_MIN_LABEL_SIZE];   // must be last
};
```

2、获取队列的方式

- 1、主队列：

  ```objective-c
  #define dispatch_get_main_queue() (&_dispatch_main_q)
  ```

  实际上是获取到结构体`_dispatch_main_q`的地址

  ```c
  struct dispatch_queue_s _dispatch_main_q = {
      .do_vtable = &_dispatch_queue_vtable,
      .do_ref_cnt = DISPATCH_OBJECT_GLOBAL_REFCNT,
      .do_xref_cnt = DISPATCH_OBJECT_GLOBAL_REFCNT,
      .do_suspend_cnt = DISPATCH_OBJECT_SUSPEND_LOCK,
      .do_targetq = &_dispatch_root_queues[DISPATCH_ROOT_QUEUE_COUNT / 2],
  
      .dq_label = "com.apple.main-thread",
      .dq_running = 1,
      .dq_width = 1,
      .dq_serialnum = 1,
  };
  ```

  主队列的内部引用计数和外部引用计数都是DISPATCH_OBJECT_GLOBAL_REFCNT，即：

  ```c
  #define DISPATCH_OBJECT_GLOBAL_REFCNT   (~0u)
  ```

  GCD对象的内存管理方法如下：

  ```c
  void _dispatch_retain(dispatch_object_t dou)
  {
      if (dou._do->do_ref_cnt == DISPATCH_OBJECT_GLOBAL_REFCNT) {
          return; // global object
      }
      ...
  }
  
  void dispatch_release(dispatch_object_t dou)
  {
      typeof(dou._do->do_xref_cnt) oldval;
  
      if (dou._do->do_xref_cnt == DISPATCH_OBJECT_GLOBAL_REFCNT) {
          return;
      }
      ...
  ```

  可见：在App的生命周期内，主队列的引用计数是常数`DISPATCH_OBJECT_GLOBAL_REFCNT`，它的retain和release方法不对引用计数产生影响，是伴随着App的生命周期的。

- 2、管理队列

  `_dispatch_mgr_q`，GCD内部使用，不对外公开

- 3、全局队列

  `dispatch_get_get_global_queue`

  定义：

  ```c
  enum {
      DISPATCH_QUEUE_PRIORITY_HIGH = 2,
      DISPATCH_QUEUE_PRIORITY_DEFAULT = 0,
      DISPATCH_QUEUE_PRIORITY_LOW = -2,
  };
  
  dispatch_queue_t dispatch_get_global_queue(long priority, unsigned long flags)
  {
      if (flags & ~DISPATCH_QUEUE_OVERCOMMIT) {
          return NULL;
      }
      return _dispatch_get_root_queue(priority, flags & DISPATCH_QUEUE_OVERCOMMIT);
  }
  
  static inline dispatch_queue_t _dispatch_get_root_queue(long priority, bool overcommit)
  {
      if (overcommit) switch (priority) {
      case DISPATCH_QUEUE_PRIORITY_LOW:
          return &_dispatch_root_queues[1];
      case DISPATCH_QUEUE_PRIORITY_DEFAULT:
          return &_dispatch_root_queues[3];
      case DISPATCH_QUEUE_PRIORITY_HIGH:
          return &_dispatch_root_queues[5];
      }
      switch (priority) {
      case DISPATCH_QUEUE_PRIORITY_LOW:
          return &_dispatch_root_queues[0];
      case DISPATCH_QUEUE_PRIORITY_DEFAULT:
          return &_dispatch_root_queues[2];
      case DISPATCH_QUEUE_PRIORITY_HIGH:
          return &_dispatch_root_queues[4];
      default:
          return NULL;
      }
  }
  ```

  这一版本源码定义了6个全局队列（最新版本有8个）

  伪代码如下（队列名：dq_label）

  ```c
  static struct dispatch_queue_s _dispatch_root_queues[] = {
          .dq_label = "com.apple.root.low-priority"
          .dq_label = "com.apple.root.low-overcommit-priority"
      .dq_label = "com.apple.root.default-priority"
       .dq_label = "com.apple.root.default-overcommit-priority"
       .dq_label = "com.apple.root.high-priority"
       .dq_label = "com.apple.root.high-overcommit-priority"
  };
  ```

  它们的dq_width都是`UINT32_MAX`

  函数dispatch_get_global_queue是根据priority（优先级）和flags来从dispatch_queue_s结构体数组_dispatch_root_queues里取出对应的队列。

- 3、自定义队列

  一般像下面自顶一个一个队列：

  ```
  //并发队列
  dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("com.exemple.gcd.MyConcurrentDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
  
  //串行队列
      dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("com.exemple.gcd.MyConcurrentDispatchQueue", DISPATCH_QUEUE_SERIAL);
  或者：
      dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("com.exemple.gcd.MyConcurrentDispatchQueue", NULL);
  ```

  函数定义如下：

  ```c
  dispatch_queue_t dispatch_queue_create(const char *label, dispatch_queue_attr_t attr) {
    /*
    1、队列名字预处理
    2、申请队列内存
    3、设置队列的基本属性	  	 
    _dispatch_queue_init(dq);
    
    4、设置队列名字
    5、
    if(slowpath(attr)){
    5.1、获取一个全局队列并设置为队列的目标队列，有两个参数，分别表示优先级和是否支持overcommit:
    带有overcommit的队列表示每当有任务提交时，系统会新开一个线程处理，避免某个线程过载
    dq->do_targetq = _dispatch_get_root_queue(attr->qa_priority, attr->qa_flags & DISPATCH_QUEUE_OVERCOMMIT);
    5.2、设置dq_finalizer_ctxt
    5.3、设置dq_finalizer_func
    
    6、Block处理
    如果finalizer_ctxt是一个Block,需要retain
    }
    */
  } 
  ```

  函数`_dispatch_queue_init`中将dq_width设置为1，说明默认设置此队列为串行队列，不同于全局队列的`UINT32_MAX`.

  这里解释GCD队列与block模型：target-queue

  >想任何队列中提交的block，都会被放到它的目标队列中执行，而普通串行队列的目标队列就是一个支持overcommit的全局队列，全局队列的底层则是一个线程池。

  如下图：

  ![gcd_thread_pool](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/gcd_thread pool.png)



####dispatch_sync

同步任务处理函数，定义：

```c
void dispatch_sync(dispatch_queue_t dq, void (^work)(void))
{
#if DISPATCH_COCOA_COMPAT
    if (slowpath(dq == &_dispatch_main_q)) {
        return _dispatch_sync_slow(dq, work);
    }
#endif
    struct Block_basic *bb = (void *)work;
    dispatch_sync_f(dq, work, (dispatch_function_t)bb->Block_invoke);
}
```

- 如果是主队列，调用_dispatch_sync_slow，而从源码看，最终还是调用函数`dispatch_sync_f`
- 非主队列，调用dispatch_sync_f

函数dispatch_sync_f主要做了几件事：

```
1、如果是串行队列，调用函数dispatch_barrier_sync_f
2、如果是并发队列
2.1、如果并发队列中存在其他任务或者队列被挂起，则调用函数_dispatch_sync_f_slow，等待队列中的其他任务完成(实现方式为信号量)，然后执行这个任务
2.2、如果队列为空，没有正在执行的任务，调用函数_dispatch_wakeup唤醒队列
2.3、如果队列为空，但是有任务正在执行，调用函数_dispatch_sync_f_slow
```

而函数dispatch_barrier_sync_f主要处理：

```
1、判断队列中是否还有其他任务、队列是否被挂起、队列是否能加锁，如果有一项成立，则调用函数_dispath_barrier_sync_f_slow
2、如果都不成立，则直接执行block
```

函数函数_dispatch_sync_f_slow：

```
如果队列的目标队列不为空，向队列中压入内容，等待信号，
```

函数_dispatch_wakeup，唤醒队列：

```
1、如果队列被挂起，直接返回NULL
2、如果传入的是全局队列，唤醒全局队列（dx_probe指向的函数_dispatch_queue_wakeup_global），如果失败且队尾指针为空，直接返回NULL
3、如果传入的是主队列，则调用函数_dispatch_queue_wakeup_main唤醒主队列
```

唤醒主队列函数：_dispatch_queue_wakeup_main

```
1、利用dispatch_once_f函数(单例的实现其实也是调用此函数)，保证只初始化一次
2、唤醒主线程_dispatch_send_wakeup_main_thread，

\**由RunLoop的原理可以猜测：是向主线程的RunLoop传入一个Source1，唤醒睡眠的RunLoop\**
```

唤醒全局队列函数：_dispatch_queue_wakeup_global

```
1、全局队列检测，初始化和配置环境(使用dispatch_once_f)
	此处注意和主队列初始化的不同：
	全局队列：dispatch_once_f(&pred, NULL, _dispatch_root_queues_init);
	主队列：dispatch_once_f(&_dispatch_main_q_port_pred, NULL, _dispatch_main_q_port_init);
	
2、如果队列的dgq_kworkqueue不为空，则调用pthread_workqueue_additem_np函数，该函数使用workq_kernreturn系统调用，通知workqueue增加应当执行的项目。根据该通知，XNU内核基于系统状态判断是否要生成线程，如果是overcommit优先级的队列，workqueue则始终生成线程，之后线程执行_dispatch_worker_thread2函数

3、如果dgq_kworkdqueue不存在
3.1、发送一个信号量，用于线程保活
3.2、检测线程池可用的大小，如果可用，则减一
3.3、如果线程池不可用，则调用pthread_create函数创建一个线程，线程入口是_dispatch_worker_thread，这个函数调用_dispatch_worker_thread2函数，和第2条一样
```

函数\_dispatch_worker_thread

```
1、设置线程的信号掩码
2、调度任务_dispatch_worker_thread2
3、等待信号量(唤醒全局队列第三步中3.1发送的信号量)，设置的时间是65秒
***
唤醒全局队列中3.3中，如果线程池不可用，则创建线程。这里等待信号量，是为了避免频繁创建线程，节省系统资源。
如果65秒内接收到新的信号量(表示有新的任务)，这个线程就会去继续执行加进来的任务，而不是重新开启新线程，65秒后没接收到信号量，则退出这个线程，销毁这个线程
***
```

函数\_dispatch_worker_thread2实际是真正用来调度任务的

此函数里用来任务调度的关键函数是：

- 取出列队里的一个内容（之所以说是内容，而不是任务，是因为传入的可能是任务（block封装的dispatch_continuation_t结构体）或者队列）\_dispatch_queue_concurrent_drain_one()
- 处理内容（如果是任务，则执行任务）\_dispatch_continuation_pop()





#### dispatch_async

定义：

```c
void dispatch_async(dispatch_queue_t dq, void (^work)(void))
{
    dispatch_async_f(dq, _dispatch_Block_copy(work), _dispatch_call_block_and_release);
}
```

- \_dispatch_Blokc_copy在堆上创建传入block的拷贝，或者增加引用计数，这样就保证了block不会被提前销毁掉
- _dispatch_call_block_and_release：执行block，然后销毁



函数dispatch_async_f：

```
1、调用函数_dispatch_continuation_alloc_cacheonly从线程的TLS(线程的私有存储，线程都有自己的私有存储，不会被其他线程所使用)中提取一个dispatch_continuation_t，如果不存在失败，调用_dispatch_async_f_slow函数
2、如果提取成功，设置dc的do_vtable、dc_ctxt、dc_func，进行入队操作
```

函数_dispatch_async_f_slow：

```
从堆上初始化一个dispatch_continuation_t，和前面一页，设置结构体的成员，入队
```

入队函数：

```c
#define _dispatch_queue_push(x, y) _dispatch_queue_push_list((x), (y), (y))
```



函数_dispatch_queue_push_list((x), (y), (y))：

```c
static inline void
_dispatch_queue_push_list(dispatch_queue_t dq, dispatch_object_t _head, dispatch_object_t _tail)
```

是一个内联inline函数，对于调用很频繁的函数，可以设置为inline函数

> inline通常在内核中，效率很高，但生成的二进制文件变大，空间换时间

- 如归队列不为空，直接把dc当道队尾并重定向dq->dq_items_tail
- 如果队列为空，则调用\_dispatch_queue_push_list_slow函数



函数\_dispatch_queue_push_list_slow

```
将dq->dq_items_head设置为obj，然后调用_dispatch_wakeup走唤醒队列流程
```

\_dispatch_wakeup在前面dispatch_sync中已分析。