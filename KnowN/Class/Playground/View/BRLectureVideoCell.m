//
//  BRLectureVideoCell.m
//  KnowN
//
//  Created by Yingwei Fan on 3/9/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRLectureVideoCell.h"
#import <UIImageView+WebCache.h>

@interface BRLectureVideoCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *instructorLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *purchaseButton;

@end

@implementation BRLectureVideoCell

+ (NSString *)reuseIdentifier {
    return @"BRLectureVideoCell";
}

+ (CGFloat)defaultCellHeight {
    return 120;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UILayoutGuide *marginGuide = self.contentView.layoutMarginsGuide;
    
    _thumbnailImageView = [[UIImageView alloc] init];
    _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_thumbnailImageView];
    _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_thumbnailImageView.topAnchor constraintEqualToAnchor:marginGuide.topAnchor].active = YES;
    [_thumbnailImageView.leadingAnchor constraintEqualToAnchor:marginGuide.leadingAnchor].active = YES;
    [_thumbnailImageView.bottomAnchor constraintEqualToAnchor:marginGuide.bottomAnchor].active = YES;
    [_thumbnailImageView.widthAnchor constraintEqualToAnchor:_thumbnailImageView.heightAnchor].active = YES;
    
    _purchaseButton = [[UIButton alloc] init];
    [_purchaseButton setBackgroundImage:[UIImage imageNamed:@"background_blue"] forState:UIControlStateNormal];
    [_purchaseButton setBackgroundImage:[UIImage imageNamed:@"background_blue_highlighted"] forState:UIControlStateHighlighted];
    [_purchaseButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
    _purchaseButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _purchaseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_purchaseButton];
    _purchaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_purchaseButton.trailingAnchor constraintEqualToAnchor:marginGuide.trailingAnchor].active = YES;
    [_purchaseButton.heightAnchor constraintEqualToConstant:25].active = YES;
    [_purchaseButton.widthAnchor constraintEqualToAnchor:_purchaseButton.heightAnchor multiplier: 1.6].active = YES;
    [_purchaseButton.centerYAnchor constraintEqualToAnchor:marginGuide.centerYAnchor].active = YES;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:20.0];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleLabel.topAnchor constraintEqualToAnchor:_thumbnailImageView.topAnchor].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:_thumbnailImageView.trailingAnchor constant:5].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:marginGuide.trailingAnchor].active = YES;
    [_titleLabel.heightAnchor constraintEqualToConstant:25].active = YES;
    
    _instructorLabel = [[UILabel alloc] init];
    _instructorLabel.font = [UIFont systemFontOfSize:14.0];
    _instructorLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_instructorLabel];
    _instructorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_instructorLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:3.0].active = YES;
    [_instructorLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor].active = YES;
    [_instructorLabel.trailingAnchor constraintEqualToAnchor:_purchaseButton.leadingAnchor constant:-5.0].active = YES;
    [_instructorLabel.heightAnchor constraintEqualToConstant:18].active = YES;
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont systemFontOfSize:13.0];
    _detailLabel.textColor = [UIColor lightGrayColor];
    _detailLabel.numberOfLines = 0;
    [self.contentView addSubview:_detailLabel];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_detailLabel.topAnchor constraintEqualToAnchor:_instructorLabel.bottomAnchor constant:5.0].active = YES;
    [_detailLabel.leadingAnchor constraintEqualToAnchor:_instructorLabel.leadingAnchor].active = YES;
    [_detailLabel.trailingAnchor constraintEqualToAnchor:_instructorLabel.trailingAnchor].active = YES;
    [_detailLabel.bottomAnchor constraintLessThanOrEqualToAnchor:marginGuide.bottomAnchor].active = YES;
}

- (void)setModel:(BRLectureVideoModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.instructorLabel.text = model.instructor;
    [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnailURL] placeholderImage:[UIImage imageNamed:@"video_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        model.thumbnailImage = image;
    }];
    self.detailLabel.text = model.detail;
    if (model.price != 0) {
        [self.purchaseButton setTitle:[NSString stringWithFormat:@"￥%.1f", model.price] forState:UIControlStateNormal];
        self.purchaseButton.enabled = YES;
    }
    else {
        [self.purchaseButton setTitle:@"FREE" forState:UIControlStateNormal];
        self.purchaseButton.enabled = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
