//
//  AView.h
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AView : UIView

- (void)addTarget:(id)target selector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
