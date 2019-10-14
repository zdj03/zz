> dispatch_source是BSD系统内核功能kqueue的包装，可以监视某些类型事件的发生。当这些事件发生时，自动将block放入dispatch queue的执行历程中。

>IO多路复用
>定义：同时监控多个IO事件，当哪个IO事件准备就绪就执行哪个IO事件。
>以此形成可以同时操作多个IO的并发行为，从而避免一个IO阻塞，造成所有IO都无法执行
>
>IO事件准备就绪：是一种IO必然要发生的临界状态。
>
>IO多路复用的编程实现
>1.将IO设置为关注IO（注册IO）
>2.将关注IO提交给内核监测
>3.处理内核给我们反馈的准备就绪的IO
>
>具体实现方案： 3种
>1.select ----->windows linux unix（苹果内核）
>2.poll ----->linux unix
>3.epoll ----->linux unix

dispatch支持的事件类型：

```
DISPATCH_SOURCE_TYPE_DATA_ADD：      自定义事件
DISPATCH_SOURCE_TYPE_DATA_OR：       自定义事件
DISPATCH_SOURCE_TYPE_MACH_SEND：     Mach端口发送事件。
DISPATCH_SOURCE_TYPE_MACH_RECV：     Mach端口接收事件。
DISPATCH_SOURCE_TYPE_PROC：          进程相关的事件。
DISPATCH_SOURCE_TYPE_READ：          读文件事件。
DISPATCH_SOURCE_TYPE_WRITE：         写文件事件。
DISPATCH_SOURCE_TYPE_VNODE：         文件属性更改事件。
DISPATCH_SOURCE_TYPE_SIGNAL：        接收信号事件。
DISPATCH_SOURCE_TYPE_TIMER：         定时器事件。
DISPATCH_SOURCE_TYPE_MEMORYPRESSURE：内存压力事件。
```

使用方式：

```c
// 1、创建dispatch源，这里使用加法来合并dispatch源数据，最后一个参数是指定dispatch队列
dispatch_source_t source = dispatch_source_create(dispatch_source_type, handler, mask, dispatch_queue);

// 2、设置响应dispatch源事件的block，在dispatch源指定的队列上运行
dispatch_source_set_event_handler(source, ^{ 
　　//可以通过dispatch_source_get_data(source)来得到dispatch源数据
});

// 3、dispatch源创建后处于suspend状态，所以需要启动dispatch源
dispatch_resume(source);

// 4、合并dispatch源数据
dispatch_source_merge_data(source, value);
```

####定时器

```
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
dispatch_source_set_event_handler(timer, ^{
    NSLog(@"timer");
});
dispatch_resume(timer);
```

注意：timer如果是局部变量，在代码块执行完之后，timer会被释放掉，block不会被执行到



NSTimer、CADisplayLink是和RunLoop关联的，如果runloop执行了耗时操作或者睡眠时间较长而没有被唤醒的话，会导致二者的精度不准。而dispatch_source的timer事件类型，是使用内核的事件源，比前者更加准确。



####监视文件

```c
dispatch_source_t fileMonitor(const char* filename) 
{ 
    int fd = open(filename, O_EVTONLY); 
    if (fd == -1) return NULL; 

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0); 
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_RENAME, queue); 
    
    // 保存原文件名
    int length = strlen(filename); 
    char* newString = (char*)malloc(length + 1); 
    newString = strcpy(newString, filename); 
    dispatch_set_context(source, newString); 

    // 设置事件发生的回调
    dispatch_source_set_event_handler(source, ^{ 
        // 获取原文件名
        const char*  oldFilename = (char*)dispatch_get_context(source); 
        
        // 文件名变化逻辑处理
        ... 
    }); 

    // 设置取消回调 
    dispatch_source_set_cancel_handler(source, ^{ 
        char* fileStr = (char*)dispatch_get_context(source); 
        free(fileStr); 
        close(fd); 
    }); 

    // 启动
    dispatch_resume(source); 

   return source; 
}
```

