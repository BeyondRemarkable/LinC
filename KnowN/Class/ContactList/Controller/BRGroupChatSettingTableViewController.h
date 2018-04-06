//
//  BRGroupChatSettingTableViewController.h
//  KnowN
//
//  Created by zhe wu on 12/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>

@interface BRGroupChatSettingTableViewController : UITableViewController

@property (copy, nonatomic) NSString *groupID;
@property (nonatomic, assign) BOOL doesJoinGroup;
@end
