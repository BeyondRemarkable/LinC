//
//  BRFriendInfoTableViewController.h
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"
#import <Hyphenate/Hyphenate.h>

@interface BRFriendInfoTableViewController : UITableViewController
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, strong) BRContactListModel *contactListModel;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, strong) EMGroup *group;
@end
