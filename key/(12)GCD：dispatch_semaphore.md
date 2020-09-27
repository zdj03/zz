`dispatch_semaphore_s`是性能稍次于自旋锁的的信号量对象，用来保证资源使用的安全性。

semaphore.h中api仅三个

```
创建一个初始值为value的信号量
dispatch_semaphore_t
dispatch_semaphore_create(long value);

等待一个信号量，将信号量的值减1
long
dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);

发出一个信号量，将信号量的值加1
long
dispatch_semaphore_signal(dispatch_semaphore_t dsema);
```

一般调用步骤：

- 创建一个信号量
- 等待此信号量的发出，执行任务
- 发出一个信号量



定义：

```c
struct dispatch_semaphore_s {
    DISPATCH_STRUCT_HEADER(dispatch_semaphore_s, dispatch_semaphore_vtable_s);
    long dsema_value;   // 当前信号值，当这个值小于0时无法访问加锁资源
    long dsema_orig;    // 初始化信号值，限制了同时访问资源的线程数量
    
    size_t dsema_sent_ksignals; //由于mach信号可能会被意外唤醒，通过原子操作来避免虚假信号
    
    semaphore_t dsema_port;
    semaphore_t dsema_waiter_port;
    size_t dsema_group_waiters;
    struct dispatch_sema_notify_s *dsema_notify_head;
    struct dispatch_sema_notify_s *dsema_notify_tail;
};
```

- semaphore_t是mach_port_t信号

  ```c
  typedef mach_port_t semaphore_t;
  ```

- dispatch_sema_notify_s定义：

  ```c
  struct dispatch_sema_notify_s {
      struct dispatch_sema_notify_s *dsn_next;
      dispatch_queue_t dsn_queue;
      void *dsn_ctxt;
      void (*dsn_func)(void *);
  };
  ```

  是一个链表结构，信号量中包含链表头和链表尾部



####创建信号量

```c
dispatch_semaphore_t
dispatch_semaphore_create(long value)
{
	dispatch_semaphore_t dsema;
	
	// If the internal value is negative, then the absolute of the value is
	// equal to the number of waiting threads. Therefore it is bogus to
	// initialize the semaphore with a negative value.
	if (value < 0) {
		return NULL;
	}
	
	dsema = calloc(1, sizeof(struct dispatch_semaphore_s));
	
	if (fastpath(dsema)) {
		dsema->do_vtable = &_dispatch_semaphore_vtable;
		dsema->do_next = DISPATCH_OBJECT_LISTLESS;
		dsema->do_ref_cnt = 1;
		dsema->do_xref_cnt = 1;
		dsema->do_targetq = dispatch_get_global_queue(0, 0);
		dsema->dsema_value = value;
		dsema->dsema_orig = value;
	}
	
	return dsema;
}
```

- value必须不小于0

- 分配一块dispatch_semaphore_s结构体所占大小的内存

- 设置do_vtable，_dispatch_semaphore_vtable定义如下：

  ```c
  const struct dispatch_semaphore_vtable_s _dispatch_semaphore_vtable = {
  	.do_type = DISPATCH_SEMAPHORE_TYPE,//类型
  	.do_kind = "semaphore",
  	.do_dispose = _dispatch_semaphore_dispose,//销毁函数
  	.do_debug = _dispatch_semaphore_debug,//调试函数
  };
  ```

- 设置链表结尾标记

- 设置内部和外部引用计数为1

- 设置目标队列为全局队列

- 设置信号值和初始值为1

销毁函数_dispatch_semaphore_dispose，是调用内核函数销毁信号量



#### 等待信号

```c
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout){
    
        // 如果信号量的值-1之后大于等于0,表示有资源可用
    if (dispatch_atomic_dec(&dsema->dsema_value) >= 0) {
        return 0;
    }
    return _dispatch_semaphore_wait_slow(dsema, timeout);
}
```

- 如果信号值减1后仍大于0，则表示成功，返回0

- 否则调用_dispatch_semaphore_wait_slow函数，

  该函数中判断三种情况：

  - DISPATCH_TIME_NOW：检测后立即返回，不等待，如果信号值小于0，则加1，返回超时信号

  - DISPATCH_TIME_FOREVER：无限等待，直到信号值大于0，重新执行本函数流程

    ```
    /* 没有超时的代码 */
    kr = semaphore_wait(dsema->dsema_port);
    ```

  - 即使等待，直到有信号到来或者超时

    ```
    /* 有超时的代码 */
    kr = slowpath(semaphore_timedwait(dsema->dsema_port, _timeout));
    ```

####发送信号

```c
ISPATCH_NOINLINE long dispatch_semaphore_signal(dispatch_semaphore_t dsema){
    if (dispatch_atomic_inc(&dsema->dsema_value) > 0) {
        return 0;
    }
    return _dispatch_semaphore_signal_slow(dsema);
}
```

- 原子增加1之前的值，大于0则直接返回0。
- 否则调用函数_dispatch_semaphore_signal_slow



函数_dispatch_semaphore_signal_slow，

利用心态的信号量库实现发送信号量的功能，唤醒dispatch_semaphore_wait_slow中等待的线程。如果有多个线程在等待，则根据线程的优先级来判断唤醒哪个。



​		





dispatch_semaphore也可以拿来实现锁的功能