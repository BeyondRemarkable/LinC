//
//  BRRefreshTableViewCell.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BRRefreshTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;


@end

@implementation BRRefreshTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setContactList:(BRContactListModel *)contactList
{
    _contactList = contactList;
    
    // Set image radius
    self.imageIcon.layer.cornerRadius = self.imageIcon.frame.size.width / 2;
    self.imageIcon.clipsToBounds = YES;
    
    [self.imageIcon sd_setImageWithURL:[NSURL URLWithString:contactList.iconURL] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
    
    if (contactList.userName == nil) {
        self.nickName.text = contactList.userID;
    } else {
        self.nickName.text = contactList.userName;
    }
}
@end
