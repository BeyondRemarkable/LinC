//
//  BRTabBarController.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRTabBarController.h"
#import "BRNavigationController.h"
#import "BRConversationListViewController.h"
#import "BRContactListViewController.h"
#import "BRUserInfoViewController.h"

@interface BRTabBarController ()

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
        BRConversationListViewController *chatsVc = [[BRConversationListViewController alloc] initWithStyle:UITableViewStylePlain];
        [self setupChildVc:chatsVc title:@"LinC" imageName:@"tabbar_chats_normal" selectedImageName:@"tabbar_chats_selected"];
        BRContactListViewController *contactsVc = [[BRContactListViewController alloc] init];
        [self setupChildVc:contactsVc title:NSLocalizedString(@"Contacts", @"") imageName:@"tabbar_contacts_normal" selectedImageName:@"tabbar_contacts_selected"];
        BRUserInfoViewController *profileVc = [[BRUserInfoViewController alloc] init];
        [self setupChildVc:profileVc title:NSLocalizedString(@"Me", @"") imageName:@"tabbar_me_normal" selectedImageName:@"tabbar_me_selected"];
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
//    
//    // 设置代理
//    [self.chatsVc setDelegate:self];
//    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    // 获取未读消息数，设置badge
//    NSInteger unreadNum = 0;
//    NSArray *chatList = [[EMClient sharedClient].chatManager getAllConversations];
//    for (EMConversation *chat in chatList) {
//        unreadNum += chat.unreadMessagesCount;
//    }
//    if (unreadNum) {
//        [[self.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)unreadNum]];
//    }
}

#pragma mark - private methods
- (void)setupChildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    // 设置子控制器的标题和图标
    childVc.title = title; //set up tabbar and navigation bar
    childVc.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置tabBarItem的文字颜色属性
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:BRColor(94, 94, 94)} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:BRColor(82, 190, 61)} forState:UIControlStateSelected];
    
    BRNavigationController *navigationVc = [[BRNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:navigationVc];
}

//- (void)addChatBadgeBy:(NSInteger)number {
//    if (number == 0) {
//        return;
//    }
//    UITabBarItem *chatItem = [self.tabBar.items objectAtIndex:0];
//    NSInteger currNum = [chatItem.badgeValue integerValue];
//    currNum += number;
//    if (currNum == 0) {
//        [chatItem setBadgeValue:nil];
//    }
//    else {
//        [chatItem setBadgeValue:[NSString stringWithFormat:@"%ld", (long)currNum]];
//    }
//}
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
