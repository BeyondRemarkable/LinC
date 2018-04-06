//
//  BRGroupChatSettingTableViewController.h
//  KnowN
//
//  Created by zhe wu on 12/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRCreateGroupChatTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *selectedList;
@property (nonatomic, copy) void (^dismissViewControllerCompletionBlock)(UIViewController *);

@end
