//
//  BRGroupMemberTableViewCell.m
//  KnowN
//
//  Created by zhe wu on 9/29/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRGroupMemberTableViewCell.h"
@interface BRGroupMemberTableViewCell()


@end
@implementation BRGroupMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(BRContactListModel *)model {
    _model = model;
    self.grounpIcon.image = model.avatarImage ? model.avatarImage : [UIImage imageNamed:@"user_default"];
    if (model.nickname.length != 0) {
        self.grounpName.text = model.nickname;
    } else {
        self.grounpName.text = model.username;
    }
}

@end
