//
//  BRBubbleView+Text.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView.h"

@interface BRBubbleView (Text)

/*!
 @method
 @brief 构建文本类型消息气泡视图
 */
- (void)setupTextBubbleView;

/*!
 @method
 @brief 变更文本类型消息气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateTextMargin:(UIEdgeInsets)margin;

@end
