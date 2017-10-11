//
//  BRTabBarController.h
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTabBarController : UITabBarController

//@property (nonatomic, strong) ChatListViewController *chatsVc;
//@property (nonatomic, strong) ContactsViewController *contactsVc;
//@property (nonatomic, strong) ProfileViewController *profileVc;
//
/** 好友申请数组，包含的是BRUserModel数据 */
@property (nonatomic, strong) NSMutableArray *requestList;

@end
