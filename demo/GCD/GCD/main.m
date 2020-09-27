//
//  main.m
//  GCD
//
//  Created by 周登杰 on 2019/10/8.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        
       
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
