//
//  BRAddedFriendTableViewController.h
//  LinC
//
//  Created by zhe wu on 9/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRRequestMessageTableViewController : UITableViewController

@property (nonatomic, strong) NSString *searchID;
@property (nonatomic, assign) BOOL doesJoinGroup;
@property (nonatomic, strong) NSString *groupID;
@end
