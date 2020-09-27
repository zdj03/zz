//
//  AppDelegate.m
//  GCD
//
//  Created by 周登杰 on 2019/10/8.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "AppDelegate.h"
#import "Test.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
  //  Test *test = Test.sharedInstance;
    
    
    
    return YES;
}




- (void)dispatch_group{

        __block NSInteger number = 0;
           NSLog(@"0---number:%d",number);

        dispatch_group_t group = dispatch_group_create();
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        
           //A耗时操作
           dispatch_group_async(group, queue, ^{
               [NSThread sleepForTimeInterval:3];
               NSLog(@"1---number:%d",number);
           });
           
        
        //模拟3次网络请求
        for (int i = 0; i < 3; i++) {
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
        
}


- (void)sendRequestWithCompletion:(void (^)(id response))completion {
    //模拟一个网络请求
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(@1111);
        });
    });
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
