//
//  AView.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "GView.h"

@implementation GView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSLog(@"%s", __func__);
    return [super pointInside:point withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
