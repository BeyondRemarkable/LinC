//
//  BRBubbleView+Gif.h
//  KnowN
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBubbleView.h"

@interface BRBubbleView (Gif)

/*!
 @method
 @brief 构建gif自定义表情气泡
 */
- (void)setupGifBubbleView;

/*!
 @method
 @brief 变更gif表情气泡的边距，并更新改子视图约束
 @param margin 气泡边距
 */
- (void)updateGifMargin:(UIEdgeInsets)margin;

@end
