dispatch_group的使用方式：

```objective-c
__block NSInteger number = 0;
       NSLog(@"0---number:%d",number);

    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
       //A耗时操作
       dispatch_group_async(group, queue, ^{
           [NSThread sleepForTimeInterval:3];
           NSLog(@"1---number:%d",++number);
       });
       
    
    //模拟3次网络请求
    for (int i = 0; i < 10; i++) {
         dispatch_group_enter(group);
              [self sendRequestWithCompletion:^(id response) {
                  number += [response integerValue];
                  NSLog(@"%d---number:%d",i+2,number);
                  dispatch_group_leave(group);
              }];
    }
    
//    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
//    NSLog(@"999999---number:%d",number);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"999999---number:%d",number);
        NSLog(@"currentThread:%@",[NSThread currentThread]);
    });

/*-----------模拟网络请求--------------*/
- (void)sendRequestWithCompletion:(void (^)(id response))completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(@1111);
        });
    });
}
```

输出：

>**2019-10-10 15:08:18.525501+0800 GCD[50477:2258834] 0---number:0**
>
>**2019-10-10 15:08:18.568487+0800 GCD[50477:2258834] viewDidLoad**
>
>**2019-10-10 15:08:20.529747+0800 GCD[50477:2258834] 2---number:1111**
>
>**2019-10-10 15:08:20.530945+0800 GCD[50477:2258834] 3---number:2222**
>
>**2019-10-10 15:08:20.531332+0800 GCD[50477:2258834] 4---number:3333**
>
>**2019-10-10 15:08:21.527915+0800 GCD[50477:2258945] 1---number:3333**
>
>**2019-10-10 15:08:21.528283+0800 GCD[50477:2258834] 999999---number:3333**
>
>**2019-10-10 15:08:21.528580+0800 GCD[50477:2258834] currentThread:<NSThread: 0x6000005f13c0>{number = 1, name = main}**

如果用wait函数替代notify函数，输出结果为：

>**2019-10-10 15:04:56.276238+0800 GCD[50420:2255978] 0---number:0**
>
>**2019-10-10 15:04:59.277169+0800 GCD[50420:2256063] 1---number:0**
>
>**2019-10-10 15:05:06.277469+0800 GCD[50420:2255978] 999999---number:0**
>
>**2019-10-10 15:05:06.317043+0800 GCD[50420:2255978] viewDidLoad**
>
>**2019-10-10 15:05:06.330274+0800 GCD[50420:2255978] 2---number:1111**
>
>**2019-10-10 15:05:06.330434+0800 GCD[50420:2255978] 3---number:2222**
>
>**2019-10-10 15:05:06.330548+0800 GCD[50420:2255978] 4---number:3333**

注意：

- 此处不管是wait还是notify，二者的block都是在主线程执行的。
- 使用notify，notify里的block一定是在group里任务全都执行完了之后才执行的，至于在哪个线程执行，是要看此函数的queue参数传入的是哪个queue
- 使用wait，可以看到viewDidLoad在wait后的任务之后才执行，可知阻塞了当前线程（主线程），而notify不会。





> dispatch_group是基于dispatch_semaphore实现的。dispatch_group的源码也是在semaphore.c中



#### dispatch_group_create

```c
dispatch_group_t
dispatch_group_create(void)
{
	return (dispatch_group_t)dispatch_semaphore_create(LONG_MAX);
}
```

可见，dispatch_group_t其实是一个初始值为`LONG_MAX`的信号量**（注意区分信号量和信号）**



#### dispatch_group_async

实际是封装了dispatch_group_async_f函数

```c
void
dispatch_group_async_f(dispatch_group_t dg, dispatch_queue_t dq, void *ctxt, void (*func)(void *))
{
	dispatch_continuation_t dc;

	_dispatch_retain(dg);
	dispatch_group_enter(dg);

	dc = _dispatch_continuation_alloc_cacheonly() ?: _dispatch_continuation_alloc_from_heap();

	dc->do_vtable = (void *)(DISPATCH_OBJ_ASYNC_BIT|DISPATCH_OBJ_GROUP_BIT);
	dc->dc_func = func;
	dc->dc_ctxt = ctxt;
	dc->dc_group = dg;

	_dispatch_queue_push(dq, dc);
}
```

- retain增加引用计数

- enter，其实就是等待信号量。enter和leave是成对出现，那么leave函数是在那里调用的呢？

  前面分析dispatch_async中的任务调度函数之一：_dispatch_continuation_pop中，有段代码：

  ```
  if ((long)dou._do->do_vtable & DISPATCH_OBJ_GROUP_BIT) {
  		dg = dc->dc_group;
  	} else {
  		dg = NULL;
  	}
  	dc->dc_func(dc->dc_ctxt);
  	if (dg) {
  		dispatch_group_leave(dg);
  		_dispatch_release(dg);
  	}
  ```

  在任务执行完之后，判断dg是否是group，是的话，调用leave，并且释放dg。

- 从线程的私有存储获取dispatch_continuation_t，失败的话，就从堆上重新初始化一个

- 入队

注意比较：前面dispatch_queue中dispatch_async函数中调用的dispatch_async_f



#### dispatch_group_enter和dispatch_group_leave

```c
void
dispatch_group_enter(dispatch_group_t dg)
{
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;

    (void)dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
}

void
dispatch_group_leave(dispatch_group_t dg)
{
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;
    dispatch_atomic_release_barrier();
    long value = dispatch_atomic_inc2o(dsema, dsema_value);//dsema_value原子性加1
    if (slowpath(value == LONG_MIN)) {//内存溢出，由于dispatch_group_leave在dispatch_group_enter之前调用
        DISPATCH_CLIENT_CRASH("Unbalanced call to dispatch_group_leave()");
    }
    if (slowpath(value == dsema->dsema_orig)) {//表示所有任务已经完成，唤醒group
        (void)_dispatch_group_wake(dsema);
    }
}
```

前面有提到，enter函数实际上是在等待信号量的到来，信号量会原子减1，而leave是将信号量原子加1。。如果信号量的值与初始值相等，表示所有任务已完成，则唤醒group。唤醒group核心其实是_dispatch_async_f函数，用来进行任务调度的，此函数在前面dispatch_async中以解析过.

dispatch_group_wake:

- 通过semaphore_signal唤醒信号量
- 依次调用dispatch_async_f



此处需要注意enter和leave如果不是成对的使用的情况：

- 如调用enter而不调用leave，因为信号量的值不等于初始值，则group不会被唤醒，那么notify函数中的任务不会被执行。
- 如果多调用了leave，那么value=LONG_MAX+1，发送数据长度溢出，变成LONG_MIN,程序会崩溃。



#### dispatch_group_notify

实际上是对dispatch_group_notify_f的封装

用链表将回调通知保存起来，等待调用。如果任务已完成，唤醒group：dispatch_group_wake



#### dispatch_group_wait

等待group中的任务完成

- 如果所有任务已完成，直接返回0

- 如果超时，返回超时

- 其他情况，调用\_dispatch_group_wait_slow

  等待信号量，唤醒group