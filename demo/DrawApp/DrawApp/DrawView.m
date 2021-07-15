//
//  DrawView.m
//  DrawApp
//
//  Created by 周登杰 on 2020/11/7.
//

#import "DrawView.h"

@implementation DrawView


- (void)drawRect:(CGRect)rect {
    // 存储点不为空时往下执行
    if (_mArrPoint) {
        // 1.绘图上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        /*
         从UI上取得当前笔画，并存储
         1）、把组成每一笔画的点存储在一个数组（savePoint）
         2）、再把每一画打包成一个对象，存储到另一个数组(displayPoint)
         */
        if (!_savePoint) {
            _savePoint = [[NSMutableArray alloc] init];
        }
        _savePoint = _mArrPoint;
        if (!_displayPoint) {
            _displayPoint = [[NSMutableArray alloc] init];
        }
        [_displayPoint addObject:_savePoint];
        
        // 2.连接各点构成线，双重循环
        for (int i = 0 ; i < [_displayPoint count] ; i ++) {
            NSMutableArray *tempArr = [_displayPoint objectAtIndex:i];
            // 书写每一笔画时，重新设置起始点
            CGPoint startPoint = [[tempArr objectAtIndex:0 ] CGPointValue];
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            for (int j = 0 ; j < [tempArr count] ; j ++) {
                CGContextAddLineToPoint(context,[[tempArr objectAtIndex:j] CGPointValue].x,[[tempArr objectAtIndex:j] CGPointValue].y);
            }
        }
                
        // 3设置画笔属性，宽度，颜色
        [[UIColor greenColor] set];
        CGContextSetLineWidth(context, 5);
        CGContextStrokePath(context);
    }
}
 
// 清空画布
- (void)cleanDrawView {
    _mArrPoint = nil;
    _savePoint = nil;
    _displayPoint = nil;
    [self setNeedsDisplay];
}
 
#pragma mark UIResponder
// 开始触摸
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _mArrPoint = nil;
    NSLog(@"touchesBegan");
}
 
// 触摸移动，不断监听一次有效的Touch移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_mArrPoint) {
        _mArrPoint = [[NSMutableArray alloc] init];
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    [_mArrPoint addObject:[NSValue valueWithCGPoint: touchPoint]];
    [self setNeedsDisplay];
    NSLog(@"touchesMoved");
}
 
// 触摸事件结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
}
 
// 触摸事件 取消，比如来电话打断
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}
 
/*
 而这几个方法被调用时，正好对应了UITouch类中phase属性的4个枚举值。
 上面的四个事件方法，在开发过程中并不要求全部实现，可以根据需要重写特定的方法。对于这4个方法
 都有两个相同的参数：NSSet类型的touches和UIEvent类型的event。其中touches表示触摸产生的
 所有UITouch对象，而event表示特定的事件。因为UIEvent包含了整个触摸过程中所有的触摸对象
 因此可以调用allTouches方法获取该事件内所有的触摸对象，也可以调用touchesForVIew：
 或者touchesForWindows：取出特定视图或者窗口上的触摸对象。在这几个事件中，都可以拿到触摸对象
 然后根据其位置，状态，时间属性做逻辑处理。
 */


@end
