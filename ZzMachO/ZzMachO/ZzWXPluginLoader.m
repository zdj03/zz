//
//  ZzWXPluginLoader.m
//  ZzMachO
//
//  Created by 周登杰 on 2019/9/22.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ZzWXPluginLoader.h"
#import <WeexSDK/WeexSDK.h>
#import <SDWebImageManager.h>
#include <mach-o/loader.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>

const struct mach_header *machHeader = NULL;
static NSString *configuration = @"";

@implementation ZzWXPluginLoader

+ (void)load{
    
    [self registerPlugins];
    
}

+ (void)registerPlugins {
    
    NSArray<NSString *> *plugins =  [self readConfigFromSectionName:@"WeexPlugin"];
    
    for (NSString *plugin in plugins) {
        NSArray *cmps = [plugin componentsSeparatedByString:@"&"];
        NSString *seperator = cmps[0];
        NSString *jsname = cmps[1];
        NSString *classname = cmps[2];
        
        if ([seperator isEqualToString:@"module"]) {
            Class clz = NSClassFromString(classname);
            if (clz) {
                NSLog(@"register module:%@ with jsname:%@",classname,jsname);
                [WXSDKEngine registerModule:jsname withClass:clz];
            }
        } else if ([seperator isEqualToString:@"component"]) {
            Class clz = NSClassFromString(classname);
            if (clz) {
                NSLog(@"register component:%@ with jsname:%@",classname,jsname);
                [WXSDKEngine registerComponent:jsname withClass:clz];
            }
        } else if ([seperator isEqualToString:@"protocol"]) {
            Class clz = NSClassFromString(jsname);
            Protocol *protocol = NSProtocolFromString(classname);
            if ([[clz new] conformsToProtocol:protocol]) {
                NSLog(@"register protocol:%@ with jsimpl:%@",classname,jsname);
                [WXSDKEngine registerHandler:[clz new] withProtocol:protocol];

            }
        } else {
            
        }
    }
    
}



+ (NSArray<NSString *> *)readConfigFromSectionName:(NSString *)sectionName
{
    NSMutableArray *configs = [NSMutableArray array];
    if (sectionName.length)
    {
        if (machHeader == NULL)
        {
            //获取mach_headers信息
            Dl_info info;
            dladdr((__bridge const void *)(configuration), &info);
            machHeader = (struct mach_header*)info.dli_fbase;
        }
        unsigned long size = 0;
        //取得该section的数据
        uintptr_t *memory = (uintptr_t*)getsectiondata(machHeader, SEG_DATA, [sectionName UTF8String], & size);
        //获取该section每条信息
        NSUInteger counter = size/sizeof(void*);
        NSError *converError = nil;
        for(int idx = 0; idx < counter; ++idx){
            char *string = (char*)memory[idx];
            
            NSString *str = [NSString stringWithUTF8String:string];
            
            if (str || str.length > 0)
            {
                [configs addObject:str];
            }
        }
    }
    return configs;
}


@end
