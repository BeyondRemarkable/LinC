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
