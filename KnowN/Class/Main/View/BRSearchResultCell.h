//
//  BRSearchResultCell.h
//  KnowN
//
//  Created by Yingwei Fan on 4/25/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"

@interface BRSearchResultCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) BRContactListModel *model;

+ (NSString *)identifier;

+ (CGFloat)defaultRowHeight;

@end
