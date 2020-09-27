//
//  MyClass.h
//  MyClass
//
//  Created by 周登杰 on 2019/9/10.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyClass : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) NSString *string;

- (void)method1;
- (void)method2;
+ (void)classMethod1;


@end

NS_ASSUME_NONNULL_END
