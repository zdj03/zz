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
    CFRunLoopObserverRef runLoopObserver;
       
}
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    
    
    //创建一个观察者
//       CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
//       runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
//                                                 kCFRunLoopAllActivities,
//                                                 YES,
//                                                 0,
//                                                 &runLoopObserverCallBack,
//                                                 &context);
//       //将观察者添加到主线程runloop的common模式下的观察中
//       CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);

    
    return YES;
}


static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    
    switch (activity) {
    case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
        break;
        case kCFRunLoopBeforeTimers:
                    NSLog(@"kCFRunLoopBeforeTimers");
                break;
        case kCFRunLoopBeforeSources:
                    NSLog(@"kCFRunLoopBeforeSources");
                break;
        case kCFRunLoopBeforeWaiting:
                    NSLog(@"kCFRunLoopBeforeWaiting");
                break;
        case kCFRunLoopAfterWaiting:
                    NSLog(@"kCFRunLoopAfterWaiting");
                break;
        case kCFRunLoopExit:
                    NSLog(@"kCFRunLoopExit");
                break;
        case kCFRunLoopAllActivities:
                    NSLog(@"kCFRunLoopAllActivities");
                break;
    default:
        break;
    }
    
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
