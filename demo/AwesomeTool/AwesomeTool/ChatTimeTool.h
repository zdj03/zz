//
//  ChatTimeTool.h
//  AwesomeTool
//
//  Created by 周登杰 on 2019/11/3.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatTimeTool : NSObject

/// 将时间戳转换为友好的显示格式
/// 1、7天内的日期显示逻辑：今天、昨天、前天、星期几？
/// 2、7天之外：直接显示完整日期时间
/// @param dt 日期时间对象
/// @param includeTime YES表示输出格式里一定会包含“时间：分钟”，否则不包含
+ (NSString *)getTimeStringAutoShort2:(NSDate *)dt mustIncludeTime:(BOOL)includeTime;

+ (NSString *)getTimeString:(NSDate *)dt format:(NSString *)fmt;

/// 获得指定date对象的时间戳
/// @param dt <#dt description#>
+ (NSTimeInterval) getIOSTimeStamp:(NSDate *)dt;

/// 获取指定date对象iOS时间戳的long形式
/// @param dt <#dt description#>
+ (long)getIOSTimeStamp_l:(NSDate *)dt;

/// 获取iOS当前系统时间的date对象
+ (NSDate *)getIOSDefaultDate;

@end

NS_ASSUME_NONNULL_END
