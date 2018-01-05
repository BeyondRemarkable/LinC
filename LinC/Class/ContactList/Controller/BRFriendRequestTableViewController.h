//
//  BRFriendRequestTableViewController.h
//  LinC
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"

@interface BRFriendRequestTableViewController : UITableViewController

@property (nonatomic, copy) NSString *searchID;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) BRContactListModel *model;
@property (nonatomic, assign) BOOL doesJoinGroup;
@property (nonatomic, copy) NSDictionary *requestDic;
@end
