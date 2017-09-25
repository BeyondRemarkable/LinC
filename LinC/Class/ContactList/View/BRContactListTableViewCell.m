//
//  BRRefreshTableViewCell.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BRContactListTableViewCell()



@end

@implementation BRContactListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.height/2;
    self.badgeLabel.layer.masksToBounds = YES;
    
}

#pragma mark - setter
- (void)setBadgeValue:(NSInteger)badgeValue {
    _badgeValue = badgeValue;
    
    if (badgeValue > 0) {
        self.badgeLabel.hidden = NO;
    }
    else{
        self.badgeLabel.hidden = YES;
    }
    
    if (badgeValue > 99) {
        self.badgeLabel.text = @"...";
    }
    else{
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)_badgeValue];
    }
}

- (void)setShowBadge:(BOOL)showBadge {
    if (_showBadge != showBadge) {
        _showBadge = showBadge;
        self.badgeLabel.hidden = !_showBadge;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setContactListModel:(BRContactListModel *)contactListModel
{
    _contactListModel = contactListModel;
    
    [self.imageIcon sd_setImageWithURL:[NSURL URLWithString:contactListModel.avatarURLPath] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (contactListModel.nickname == nil) {
        self.nickName.text = contactListModel.username;
    } else {
        self.nickName.text = contactListModel.nickname;
    }
}
@end
