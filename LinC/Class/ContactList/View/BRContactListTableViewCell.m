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
    
    // Set image radius
    self.imageIcon.layer.cornerRadius = self.imageIcon.frame.size.width / 2;
    self.imageIcon.clipsToBounds = YES;
//    
//    [self.imageIcon sd_setImageWithURL:[NSURL URLWithString:contactListModel.iconURL] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
//    
//    if (contactListModel.userName == nil) {
//        self.nickName.text = contactListModel.userID;
//    } else {
//        self.nickName.text = contactListModel.userName;
//    }
}
@end
