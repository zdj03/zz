//
//  GCDTimer.h
//  GCD
//
//  Created by 周登杰 on 2019/10/11.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Task)(void);

@interface GCDTimer : NSObject

+ (GCDTimer *)timerWithTask:(Task)task withTimeInterval:(NSTimeInterval)ti;

- (void)invalid;

@end

NS_ASSUME_NONNULL_END
