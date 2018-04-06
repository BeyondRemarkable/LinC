//
//  CreateChatViewController.h
//  KnowN
//
//  Created by Yingwei Fan on 6/16/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissViewController)(UIViewController *);
@interface BRCreateChatViewController : UITableViewController
@property (nonatomic, copy) DismissViewController dismissViewControllerCompletionBlock;
@property (nonatomic, assign) BOOL doesAddMembers;
@property (nonatomic, strong) NSArray *groupMembersArray;
@property (nonatomic, strong) NSString *groupID;
@end
