//
//  BRGroupMemberTableViewCell.h
//  KnowN
//
//  Created by zhe wu on 9/29/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"

@interface BRGroupMemberTableViewCell : UITableViewCell

@property (strong, nonatomic) BRContactListModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *grounpIcon;
@property (weak, nonatomic) IBOutlet UILabel *grounpName;
@property (weak, nonatomic) IBOutlet UIImageView *groupPropertyIcon;

@end
