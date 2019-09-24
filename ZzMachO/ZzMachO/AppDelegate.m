//
//  AppDelegate.m
//  ZzMachO
//
//  Created by 周登杰 on 2019/8/4.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreFoundation/CFRunLoop.h>

@interface AppDelegate()
{
   int timeoutCount;
        CFRunLoopObserverRef runLoopObserver;
        @public
        dispatch_semaphore_t dispatchSemaphore;
        CFRunLoopActivity runLoopActivity;
       
}
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    //监测卡顿
        if (runLoopObserver) {
            return YES;
        }
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

    
     //创建子线程监控
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //子线程开启一个持续的loop用来进行监控
            while (YES) {
                long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 20*NSEC_PER_MSEC));
                
                NSLog(@"semaphoreWait:%ld",semaphoreWait);
                
                if (semaphoreWait != 0) {
                    if (!runLoopObserver) {
                        timeoutCount = 0;
                        dispatchSemaphore = 0;
                        runLoopActivity = 0;
                        return;
                    }
                    //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                    if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting) {
                        //出现三次出结果
                        if (++timeoutCount < 3) {
                            continue;
                        }
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            
                            NSLog(@"monitor trigger");

                            
    //                        [SMCallStack callStackWithType:SMCallStackTypeAll];
                        });
                    } //end activity
                }// end semaphore wait
                timeoutCount = 0;
            }// end while
        });
    
    
CADisplayLink
    
    return YES;
}


static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    AppDelegate *appdelegate = (__bridge AppDelegate *)info;
    appdelegate->runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = appdelegate->dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)addRunLoopObserver{
    //获取当前的CFRunLoopRef
    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
    //创建上下文,用于控制器数据的获取
    CFRunLoopObserverContext context =  {
        0,
        (__bridge void *)(self),//self传递过去
        &CFRetain,
        &CFRelease,
        NULL
    };
    //创建一个监听
    static CFRunLoopObserverRef observer;
    observer = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting, YES, 0, &runLoopObserverCallBack,&context);
    //注册监听
    CFRunLoopAddObserver(runLoopRef, observer, kCFRunLoopCommonModes);
    //销毁
    CFRelease(observer);
}



#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
