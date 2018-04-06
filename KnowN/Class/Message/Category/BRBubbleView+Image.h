//
//  BRBubbleView+Image.h
//  KnowN
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView.h"

@interface BRBubbleView (Image)

/*!
 @method
 @brief 构建图片类型消息气泡视图
 */
- (void)setupImageBubbleView;

/*!
 @method
 @brief 变更图片类型消息气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateImageMargin:(UIEdgeInsets)margin;

@end
