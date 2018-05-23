//
//  BRSearchResultCell.m
//  KnowN
//
//  Created by Yingwei Fan on 4/25/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRSearchResultCell.h"

@implementation BRSearchResultCell

+ (NSString *)identifier {
    return @"BRSearchResultCell";
}

+ (CGFloat)defaultRowHeight {
    return 60;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UILayoutGuide *margin = self.contentView.layoutMarginsGuide;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    [_avatarView.topAnchor constraintEqualToAnchor:margin.topAnchor].active = YES;
    [_avatarView.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor].active = YES;
    [_avatarView.bottomAnchor constraintEqualToAnchor:margin.bottomAnchor].active = YES;
    [_avatarView.widthAnchor constraintEqualToAnchor:_avatarView.heightAnchor].active = YES;
    
    _nicknameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nicknameLabel];
    _nicknameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_nicknameLabel.topAnchor constraintEqualToAnchor:margin.topAnchor].active = YES;
    [_nicknameLabel.leadingAnchor constraintEqualToAnchor:_avatarView.trailingAnchor constant:8].active = YES;
    [_nicknameLabel.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_usernameLabel];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_usernameLabel.leadingAnchor constraintEqualToAnchor:_avatarView.trailingAnchor constant:8].active = YES;
    [_usernameLabel.bottomAnchor constraintEqualToAnchor:margin.bottomAnchor].active = YES;
    [_usernameLabel.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    [_usernameLabel.topAnchor constraintEqualToAnchor:_nicknameLabel.bottomAnchor].active = YES;
}

- (void)setModel:(BRContactListModel *)model {
    self.avatarView.image = model.avatarImage? model.avatarImage : [UIImage imageNamed:@"user_default"];
    self.nicknameLabel.text = model.nickname;
    self.usernameLabel.text = [NSString stringWithFormat:@"KnowN ID: %@", model.username];
}

@end
