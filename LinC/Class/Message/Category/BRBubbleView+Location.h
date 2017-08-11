//
//  BRBubbleView+Location.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView.h"

@interface BRBubbleView (Location)

/*!
 @method
 @brief 构建位置类型消息气泡视图
 */
- (void)setupLocationBubbleView;

/*!
 @method
 @brief 变更位置类型气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateLocationMargin:(UIEdgeInsets)margin;

@end
