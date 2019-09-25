//
//  ZzTapGestureRecognizer.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ZzTapGestureRecognizer.h"

@implementation ZzTapGestureRecognizer



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s,%s",object_getClassName(self.view), __func__);
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s,%s",object_getClassName(self.view), __func__);
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s,%s",object_getClassName(self.view), __func__);
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s,%s",object_getClassName(self.view), __func__);
    [super touchesCancelled:touches withEvent:event];
}

@end
