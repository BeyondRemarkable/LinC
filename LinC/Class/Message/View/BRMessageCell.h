//
//  BRMessageCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IModelChatCell.h"
#import "IMessageModel.h"
#import "BRBubbleView.h"

/** @brief 缩略图宽度(当缩略图宽度为0或者宽度大于高度时) */
#define kEMMessageImageSizeWidth 120
/** @brief 缩略图高度(当缩略图高度为0或者宽度小于高度时) */
#define kEMMessageImageSizeHeight 120
/** @brief 位置消息cell的高度 */
#define kEMMessageLocationHeight 95
/** @brief 语音消息cell的高度 */
#define kEMMessageVoiceHeight 23

extern CGFloat const BRMessageCellPadding;

typedef enum{
    BRMessageCellEvenVideoBubbleTap,      /** @brief 视频消息cell点击 */
    BRMessageCellEventLocationBubbleTap,  /** @brief 位置消息cell点击 */
    BRMessageCellEventImageBubbleTap,     /** @brief 图片消息cell点击 */
    BRMessageCellEventAudioBubbleTap,     /** @brief 语音消息cell点击 */
    BRMessageCellEventFileBubbleTap,      /** @brief 文件消息cell点击 */
    BRMessageCellEventCustomBubbleTap,    /** @brief 自定义gif图片消息cell点击 */
}BRMessageCellTapEventType;

@protocol BRMessageCellDelegate;
@interface BRMessageCell : UITableViewCell <IModelChatCell>

{
    UIButton *_statusButton;
    UILabel *_hasRead;
    BRBubbleView *_bubbleView;
    UIActivityIndicatorView *_activity;
    
    
    NSLayoutConstraint *_statusWidthConstraint;
}

@property (weak, nonatomic) id<BRMessageCellDelegate> delegate;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (strong, nonatomic) UIImageView *avatarView;

@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UIButton *statusButton;

@property (strong, nonatomic) UILabel *hasRead;

/** @brief 气泡视图 */
@property (strong, nonatomic) BRBubbleView *bubbleView;

@property (strong, nonatomic) id<IMessageModel> model;

/*
 *  状态按钮尺寸
 */
@property (nonatomic) CGFloat statusSize UI_APPEARANCE_SELECTOR; //default 20;

/*
 *  加载尺寸
 */
@property (nonatomic) CGFloat activitySize UI_APPEARANCE_SELECTOR; //default 20;

/*
 *  聊天气泡的最大宽度
 */
@property (nonatomic) CGFloat bubbleMaxWidth UI_APPEARANCE_SELECTOR; //default 200;

@property (nonatomic) UIEdgeInsets bubbleMargin UI_APPEARANCE_SELECTOR; //default UIEdgeInsetsMake(8, 0, 8, 0);

@property (nonatomic) UIEdgeInsets leftBubbleMargin UI_APPEARANCE_SELECTOR; //default UIEdgeInsetsMake(8, 15, 8, 10);

@property (nonatomic) UIEdgeInsets rightBubbleMargin UI_APPEARANCE_SELECTOR; //default UIEdgeInsetsMake(8, 10, 8, 15);

/*
 *  发送者气泡图片
 */
@property (strong, nonatomic) UIImage *sendBubbleBackgroundImage UI_APPEARANCE_SELECTOR;

/*
 *  接收者气泡图片
 */
@property (strong, nonatomic) UIImage *recvBubbleBackgroundImage UI_APPEARANCE_SELECTOR;

/*
 *  消息显示字体
 */
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:15];

/*
 *  消息显示颜色
 */
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR; //default [UIColor blackColor];

/*
 *  位置消息显示字体
 */
@property (nonatomic) UIFont *messageLocationFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:12];

/*
 *  位置消息显示颜色
 */
@property (nonatomic) UIColor *messageLocationColor UI_APPEARANCE_SELECTOR; //default [UIColor whiteColor];

/*
 *  发送者语音消息播放图片
 */
@property (nonatomic) NSArray *sendMessageVoiceAnimationImages UI_APPEARANCE_SELECTOR;

/*
 *  接收者语音消息播放图片
 */
@property (nonatomic) NSArray *recvMessageVoiceAnimationImages UI_APPEARANCE_SELECTOR;

/*
 *  语音消息显示颜色
 */
@property (nonatomic) UIColor *messageVoiceDurationColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor];

/*
 *  语音消息显示字体
 */
@property (nonatomic) UIFont *messageVoiceDurationFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:12];

/*
 *  语音消息显示宽度
 */
@property (nonatomic) CGFloat voiceCellWidth UI_APPEARANCE_SELECTOR; //default 75;

/*
 *  文件消息名称显示字体
 */
@property (nonatomic) UIFont *messageFileNameFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:13];

/*
 *  文件消息名称显示颜色
 */
@property (nonatomic) UIColor *messageFileNameColor UI_APPEARANCE_SELECTOR; //default [UIColor blackColor];

/*
 *  文件消息显示字体
 */
@property (nonatomic) UIFont *messageFileSizeFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:11];

/*
 *  文件消息显示颜色
 */
@property (nonatomic) UIColor *messageFileSizeColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor];

/*
 *  @param  cell
 *  @param
 *  @param  消息model
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model;

/*
 *
 *
 *  @param  消息model
 *
 *  @result
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model;

/*
 *
 *
 *  @param  消息model
 *
 *  @result cell高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model;

@end

@protocol BRMessageCellDelegate <NSObject>

@optional

/*
 *  消息点击回调
 *
 *  @param  消息cell
 */
- (void)messageCellSelected:(BRMessageCell *)mesageCell;

/*
 *  状态按钮点击回调
 *
 *  @param  消息model
 *  @param  当前cell
 */
- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(BRMessageCell *)messageCell;

/*
 *  头像点击回调
 *
 *  @param  消息model
 */
- (void)avatarViewSelcted:(id<IMessageModel>)model;

@end
