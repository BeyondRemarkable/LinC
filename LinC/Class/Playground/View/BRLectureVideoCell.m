//
//  BRLectureVideoCell.m
//  LinC
//
//  Created by Yingwei Fan on 3/9/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRLectureVideoCell.h"

@interface BRLectureVideoCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *instructorLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *priceLabel;
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
    _thumbnailImageView.backgroundColor = [UIColor redColor];
    _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_thumbnailImageView];
    [_thumbnailImageView.topAnchor constraintEqualToAnchor:marginGuide.topAnchor].active = YES;
    [_thumbnailImageView.leadingAnchor constraintEqualToAnchor:marginGuide.leadingAnchor].active = YES;
    [_thumbnailImageView.bottomAnchor constraintEqualToAnchor:marginGuide.bottomAnchor].active = YES;
    [_thumbnailImageView.heightAnchor constraintEqualToConstant:[[self class] defaultCellHeight]].active = YES;
    [_thumbnailImageView.widthAnchor constraintEqualToAnchor:_thumbnailImageView.heightAnchor].active = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
