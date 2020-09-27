//
//  main.m
//  ZzMachO
//
//  Created by 周登杰 on 2019/8/4.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


#import <dlfcn.h>

typedef int (*printf_func_pointer) (const char * __restrict, ...);

void dynamic_call_function(){
    
    //动态库路径
    char *dylib_path = "/usr/lib/libSystem.dylib";
    
    //打开动态库
    void *handle = dlopen(dylib_path, RTLD_GLOBAL | RTLD_NOW);
    if (handle == NULL) {
        //打开动态库出错
        fprintf(stderr, "%s\n", dlerror());
    } else {
        
        //获取 printf 地址
        printf_func_pointer printf_func = dlsym(handle, "printf");
        
        //地址获取成功则调用
        if (printf_func) {
            int num = 100;
            printf_func("Hello exchen.net %d\n", num);
            printf_func("printf function address 0x%lx\n", printf_func);
        }
        
        dlclose(handle); //关闭句柄
    }
}


__attribute__((constructor))void beforeMain(){
    NSLog(@"beforeMain");
}

__attribute__((desctructor))void afterMain(){
    NSLog(@"afterMain");
}

int main(int argc, char * argv[]) {
    
   // dynamic_call_function();

    NSLog(@"Main");
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
