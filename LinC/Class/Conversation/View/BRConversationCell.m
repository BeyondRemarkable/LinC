//
//  BRConversationCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRConversationCell.h"
#import <Hyphenate/EMConversation.h>

CGFloat const BRConversationCellPadding = 10;

@implementation BRConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - class method

/*!
 @method
 @brief 获取cell的重用标识
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id)model
{
    return @"BRConversationCell";
}

/*!
 @method
 @brief 获取cell的高度
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id)model
{
    return BRConversationCellMinHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
