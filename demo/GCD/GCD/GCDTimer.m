//
//  GCDTimer.m
//  GCD
//
//  Created by 周登杰 on 2019/10/11.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

//@property (nonatomic, strong)dispatch_source_t *_timer;
//@property (nonatomic, copy)Task _task;

{
    dispatch_source_t _timer;

   // Task _task;
}
@end


@implementation GCDTimer


- (instancetype)init {
    
    if(self = [super init]){
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return self;
}

+ (GCDTimer *)timerWithTask:(Task)t withTimeInterval:(NSTimeInterval)ti {
    GCDTimer *timer = [GCDTimer new];
        
    dispatch_source_set_timer(timer->_timer, DISPATCH_TIME_NOW, ti * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer->_timer, [t copy]);
    dispatch_resume(timer->_timer);
    
    return timer;
}


- (void)invalid {
    dispatch_cancel(_timer);
}

@end
