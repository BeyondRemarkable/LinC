//
//  BRConversationCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRConversationModel.h"
#import "BRAvatarView.h"

/** @brief cell的最小高度 */
static CGFloat BRConversationCellMinHeight = 60;

/** @brief 会话列表自定义UITableViewCell */

@interface BRConversationCell : UITableViewCell

/** @brief 头像(用户、群组、聊天室) */
@property (strong, nonatomic) BRAvatarView *avatarView;

/** @brief 最近一条消息的信息 */
@property (strong, nonatomic) UILabel *detailLabel;

/** @brief 时间 */
@property (strong, nonatomic) UILabel *timeLabel;

/** @brief 会话标题 */
@property (strong, nonatomic) UILabel *titleLabel;

/** @brief 会话对象 */
@property (strong, nonatomic) BRConversationModel *model;

/** @brief 是否显示头像，默认为YES */
@property (nonatomic) BOOL showAvatar;

/** @brief title的字体 */
@property (nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR;

/** @brief title文字颜色 */
@property (nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR;

/** @brief 最近一条消息字体 */
@property (nonatomic) UIFont *detailLabelFont UI_APPEARANCE_SELECTOR;

/** @brief 最近一条消息文字颜色 */
@property (nonatomic) UIColor *detailLabelColor UI_APPEARANCE_SELECTOR;

/** @brief 时间文字字体 */
@property (nonatomic) UIFont *timeLabelFont UI_APPEARANCE_SELECTOR;

/** @brief 时间文字颜色 */
@property (nonatomic) UIColor *timeLabelColor UI_APPEARANCE_SELECTOR;

/*!
 @method
 @brief 获取cell的reuseIdentifier
 @param model    消息对象模型
 @return reuseIdentifier
 */
+ (NSString *)cellIdentifierWithModel:(BRConversationModel *)model;

/*!
 @method
 @brief 获取cell的高度
 @param model    消息对象模型
 @return cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id)model;

@end
