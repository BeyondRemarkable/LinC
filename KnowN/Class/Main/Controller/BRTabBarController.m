//
//  BRTabBarController.m
//  KnowN
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRTabBarController.h"
#import "BRNavigationController.h"
#import "BRPlaygroundViewController.h"
#import "BRConversationListViewController.h"
#import "BRContactListViewController.h"
#import "BRUserInfoViewController.h"
#import "BRSDKHelper.h"
#import "BRFileWithNewRequestData.h"
#import "BRClientManager.h"
#import "BRAudioCallManager.h"
#import "BRConfManager.h"

@interface BRTabBarController () <EMChatManagerDelegate, EMContactManagerDelegate>

@end

@implementation BRTabBarController

//- (NSMutableArray *)requestList {
//    if (_requestList == nil) {
//        _requestList = [NSMutableArray array];
//    }
//    return _requestList;
//}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // 设置tabBar的四个子控制器
        
        // Add playground view controller
        BRPlaygroundViewController *playgroundVc = [[BRPlaygroundViewController alloc] initWithStyle:UITableViewStylePlain];
        [self setupChildVc:playgroundVc title:NSLocalizedString(@"Playground", nil) imageName:@"tabbar_playground" selectedImageName:@"tabbar_playground_selected"];
        
        // Add conversation list view controller
        BRConversationListViewController *chatsVc = [[BRConversationListViewController alloc] initWithStyle:UITableViewStylePlain];
        [self setupChildVc:chatsVc title:NSLocalizedString(@"Messages", nil) imageName:@"tabbar_conversationlist" selectedImageName:@"tabbar_conversationlist_selected"];

        // Add contact list view controller
        BRContactListViewController *contactListVC = [[BRContactListViewController alloc] initWithStyle:UITableViewStylePlain];
        [self setupChildVc:contactListVC title:NSLocalizedString(@"Contacts", nil) imageName:@"tabbar_contactlist" selectedImageName:@"tabbar_contactlist_selected"];
        
        // Add user infromation view controller
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:nil];
        BRUserInfoViewController *vc =  [sc instantiateViewControllerWithIdentifier:@"BRUserInfoViewController"];
        [self setupChildVc:vc title:NSLocalizedString(@"Me", nil) imageName:@"tabbar_profile" selectedImageName:@"tabbar_profile_selected"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    // 将系统tabBar换成自定义
//    MainTabBar *tabBar = [[MainTabBar alloc] init];
//    [self setValue:tabBar forKey:@"tabBar"];
//    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_background"]];

    [self registerNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [BRAudioCallManager sharedManager];
    [self registerNotification];
    
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    // 获取未读消息数，设置badge，并更新群信息
    NSMutableSet *idSet = [NSMutableSet set];
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in conversations) {
        totalUnreadCount += conversation.unreadMessagesCount;
        if (conversation.type == EMConversationTypeGroupChat) {
            [idSet addObject:conversation.conversationId];
        }
    }
    [[BRClientManager sharedManager] updateGroupInformationWithIDs:idSet];
    if (totalUnreadCount) {
        self.tabBar.items[1].badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
    }
    
    // 获取未处理好友请求数，设置badge
    [self updateContactsBadge];
    // 注册语音
    [BRAudioCallManager sharedManager];
    [BRConfManager sharedManager];

}

- (void)receivedNewFriendRequest:(NSNotification *)notification {
    UITabBarItem *contactItem = self.tabBar.items[2];
    [self addBadgeBy:1 inItem:contactItem];
}

- (void)updateFriendRequest:(NSNotification *)notification {
    UITabBarItem *contactItem = self.tabBar.items[2];
    [self addBadgeBy:-1 inItem:contactItem];
}

- (void)updateContactsBadge {
    NSString *friendsBadgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile];
    NSString *groupBadgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newGroupRequestFile];
    NSInteger requestCount = [friendsBadgeCount integerValue] + [groupBadgeCount integerValue];
    if (requestCount) {
        self.tabBar.items[2].badgeValue = [NSString stringWithFormat:@"%ld", (long)requestCount];
    }
}

#pragma mark - private methods

- (void)registerNotification {
    // 设置代理
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewFriendRequest:)
                                                 name:kBRFriendRequestExtKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewFriendRequest:)
                                                 name:kBRGroupRequestExtKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequest:) name:BRFriendRequestUpdateNotification object:nil];
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupChildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    // 设置子控制器的标题和图标
    childVc.title = title; //set up tabbar and navigation bar
    childVc.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置tabBarItem的文字颜色属性
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:BRColor(94, 94, 94)} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:BRColor(247, 106, 45)} forState:UIControlStateSelected];
    
    BRNavigationController *navigationVc = [[BRNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:navigationVc];
    
}

- (void)addBadgeBy:(NSInteger)number inItem:(UITabBarItem *)item {
    if (number == 0) {
        return;
    }
    
    NSInteger currNum = [item.badgeValue integerValue];
    currNum += number;
    if (currNum == 0) {
        [item setBadgeValue:nil];
    }
    else {
        [item setBadgeValue:[NSString stringWithFormat:@"%ld", (long)currNum]];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages {
    UITabBarItem *chatItem = self.tabBar.items[1];
    [self addBadgeBy:aMessages.count inItem:chatItem];
}

- (void)dealloc {
    [self unregisterNotification];
}

//
//- (void)setChatBadgeTo:(NSInteger)number {
//    UITabBarItem *chatItem = [self.tabBar.items objectAtIndex:0];
//    if (number == 0) {
//        [chatItem setBadgeValue:nil];
//    }
//    else {
//        [chatItem setBadgeValue:[NSString stringWithFormat:@"%ld", (long)number]];
//    }
//}
//
//#pragma mark - EaseConversationListViewController delegate
//- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController didSelectConversationModel:(id<IConversationModel>)conversationModel {
//    if (conversationModel == nil) {
//        NSInteger unreadCount = self.chatsVc.unreadMessagesCount;
//        [self setChatBadgeTo:unreadCount];
//    }
//    
//    [self addChatBadgeBy:-conversationModel.conversation.unreadMessagesCount];
//}
//
//#pragma mark - EMContactManager delegate
//- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
//    // 加入到好友请求数组
//    for (EaseUserModel *model in self.requestList) {
//        if ([model.buddy isEqualToString:aUsername]) {
//            return;
//        }
//    }
//    [self.requestList insertObject:[[EaseUserModel alloc] initWithBuddy:aUsername] atIndex:0];
//    
//    // 设置tabbar的badge
//    UITabBarItem *contactItem = [self.tabBar.items objectAtIndex:1];
//    NSInteger badgeNum = [contactItem.badgeValue integerValue];
//    badgeNum ++;
//    [contactItem setBadgeValue:[NSString stringWithFormat:@"%ld", badgeNum]];
//}

@end
