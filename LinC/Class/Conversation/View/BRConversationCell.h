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

/** cell的最小高度 */
static CGFloat BRConversationCellMinHeight = 60;

/** 会话列表自定义UITableViewCell */
@interface BRConversationCell : UITableViewCell

/** 头像(用户、群组、聊天室) */
@property (weak, nonatomic) IBOutlet BRAvatarView *avatarView;

/** 最近一条消息的信息 */
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

/** 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/** 会话标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 会话对象 */
@property (strong, nonatomic) BRConversationModel *model;

/** 是否显示头像，默认为YES */
@property (nonatomic) BOOL showAvatar;

/** title的字体 */
@property (nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR;

/** title文字颜色 */
@property (nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR;

/** 最近一条消息字体 */
@property (nonatomic) UIFont *detailLabelFont UI_APPEARANCE_SELECTOR;

/** 最近一条消息文字颜色 */
@property (nonatomic) UIColor *detailLabelColor UI_APPEARANCE_SELECTOR;

/** 时间文字字体 */
@property (nonatomic) UIFont *timeLabelFont UI_APPEARANCE_SELECTOR;

/** 时间文字颜色 */
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
