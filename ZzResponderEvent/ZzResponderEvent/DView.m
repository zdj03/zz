//
//  AView.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "DView.h"

@implementation DView
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    NSLog(@"%s", __func__);
//        
//    return [super pointInside:point withEvent:event];
//}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"%s", __func__);
//    return [super hitTest:point withEvent:event];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;{
    NSLog(@"%s", __func__);
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;{
    NSLog(@"%s", __func__);
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;{
    NSLog(@"%s", __func__);
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;{
    NSLog(@"%s", __func__);
}

@end
