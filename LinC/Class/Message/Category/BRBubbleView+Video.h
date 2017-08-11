//
//  BRBubbleView+Video.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView.h"

@interface BRBubbleView (Video)

/*!
 @method
 @brief 构建视频类型消息气泡视图
 */
- (void)setupVideoBubbleView;

/*!
 @method
 @brief 变更视频类型消息气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateVideoMargin:(UIEdgeInsets)margin;

@end
