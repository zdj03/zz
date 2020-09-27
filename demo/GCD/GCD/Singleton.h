//
//  Singleton.h
//  GCD
//
//  Created by 周登杰 on 2019/10/8.
//  Copyright © 2019 zdj. All rights reserved.
//

#ifndef Singleton_h
#define Singleton_h

#import <Foundation/Foundation.h>

#ifdef __has_feature(objc_arc)

#define singleton_h +(instancetype)sharedInstance;
#define singleton_m \
static id _instanceType = nil;\
\
+(instancetype)sharedInstance\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instanceType = [[self alloc] init];\
    });\
    return _instanceType;\
}\
\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instanceType = [[self alloc]init];\
    });\
    return _instanceType;\
}\
\
-(id)copyWithZone:(NSZone *)zone\
{\
    return _instanceType;\
}\

#else

#define singleton_h +(instancetype)sharedInstance;
#define singleton_m\
static id _instanceType = nil;\
\
+(instancetype)sharedInstance\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instanceType = [[self alloc]init];\
    });\
    return _instanceType;\
}\
\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instanceType = [[self alloc]init];\
    });\
    return _instanceType;\
}\
\
- (id)copyWithZone:(NSZone *)zone\
{\
    return _instanceType;\
}\
\
-(oneway void)release\
{\
}\
\
- (instancetype)retain\
{\
    return _instanceType;\
}\
\
-(instancetype)autorelease\
{\
    return _instanceType;\
}\
-(NSUInteger)retainCount\
{\
    return 1;\
}\

#endif


#endif /* Singleton_h */
