//
//  WXModuleTest.m
//  Test
//
//  Created by 周登杰 on 2019/9/18.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "WXModuleTest.h"
#import <WeexPluginLoader/WeexPluginLoader.h>

WX_PlUGIN_EXPORT_MODULE(test, WXModuleTest);

@implementation WXModuleTest
@dynamic weexInstance;

- (void)test{
    NSLog(@"test");
}

@end
