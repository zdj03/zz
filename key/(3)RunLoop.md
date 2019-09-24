[CFRunLoopRef源码](https://opensource.apple.com/source/CF/CF-855.17/CFRunLoop.c)

> CFRunLoopRef 是在 CoreFoundation 框架内的，它提供了纯 C 函数的 API，所有这些 API 都是线程安全的。
>
> NSRunLoop 是基于 CFRunLoopRef 的封装，提供了面向对象的 API，但是这些 API 不是线程安全的。

#### RunLoop概念

在一个do-while循环内，RunLoop管理其需要处理的事件和消息，并提供一个入口函数来执行逻辑。让线程在没有消息处理时休眠以避免占用资源、在有消息时立刻被唤醒处理。

结构如下：

```c
struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;			/* locked for accessing mode list */
    __CFPort _wakeUpPort;			// used for CFRunLoopWakeUp 
    Boolean _unused;
    volatile _per_run_data *_perRunData;              // reset for runs of the run loop
    pthread_t _pthread;
    uint32_t _winthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes;
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFTypeRef _counterpart;
};
```

#### RunLoop和线程

RunLoop和线程是一一对应的，其关系保存在一个全局的字典中。RunLoop在线程刚创建时没有创建，是在第一次获取时才创建，销毁发生在线程结束时，只能在线程内容获取其RunLoop(主线程除外)。

#### RunLoop对外接口

在 CoreFoundation 里面关于 RunLoop 有5个类:

CFRunLoopRef
CFRunLoopModeRef
CFRunLoopSourceRef
CFRunLoopTimerRef
CFRunLoopObserverRef

一个RunLoop包含若干个Mode（比如App启动时，Mode是kCFRunLoopDefaultMode，当滚动屏幕时，切换到UITrackingRunLoopMode），每个Mode包含若干个Source/Timer/Observer。如果需要切换Mode，只能退出Loop，重新指定Mode进入主函数。目的是为了分隔开不同组的Source/Timer/Observer ，使其互不影响。

Mode结构如下：

```c
struct __CFRunLoopMode {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;	/* must have the run loop locked before locking this */
    CFStringRef _name;
    Boolean _stopped;
    char _padding[3];
    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
    CFMutableDictionaryRef _portToV1SourceMap;
    __CFPortSet _portSet;
    CFIndex _observerMask;
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    dispatch_source_t _timerSource;
    dispatch_queue_t _queue;
    Boolean _timerFired; // set to true by the source when a timer has fired
    Boolean _dispatchTimerArmed;
#endif
#if USE_MK_TIMER_TOO
    mach_port_t _timerPort;
    Boolean _mkTimerArmed;
#endif
#if DEPLOYMENT_TARGET_WINDOWS
    DWORD _msgQMask;
    void (*_msgPump)(void);
#endif
    uint64_t _timerSoftDeadline; /* TSR */
    uint64_t _timerHardDeadline; /* TSR */
};
```

\_\_CFRunLoop中有个\_\_commonModes：

> 一个 Mode 可以将自己标记为”Common”属性（通过将其 ModeName 添加到 RunLoop 的 “commonModes” 中）。每当 RunLoop 的内容发生变化时，RunLoop 都会自动将 _commonModeItems 里的 Source/Observer/Timer 同步到具有 “Common” 标记的所有Mode里。

比如App启动时，kCFRunLoopDefaultMode和UITrackingRunLoopMode已被标记为commonMode。当创建一个NSTimer加到DefaultMode时，Timer会重复回调，但切换到TrackingRunLoopMode时，Timer不会回调，也不会影响滑动操作。解决方法是将Timer加入到两种Mode，或者加入到RunLoop的commonModeItems(RunLoop会自动将Timer同步到两种Mode中)



**CFRunLoopSourceRef** 是事件产生的地方。Source：Source0 和 Source1。
• Source0 只包含了一个回调（函数指针），它并不能主动触发事件。比如点击屏幕、重新布局等
• Source1 包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。 能主动唤醒 RunLoop 的线程

**CFRunLoopTimerRef** 是基于时间的触发器，它和 NSTimer 是toll-free bridged 的，可以混用。注册对应的时间点，当时间点到时，RunLoop会被唤醒以执行那个回调。

**CFRunLoopObserverRef** 是观察者，每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接受到这个变化

```c
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};
```



注册observer监听RunLoop状态变化：

```objective-c
    //创建一个观察者
       CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
       runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                 kCFRunLoopAllActivities,
                                                 YES,
                                                 0,
                                                 &runLoopObserverCallBack,
                                                 &context);
       //将观察者添加到主线程runloop的common模式下的观察中
       CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);


-----------------------------------
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
   //通过activity即对应的状态
}
```



#### RunLoop原理

源码整理如下（来自.ibireme）

```c
/// 用DefaultMode启动
void CFRunLoopRun(void) {
    CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
}
 
/// 用指定的Mode启动，允许设置RunLoop超时时间
int CFRunLoopRunInMode(CFStringRef modeName, CFTimeInterval seconds, Boolean stopAfterHandle) {
    return CFRunLoopRunSpecific(CFRunLoopGetCurrent(), modeName, seconds, returnAfterSourceHandled);
}
 
/// RunLoop的实现
int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {
    
    /// 首先根据modeName找到对应mode
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
    /// 如果mode里没有source/timer/observer, 直接返回。
    if (__CFRunLoopModeIsEmpty(currentMode)) return;
    
    /// 1. 通知 Observers: RunLoop 即将进入 loop。
    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
    
    /// 内部函数，进入loop
    __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {
        
        Boolean sourceHandledThisLoop = NO;
        int retVal = 0;
        do {
 
            /// 2. 通知 Observers: RunLoop 即将触发 Timer 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
            /// 3. 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            /// 4. RunLoop 触发 Source0 (非port) 回调。
            sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
 
            /// 5. 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
            if (__Source0DidDispatchPortLastTime) {
                Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                if (hasMsg) goto handle_msg;
            }
            
            /// 通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
            if (!sourceHandledThisLoop) {
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
            }
            
            /// 7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            /// • 一个基于 port 的Source 的事件。
            /// • 一个 Timer 到时间了
            /// • RunLoop 自身的超时时间到了
            /// • 被其他什么调用者手动唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
            }
 
            /// 8. 通知 Observers: RunLoop 的线程刚刚被唤醒了。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
            
            /// 收到消息，处理消息。
            handle_msg:
 
            /// 9.1 如果一个 Timer 到时间了，触发这个Timer的回调。
            if (msg_is_timer) {
                __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
            } 
 
            /// 9.2 如果有dispatch到main_queue的block，执行block。
            else if (msg_is_dispatch) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            } 
 
            /// 9.3 如果一个 Source1 (基于port) 发出事件了，处理这个事件
            else {
                CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                if (sourceHandledThisLoop) {
                    mach_msg(reply, MACH_SEND_MSG, reply);
                }
            }
            
            /// 执行加入到Loop的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
 
            if (sourceHandledThisLoop && stopAfterHandle) {
                /// 进入loop时参数说处理完事件就返回。
                retVal = kCFRunLoopRunHandledSource;
            } else if (timeout) {
                /// 超出传入参数标记的超时时间了
                retVal = kCFRunLoopRunTimedOut;
            } else if (__CFRunLoopIsStopped(runloop)) {
                /// 被外部调用者强制停止了
                retVal = kCFRunLoopRunStopped;
            } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                /// source/timer/observer一个都没有了
                retVal = kCFRunLoopRunFinished;
            }
            
            /// 如果没超时，mode里没空，loop也没被停止，那继续loop。
        } while (retVal == 0);
    }
    
    /// 10. 通知 Observers: RunLoop 即将退出。
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}
```



#### Mach消息通信

> 在 Mach 中，所有的东西都是通过自己的对象实现的，进程、线程和虚拟内存都被称为”对象”。和其他架构不同， Mach 的对象间不能直接调用，只能通过消息传递的方式实现对象间的通信。”消息”是 Mach 中最基础的概念，消息在两个端口 (port) 之间传递，这就是 Mach 的 IPC (进程间通信) 的核心。

为了实现消息的发送接收，mach_msg()调用函数mach_msg_trap()，等同于系统调用。当在用户态调用 mach_msg_trap() 时会触发陷阱机制，切换到内核态；内核态中内核实现的 mach_msg() 函数会完成实际的工作。

RunLoop的核心就是mach_msg()，RunLoop调用这个函数去接收消息，如果没有port消息，内核会将线程置于等待状态。



#### App启动时RunLoop状态

打印启动后currentRunLoop如下(经整理)：

```
(lldb) po [NSRunLoop currentRunLoop]
CFRunLoop 
current mode = kCFRunLoopDefaultMode,
common modes = {
	UITrackingRunLoopMode
	kCFRunLoopDefaultMode
}
,
common mode items = {
	<CFRunLoopSource{order = -1, callout = PurpleEventSignalCallback}
	<CFRunLoopSource{order = -2, callout = __handleHIDEventFetcherDrain}
	<CFRunLoopObserver{order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler}
	<CFRunLoopObserver{order = 1999000, callout = _beforeCACommitHandler}
	<CFRunLoopSource{order = -1, callout = __handleEventQueue}
	<CFRunLoopObserver{order = 2000000, callout = _ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv}
	<CFRunLoopObserver{order = 2001000, callout = _afterCACommitHandler}
	<CFRunLoopObserver{order = 0, callout = _UIGestureRecognizerUpdateObserver}
	<CFRunLoopSource{order = 0,callout = FBSSerialQueueRunLoopSourceHandler}
	<CFRunLoopSource{order = -1,callout = PurpleEventCallback}
	<CFRunLoopObserver{order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler}
,
modes = {
	<CFRunLoopMode{name = UITrackingRunLoopMode,
	sources0 = {
	<CFRunLoopSource{order = -1, callout = PurpleEventSignalCallback}
	<CFRunLoopSource{order = -1, callout = __handleEventQueue}
	<CFRunLoopSource{order = -2, callout = __handleHIDEventFetcherDrain}
	<CFRunLoopSource{order = 0,callout = FBSSerialQueueRunLoopSourceHandler}
}
,
	sources1 = {
	<CFRunLoopSource{order = -1,callout = PurpleEventCallback}
}
,
	observers = (
    <CFRunLoopObserver{order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler},
    <CFRunLoopObserver{order = 0, callout = _UIGestureRecognizerUpdateObserver},
    <CFRunLoopObserver{order = 1999000, callout = _beforeCACommitHandler},
    <CFRunLoopObserver{order = 2000000, callout = _ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv},
    <CFRunLoopObserver{order = 2001000, callout = _afterCACommitHandler},
    <CFRunLoopObserver{order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler}
),
	timers = (null),
},

	<CFRunLoopMode{name = GSEventReceiveRunLoopMode
	sources0 ={
		<CFRunLoopSource{order = -1,callout = PurpleEventSignalCallback}
}
,
	sources1 ={
		<CFRunLoopSource{order = -1,callout = PurpleEventCallback}
}
,
	observers = (null),
	timers = (null),
},

	<CFRunLoopMode{name = kCFRunLoopDefaultMode
	sources0 {
  	<CFRunLoopSource{order = -1,callout = PurpleEventSignalCallback}
		<CFRunLoopSource{order = -1,callout = __handleEventQueue}
		<CFRunLoopSource{order = -2,callout = __handleHIDEventFetcherDrain}
		<CFRunLoopSource{order = 0,callout = FBSSerialQueueRunLoopSourceHandler}
}
,
	sources1 ={
		<CFRunLoopSource{order = -1,callout = PurpleEventCallback}
}
,
	observers = (
    "<CFRunLoopObserver{order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler}",
    "<CFRunLoopObserver{order = 0, callout = _UIGestureRecognizerUpdateObserver}",
    "<CFRunLoopObserver{order = 1999000, callout = _beforeCACommitHandler (0x7fff46ca67a8)}",
    "<CFRunLoopObserver{order = 2000000, callout = _ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv}",
    "<CFRunLoopObserver{order = 2001000, callout = _afterCACommitHandler}",
    "<CFRunLoopObserver{order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler}"
),
	timers ={
	0 : <CFRunLoopTimer{callout = (Delayed Perform) UIApplication _accessibilitySetUpQuickSpeak},
}
```

系统默认注册了5个Mode:
1. kCFRunLoopDefaultMode: App的默认 Mode，通常主线程是在这个 Mode 下运行的。
2. UITrackingRunLoopMode: 界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响。
3. UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用。
4.  GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到。
5.  kCFRunLoopCommonModes: 这是一个占位的 Mode，没有实际作用。

这里我们能看到其中的三个：kCFRunLoopDefaultMode、UITrackingRunLoopMode、GSEventReceiveRunLoopMode



#### RunLoop与事件响应

苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为 __IOHIDEventSystemClientQueueCallback()。

当一个硬件事件发生后，首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收。SpringBoard 只接收按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的App进程。随后苹果注册的那个 Source1 就会触发__IOHIDEventSystemClientQueueCallback()回调，Source1内部触发Source0回调_UIApplicationHandleEventQueue() ，进行应用内部的分发。

_UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。

#### RunLoop与手势识别

当 _UIApplicationHandleEventQueue() 识别了一个手势时，其首先会调用 Cancel 将当前的 touchesBegin/Move/End 系列回调打断。随后系统将对应的 UIGestureRecognizer 标记为待处理。

苹果注册了一个 Observer （在kCFRunLoopDefaultMode、UITrackingRunLoopMode两种Mode下都有注册）监测 BeforeWaiting (Loop即将进入休眠) 事件，这个Observer的回调函数是 _UIGestureRecognizerUpdateObserver()，其内部会获取所有刚被标记为待处理的 GestureRecognizer，并执行GestureRecognizer的回调。

当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理。



**事件响应与手势识别会另外详细讲解**

#### RunLoop与界面更新

当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。

苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件，回调去执行一个很长的函数：
_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()。这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。

#### RunLoop与定时器

NSTimer 其实就是 CFRunLoopTimerRef，他们之间是 toll-free bridged 的。一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件RunLoop为了节省资源，并不会在非常准确的时间点回调这个Timer。Timer 有个属性叫做 Tolerance (宽容度)，标示了当时间点到后，容许有多少最大误差。

如果某个时间点被错过了，例如执行了一个很长的任务，则那个时间点的回调也会跳过去，不会延后执行。

CADisplayLink 是一个和屏幕刷新率一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去（和 NSTimer 相似），造成界面卡顿的感觉。在快速滑动TableView时，即使一帧的卡顿也会让用户有所察觉。Facebook 开源的 AsyncDisplayLink 就是为了解决界面卡顿的问题，其内部也用到了 RunLoop。



#### PerformSelector

当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。

当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效。



#### GCD

实际上 RunLoop 底层也会用到 GCD 的东西，~~比如 RunLoop 是用 dispatch_source_t 实现的 Timer~~（评论中有人提醒，NSTimer 是用了 XNU 内核的 mk_timer，我也仔细调试了一下，发现 NSTimer 确实是由 mk_timer 驱动，而非 GCD 驱动的）。但同时 GCD 提供的某些接口也用到了 RunLoop， 例如 dispatch_async()。

当调用 dispatch_async(dispatch_get_main_queue(), block) 时，libDispatch 会向主线程的 RunLoop 发送消息，RunLoop会被唤醒，并从消息中取得这个 block，并在回调 \_\_CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__() 里执行这个 block。但这个逻辑仅限于 dispatch 到主线程，dispatch 到其他线程仍然是由 libDispatch 处理的。

#### NSURLConnection

通常使用 NSURLConnection 时，会传入一个 Delegate，当调用了 [connection start] 后，这个 Delegate 就会不停收到事件回调。实际上，start 这个函数的内部会会获取 CurrentRunLoop，然后在其中的 DefaultMode 添加了4个 Source0 (即需要手动触发的Source)。CFMultiplexerSource 是负责各种 Delegate 回调的，CFHTTPCookieStorage 是处理各种 Cookie 的。

当开始网络传输时，我们可以看到 NSURLConnection 创建了两个新线程：com.apple.NSURLConnectionLoader 和 com.apple.CFSocket.private。其中 CFSocket 线程是处理底层 socket 连接的。NSURLConnectionLoader 这个线程内部会使用 RunLoop 来接收底层 socket 的事件，并通过之前添加的 Source0 通知到上层的 Delegate。

![NSURLConnection](/System/Volumes/Data/Users/zhoudengjie/文档/zz/pics/NSURLConnection.png)

NSURLConnectionLoader 中的 RunLoop 通过一些基于 mach port 的 Source 接收来自底层 CFSocket 的通知。当收到通知后，其会在合适的时机向 CFMultiplexerSource 等 Source0 发送通知，同时唤醒 Delegate 线程的 RunLoop 来让其处理这些通知。CFMultiplexerSource 会在 Delegate 线程的 RunLoop 对 Delegate 执行实际的回调。



#### 利用RunLoop监测卡顿

原理：如果RunLoop在进入休眠前（kCFRunLoopBeforeSources）和被唤醒后（kCFRunLoopAfterWaiting）两种状态被阻塞（在一定时间内状态没有变化），可以认为线程被阻塞了。

创建observer监听RunLoop状态：

```
 dispatchSemaphore = dispatch_semaphore_create(0); //Dispatch Semaphore保证同步

 //创建一个观察者
       CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
       runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                 kCFRunLoopAllActivities,
                                                 YES,
                                                 0,
                                                 &runLoopObserverCallBack,
                                                 &context);
       //将观察者添加到主线程runloop的common模式下的观察中
       CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
       
       
       
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    AppDelegate *appdelegate = (__bridge AppDelegate *)info;
    appdelegate->runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = appdelegate->dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
    }
```



开启子线程监控主线程RunLoop:

```
// 创建子线程监控
dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 子线程开启一个持续的 loop 用来进行监控
    while (YES) {
        long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
        if (semaphoreWait != 0) {
            if (!runLoopObserver) {
                timeoutCount = 0;
                dispatchSemaphore = 0;
                runLoopActivity = 0;
                return;
            }
            //BeforeSources 和 AfterWaiting 这两个状态能够检测到是否卡顿
            if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting) {
                // 将堆栈信息上报服务器的代码放到这里
            } 
        }
        timeoutCount = 0;
    }
});
```



#### NSThread 与RunLoop

在Weex的WXBridgeManager类中，创建了两个子线程：

```objective-c
static NSThread *WXBridgeThread;
static NSThread *WXBackupBridgeThread;
```

用来执行block：

```objective-c

+ (void)_performBlockOnBackupBridgeThread:(void (^)(void))block instance:(NSString*)instanceId
{
    if ([NSThread currentThread] == [self backupJsThread]) {
        block();
    } else {
        [self performSelector:@selector(_performBlockOnBridgeThread:instance:)
                     onThread:[self backupJsThread]
                   withObject:[block copy]
                waitUntilDone:NO];
    }
}

+ (void)_performBlockOnBridgeThread:(void (^)(void))block instance:(NSString*)instanceId
{
    if ([NSThread currentThread] == [self jsThread] || [NSThread currentThread] == [self backupJsThread]) {
        block();
    } else {
        WXSDKInstance* instance = nil;
        if (instanceId) {
            instance = [WXSDKManager instanceForID:instanceId];
        }

        if (instance && instance.useBackupJsThread) {
            [self performSelector:@selector(_performBlockOnBridgeThread:instance:)
                             onThread:[self backupJsThread]
                           withObject:[block copy]
                        waitUntilDone:NO];
        } else {
            [self performSelector:@selector(_performBlockOnBridgeThread:instance:)
                             onThread:[self jsThread]
                           withObject:[block copy]
                        waitUntilDone:NO];
        }
    }
}
```



这两个方法接受外部传进来的block，并传到对应的子线程执行。子线程的创建如下：

```objective-c

- (void)_runLoopThread
{
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (!_stopRunning) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

+ (NSThread *)jsThread
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WXBridgeThread = [[NSThread alloc] initWithTarget:[[self class]sharedManager] selector:@selector(_runLoopThread) object:nil];
        [WXBridgeThread setName:WX_BRIDGE_THREAD_NAME];
        if(WX_SYS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [WXBridgeThread setQualityOfService:[[NSThread mainThread] qualityOfService]];
        } else {
            [WXBridgeThread setThreadPriority:[[NSThread mainThread] threadPriority]];
        }
        
        [WXBridgeThread start];
    });
    
    return WXBridgeThread;
}

+ (NSThread *)backupJsThread
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WXBackupBridgeThread = [[NSThread alloc] initWithTarget:[[self class]sharedManager] selector:@selector(_runLoopThread) object:nil];
        [WXBackupBridgeThread setName:WX_BACKUP_BRIDGE_THREAD_NAME];
        if(WX_SYS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [WXBackupBridgeThread setQualityOfService:[[NSThread mainThread] qualityOfService]];
        } else {
            [WXBackupBridgeThread setThreadPriority:[[NSThread mainThread] threadPriority]];
        }

        [WXBackupBridgeThread start];
    });

    return WXBackupBridgeThread;
}
```

子线程创建时传入的SEL：_runLoopThread方法里，获取了NSRunLoop(创建了runloop)，并传入了一个Source：NSMachPort的实例（如果NSRunLoop的Mode里没有Source/Timer/Observer，会自动退出），然后手动将runLoop run起来（注意设置的日期是[NSDate distantFuture]），以`达到维护线程生命周期的目的`，除非外部使之停止（\_stopRunning）。



其他用法：

- 创建常驻线程：

```objective-c
@autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
}
```

- 在一定时间内监听某种事件

  在30min内，每隔30s执行onTimerFired：

  ```objective-c
  @autoreleasepool {
      NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
      NSTimer * udpateTimer = [NSTimer timerWithTimeInterval:30
                                                      target:self
                                                    selector:@selector(onTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
      [runLoop addTimer:udpateTimer forMode:NSRunLoopCommonModes];
      [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:60*30]];
  }
  ```

AFNetwroking中的RunLoop

```objective-c
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"AFNetworking"];

        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
         // 这里主要是监听某个 port，目的是让RunLoop不会退出，确保该 Thread 不会被回收
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode]; 
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread =
        [[NSThread alloc] initWithTarget:self
                                selector:@selector(networkRequestThreadEntryPoint:)
                                  object:nil];
        [_networkRequestThread start];
    });
    return _networkRequestThread;
}
```





### CADisplayLink

CADisplayLink 的selector是在屏幕内容刷新完成的时候调用。实质上是向RunLoop注册了一个Source0事件。





参考：

1、[深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)

2、[SpringBoard.app](http://iphonedevwiki.net/index.php/SpringBoard.app)