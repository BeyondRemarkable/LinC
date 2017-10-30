//
//  BRConversationCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRConversationCell.h"
#import <Hyphenate/EMConversation.h>
#import <SDWebImage/UIImageView+WebCache.h>

CGFloat const BRConversationCellPadding = 10;

@interface BRConversationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelLeftConstraint;

@end

@implementation BRConversationCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    /** @brief 默认配置 */
    BRConversationCell *cell = [self appearance];
    cell.titleLabelColor = [UIColor blackColor];
    cell.titleLabelFont = [UIFont systemFontOfSize:17];
    cell.detailLabelColor = [UIColor lightGrayColor];
    cell.detailLabelFont = [UIFont systemFontOfSize:15];
    cell.timeLabelColor = [UIColor blackColor];
    cell.timeLabelFont = [UIFont systemFontOfSize:13];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _showAvatar = YES;
        [self _setupSubview];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - private layout subviews

/*!
 @method
 @brief 加载视图
 */
- (void)_setupSubview
{
    self.accessibilityIdentifier = @"table_cell";
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.font = _timeLabelFont;
    _timeLabel.textColor = _timeLabelColor;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.backgroundColor = [UIColor clearColor];
    
    _titleLabel.accessibilityIdentifier = @"title";
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.numberOfLines = 1;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = _titleLabelFont;
    _titleLabel.textColor = _titleLabelColor;
    
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = _detailLabelFont;
    _detailLabel.textColor = _detailLabelColor;
}

#pragma mark - setter

- (void)setShowAvatar:(BOOL)showAvatar
{
    if (_showAvatar != showAvatar) {
        _showAvatar = showAvatar;
        self.avatarView.hidden = !showAvatar;
        if (_showAvatar) {
            [self removeConstraints:@[self.titleLabelLeftConstraint, self.detailLabelLeftConstraint]];
            
            self.titleLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:BRConversationCellPadding];
            self.detailLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.detailLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:BRConversationCellPadding];
            [self addConstraints:@[self.titleLabelLeftConstraint, self.detailLabelLeftConstraint]];
        }
        else{
            [self removeConstraints:@[self.titleLabelLeftConstraint, self.detailLabelLeftConstraint]];
            
            self.titleLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BRConversationCellPadding];
            self.detailLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.detailLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BRConversationCellPadding];
            [self addConstraints:@[self.titleLabelLeftConstraint, self.detailLabelLeftConstraint]];
        }
    }
}

- (void)setModel:(id<IConversationModel>)model
{
    _model = model;
    self.titleLabel.text = _model.title;
    self.avatarView.imageView.image = _model.avatarImage;
    
    if (_model.conversation.unreadMessagesCount == 0) {
        _avatarView.showBadge = NO;
    }
    else{
        _avatarView.showBadge = YES;
        _avatarView.badge = _model.conversation.unreadMessagesCount;
    }
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont
{
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = _titleLabelFont;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor
{
    _titleLabelColor = titleLabelColor;
    _titleLabel.textColor = _titleLabelColor;
}

- (void)setDetailLabelFont:(UIFont *)detailLabelFont
{
    _detailLabelFont = detailLabelFont;
    _detailLabel.font = _detailLabelFont;
}

- (void)setDetailLabelColor:(UIColor *)detailLabelColor
{
    _detailLabelColor = detailLabelColor;
    _detailLabel.textColor = _detailLabelColor;
}

- (void)setTimeLabelFont:(UIFont *)timeLabelFont
{
    _timeLabelFont = timeLabelFont;
    _timeLabel.font = _timeLabelFont;
}

- (void)setTimeLabelColor:(UIColor *)timeLabelColor
{
    _timeLabelColor = timeLabelColor;
    _timeLabel.textColor = _timeLabelColor;
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
