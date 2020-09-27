//
//  ChatTimeTool.m
//  AwesomeTool
//
//  Created by 周登杰 on 2019/11/3.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ChatTimeTool.h"

@implementation ChatTimeTool

+ (NSString *)getTimeStringAutoShort2:(NSDate *)dt mustIncludeTime:(BOOL)includeTime;
{
    NSString *ret = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    
    NSDateComponents *curComponents = [calendar components:calendarUnit fromDate:currentDate];
    NSInteger curY = [curComponents year];
    NSInteger curM = [curComponents month];
    NSInteger curD = [curComponents day];
    
    //目标判断时间
    NSDateComponents *srcComponents = [calendar components:calendarUnit fromDate:dt];
    NSInteger srcY = [srcComponents year];
    NSInteger srcM = [srcComponents month];
    NSInteger srcD = [srcComponents day];
    
    //要额外显示的时间分钟
    NSString *timeExtraStr = (includeTime ? [ChatTimeTool getTimeString:dt format:@" HH:mm"] : @"");
    
  //当年
    if (curY == srcY) {
        long currentTimeStamp = [ChatTimeTool getIOSTimeStamp:currentDate];
        long srcTimeStamp = [ChatTimeTool getIOSTimeStamp:dt];
        
        long delta = currentTimeStamp - srcTimeStamp;
        
        //当天（月份和日期一致才是）
        if (curM == srcM && curD == srcD) {
            //时间相差60秒以内
            if (delta < 60) {
                return @"刚刚";
            } else {
                ret = [ChatTimeTool getTimeString:dt format:@"HH:mm"];
            }
        } else {
            //昨天
            NSDate *yesterdayDate = [NSDate date];
            yesterdayDate = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:yesterdayDate];
            
            NSCalendarUnit cu = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
            NSDateComponents *yesterdayComponents = [calendar components:cu fromDate:yesterdayDate];
            NSInteger yesterdayM = [yesterdayComponents month];
            NSInteger yeaderdayD = [yesterdayComponents day];
            
            // 前天（以“现在”的时候为基准-2天）
                      
            NSDate *beforeYesterdayDate = [NSDate date];
            beforeYesterdayDate = [NSDate dateWithTimeInterval:-48*60*60 sinceDate:beforeYesterdayDate];
                                                       
            NSDateComponents *beforeYesterdayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:beforeYesterdayDate];
            NSInteger beforeYesterdayMonth=[beforeYesterdayComponents month];
            NSInteger beforeYesterdayDay=[beforeYesterdayComponents day];
                                                                   
            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
            if(srcM == yesterdayM && srcD == yeaderdayD)
                ret = [NSString stringWithFormat:@"昨天%@", timeExtraStr];// -1d
            // “前天”判断逻辑同上
            else if(srcM == beforeYesterdayMonth && srcD == beforeYesterdayDay)
                ret = [NSString stringWithFormat:@"前天%@", timeExtraStr];// -2d
            else{
            // 跟当前时间相差的小时数
                long deltaHour = (delta/3600);
                                                                       
                // 如果小于或等 7*24小时就显示星期几
                if (deltaHour <= 7*24){
                    NSArray<NSString *> *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
                    // 取出的星期数：1表示星期天，2表示星期一，3表示星期二。。。。 6表示星期五，7表示星期六
                    NSInteger srcWeekday=[srcComponents weekday];
                                                       
                    // 取出当前是星期几
                    NSString *weedayDesc = [weekdayAry objectAtIndex:(srcWeekday-1)];
                    ret = [NSString stringWithFormat:@"%@%@", weedayDesc, timeExtraStr];
                }
            }
        }
    }else{// 否则直接显示完整日期时间
        ret = [NSString stringWithFormat:@"%@%@", [ChatTimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
    }
    
    return ret;
}


+ (NSString *)getTimeString:(NSDate *)dt format:(NSString *)fmt;{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:fmt];
    return [format stringFromDate:(dt == nil ? [ChatTimeTool getIOSDefaultDate] : dt)];
}

/// 获得指定date对象的时间戳
/// @param dt <#dt description#>
+ (NSTimeInterval) getIOSTimeStamp:(NSDate *)dt;{
    return [dt timeIntervalSince1970];
}

/// 获取指定date对象iOS时间戳的long形式
/// @param dt <#dt description#>
+ (long)getIOSTimeStamp_l:(NSDate *)dt;{
    return [[NSNumber numberWithDouble:[ChatTimeTool getIOSTimeStamp:dt]] longValue];
}

/// 获取iOS当前系统时间的date对象
+ (NSDate *)getIOSDefaultDate;{
    return [NSDate date];
}

@end
