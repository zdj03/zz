//
//  DrawView.h
//  DrawApp
//
//  Created by 周登杰 on 2020/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawView : UIView
@property (strong, nonatomic) NSMutableArray *mArrPoint;
@property (strong, nonatomic) NSMutableArray *savePoint;
@property (strong, nonatomic) NSMutableArray *displayPoint;
@property (strong, nonatomic) NSValue *lastValue;
 
// 清空画布
- (void)cleanDrawView;

@end

NS_ASSUME_NONNULL_END
