//
//  AView.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "AView.h"

@interface ZzControlTargetAction : NSObject

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) id target;

@end

@implementation ZzControlTargetAction


@end


@interface AView()
{
    ZzControlTargetAction *_targetAction;
}


@end

@implementation AView

- (void)dealloc {
    
    NSLog(@"AView dealloc");
}

- (void)addTarget:(id)target selector:(SEL)selector {
    if (!_targetAction) {
        _targetAction = ZzControlTargetAction.new;
    }
    
    _targetAction.target = target;
    _targetAction.action = selector;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;{
    NSLog(@"%s", __func__);
    
    if (_targetAction.action) {
        [_targetAction.target performSelector:_targetAction.action];
    }
    
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
