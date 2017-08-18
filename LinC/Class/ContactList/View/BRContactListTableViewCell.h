//
//  BRRefreshTableViewCell.h
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"
@interface BRContactListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;

@property(nonatomic, strong) BRContactListModel *contactList;

@end
