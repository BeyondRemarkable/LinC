//
//  BRBaseMessageCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBaseMessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BRCoreDataManager.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRUserInfo+CoreDataClass.h"


@interface BRBaseMessageCell ()

@property (strong, nonatomic) UILabel *nameLabel;

@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarRightConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarRightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;

@end

@implementation BRBaseMessageCell

@synthesize nameLabel = _nameLabel;

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    BRBaseMessageCell *cell = [self appearance];
    cell.avatarSize = 30;
    //cell.avatarCornerRadius = 0;
    
    cell.messageNameColor = [UIColor grayColor];
    cell.messageNameFont = [UIFont systemFontOfSize:10];
    cell.messageNameHeight = 15;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        cell.messageNameIsHidden = NO;
    }
    
    //    cell.bubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = _messageNameFont;
        _nameLabel.textColor = _messageNameColor;
        [self.contentView addSubview:_nameLabel];
        
        [self configureLayoutConstraintsWithModel:model];
        
        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
            self.messageNameHeight = 15;
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bubbleView.backgroundImageView.image = self.model.isSender ? self.sendBubbleBackgroundImage : self.recvBubbleBackgroundImage;
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
        }
            break;
        case EMMessageBodyTypeImage:
        {
            CGSize retSize = self.model.thumbnailImageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                retSize.width = kEMMessageImageSizeWidth;
                retSize.height = kEMMessageImageSizeHeight;
            }
            else if (retSize.width > retSize.height) {
                CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kEMMessageImageSizeWidth;
            }
            else {
                CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kEMMessageImageSizeHeight;
            }
            [self removeConstraint:self.bubbleWithImageConstraint];
            
            CGFloat margin = [BRMessageCell appearance].leftBubbleMargin.left + [BRMessageCell appearance].leftBubbleMargin.right;
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
            
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self removeConstraint:self.bubbleWithImageConstraint];
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[BRMessageCell appearance].voiceCellWidth];
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
        }
            break;
        case EMMessageBodyTypeFile:
        {
        }
            break;
        default:
            break;
    }
}

/*!
 @method
 @brief 根据传入的消息对象，设置头像、昵称、气泡的约束
 @param model   消息对象
 */
- (void)configureLayoutConstraintsWithModel:(id<IMessageModel>)model
{
    if (model.isSender) {
        [self configureSendLayoutConstraints];
    } else {
        [self configureRecvLayoutConstraints];
    }
}

/*!
 @method
 @brief 发送方控件约束
 @discussion  当前登录用户为消息发送方时，设置控件约束，在cell的右侧排列显示
 */
- (void)configureSendLayoutConstraints
{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BRMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-BRMessageCellPadding]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-BRMessageCellPadding]];
    
    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-BRMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    //status button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-BRMessageCellPadding]];
    
    //activity
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-BRMessageCellPadding]];
    
    //hasRead
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-BRMessageCellPadding]];
}

/*!
 @method
 @brief 接收方控件约束
 @discussion  当前登录用户为消息接收方时，设置控件约束，在cell的左侧排列显示
 */
- (void)configureRecvLayoutConstraints
{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:BRMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BRMessageCellPadding]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:BRMessageCellPadding]];
    
    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:BRMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

#pragma mark - Update Constraint

/*!
 @method
 @brief 更新头像宽度的约束
 */
- (void)_updateAvatarViewWidthConstraint
{
    if (self.avatarView) {
        [self removeConstraint:self.avatarWidthConstraint];
        
        self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.avatarSize];
        [self addConstraint:self.avatarWidthConstraint];
    }
}

/*!
 @method
 @brief 更新昵称高度的约束
 */
- (void)_updateNameHeightConstraint
{
    if (_nameLabel) {
        [self removeConstraint:self.nameHeightConstraint];
        
        self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
        [self addConstraint:self.nameHeightConstraint];
    }
}

#pragma mark - setter
- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    
    _nameLabel.text = model.nickname;
    NSString *nicknameInModel = model.nickname;
    UIImage *avatarImageInModel = model.avatarImage;
    
    if (self.model.isSender) {
        
        if(!nicknameInModel || !avatarImageInModel) {
            BRUserInfo *userInfo = [[BRCoreDataManager sharedInstance] fetchUserInfoBy:model.message.from];
            model.avatarImage = [UIImage imageWithData:userInfo.avatar];
            if (!model.avatarImage) {
                model.avatarImage = [UIImage imageNamed:@"user_default"];
            }
            model.nickname = userInfo.nickname.length > 0 ? userInfo.nickname : @""; // don't want nil value
        }
        
        self.model.avatarImage = model.avatarImage;
        self.avatarView.image = model.avatarImage;
        self.nameLabel.text = model.nickname;
        
        _hasRead.hidden = YES;
        switch (self.model.messageStatus) {
            case EMMessageStatusDelivering:
            {
                _statusButton.hidden = YES;
                [_activity setHidden:NO];
                [_activity startAnimating];
            }
                break;
            case EMMessageStatusSucceed:
            {
                _statusButton.hidden = YES;
                [_activity stopAnimating];
                if (self.model.isMessageRead) {
                    //                    _hasRead.hidden = NO;
                }
            }
                break;
            case EMMessageStatusPending:
            case EMMessageStatusFailed:
            {
                [_activity stopAnimating];
                [_activity setHidden:YES];
                _statusButton.hidden = NO;
            }
                break;
            default:
                break;
        }
    } else {
        if(!nicknameInModel || !avatarImageInModel) {
            BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:model.message.from];
            if (!friendInfo) {
                model.avatarImage = [UIImage imageNamed:@"user_default"];
                model.nickname = @""; // don't want nil value
            } else {
                model.avatarImage = [UIImage imageWithData:friendInfo.avatar];
                model.nickname = friendInfo.nickname;
            }
        }
        
        self.avatarView.image = model.avatarImage;
        self.nameLabel.text = model.nickname;
    }
}

- (void)setMessageNameFont:(UIFont *)messageNameFont
{
    _messageNameFont = messageNameFont;
    if (_nameLabel) {
        _nameLabel.font = _messageNameFont;
    }
}

- (void)setMessageNameColor:(UIColor *)messageNameColor
{
    _messageNameColor = messageNameColor;
    if (_nameLabel) {
        _nameLabel.textColor = _messageNameColor;
    }
}

- (void)setMessageNameHeight:(CGFloat)messageNameHeight
{
    _messageNameHeight = messageNameHeight;
    if (_nameLabel) {
        [self _updateNameHeightConstraint];
    }
}

- (void)setAvatarSize:(CGFloat)avatarSize
{
    _avatarSize = avatarSize;
    if (self.avatarView) {
        [self _updateAvatarViewWidthConstraint];
    }
}

//- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius
//{
//    _avatarCornerRadius = avatarCornerRadius;
//    if (self.avatarView){
//        self.avatarView.layer.cornerRadius = avatarCornerRadius;
//    }
//}

- (void)setMessageNameIsHidden:(BOOL)messageNameIsHidden
{
    _messageNameIsHidden = messageNameIsHidden;
    if (_nameLabel) {
        _nameLabel.hidden = messageNameIsHidden;
    }
}

#pragma mark - public

/*!
 @method
 @brief 获取当前cell的高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    BRBaseMessageCell *cell = [self appearance];
    
    CGFloat minHeight = cell.avatarSize + BRMessageCellPadding * 2;
    CGFloat height = cell.messageNameHeight;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height += - BRMessageCellPadding + [BRMessageCell cellHeightWithModel:model];
    height = height > minHeight ? height : minHeight;
    
    return height;
}

@end
