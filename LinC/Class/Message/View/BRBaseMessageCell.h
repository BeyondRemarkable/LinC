//
//  BRBaseMessageCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMessageCell.h"

extern NSString *const BRMessageCellIdentifierSendText;
extern NSString *const BRMessageCellIdentifierSendLocation;
extern NSString *const BRMessageCellIdentifierSendVoice;
extern NSString *const BRMessageCellIdentifierSendVideo;
extern NSString *const BRMessageCellIdentifierSendImage;
extern NSString *const BRMessageCellIdentifierSendFile;

@interface BRBaseMessageCell : BRMessageCell

{
    UILabel *_nameLabel;
}

/*
 *  头像尺寸大小
 */
@property (nonatomic) CGFloat avatarSize UI_APPEARANCE_SELECTOR; //default 30;

/*
 *  头像圆角
 */
@property (nonatomic) CGFloat avatarCornerRadius UI_APPEARANCE_SELECTOR; //default 0;

/*
 *  昵称显示字体
 */
@property (nonatomic) UIFont *messageNameFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:10];

/*
 *  昵称显示颜色
 */
@property (nonatomic) UIColor *messageNameColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor];

/*
 *  昵称显示高度
 */
@property (nonatomic) CGFloat messageNameHeight UI_APPEARANCE_SELECTOR; //default 15;

/*
 *  昵称是否显示
 */
@property (nonatomic) BOOL messageNameIsHidden UI_APPEARANCE_SELECTOR; //default NO;

@end
