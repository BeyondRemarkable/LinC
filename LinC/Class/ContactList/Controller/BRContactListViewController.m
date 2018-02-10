//
//  BRRefreshViewController.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BRContactListViewController.h"
#import "BRContactListTableViewCell.h"
#import "IUserModel.h"
#import "BRSearchFriendViewController.h"
#import "BRFriendInfoTableViewController.h"
#import "BRFriendRequestTableViewController.h"
#import "BRMessageViewController.h"
#import "BRClientManager.h"
#import <MJRefresh.h>
#import "BRFileWithNewRequestData.h"
#import "BRNewFriendTableViewController.h"
#import "BRGroupListTableViewController.h"
#import <MBProgressHUD.h>
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"
#import "BRFriendsInfo+CoreDataClass.h"

@interface BRContactListViewController () <EMContactManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSArray *storedListArray;
@property (nonatomic, strong) NSArray *storedIconArray;

@property (nonatomic, copy) NSString *friendUserID;
@property (nonatomic, copy) NSString *friendMessage;

@end

@implementation BRContactListViewController

typedef enum : NSInteger {
    TableViewSectionZero = 0,
    TableViewSectionOne,
} TableViewSession;

typedef enum : NSInteger {
    TableViewNewFriend = 0,
    TableVIewGroup,
} UITableViewRow;

// Tableview cell identifier
static NSString * const cellIdentifier = @"ContactListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadFriendsInfoFromCoreData];
    [self setUpTableView];
    [self setUpNavigationBarItem];
    [self tableViewDidTriggerHeaderRefresh];
    
    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    //通知 刷新tabbar
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFriendRequest) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    NSString *friendsBadgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile];
    NSString *groupBadgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newGroupRequestFile];
    NSInteger badgeCount = [friendsBadgeCount integerValue] + [groupBadgeCount integerValue];
    // 是否需要显示tabbar bagge
    if (badgeCount != 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    } else {
        self.tabBarItem.badgeValue = nil;
    }
    [self.navigationController setNavigationBarHidden: NO];
   
}

- (void)checkFriendRequest {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

/**
 *  Lazy load NSArray storedListArray
 *
 *  @return _storedListArray
 */
- (NSArray *)storedListArray
{
    if (!_storedListArray) {
        _storedListArray = [NSArray array];
    }
    return _storedListArray;
}

/**
 *  Lazy load NSArray storedIconArray
 *
 *  @return _storedIconArray
 */
- (NSArray *)storedIconArray {
    if (_storedIconArray == nil) {
        _storedIconArray = [NSArray array];
    }
    return _storedIconArray;
}

/**
 * Set up tableView
 */
- (void)setUpTableView
{
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    //Register reuseable tableview cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRContactListTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.storedListArray = @[@"New Friend", @"Group"];
    self.storedIconArray = @[[UIImage imageNamed:@"new_friend_request"], [UIImage imageNamed:@"owned_group"]];
}

// Set up navigation bar items
- (void)setUpNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickAddNewFriend) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}


/**
      从core data加载已经保存的好友数据
 */
- (void)loadFriendsInfoFromCoreData {

    BRUserInfo *userInfo = [[BRCoreDataManager sharedInstance] getUserInfo];
    NSMutableArray *friendsModelArray = [NSMutableArray array];
    for (BRFriendsInfo *friendsInfo in userInfo.friendsInfo) {
        
        BRContactListModel *contactModel = [[BRContactListModel alloc] init];
        contactModel.username = friendsInfo.username;
        contactModel.nickname = friendsInfo.nickname;
        contactModel.avatarImage = [UIImage imageWithData: friendsInfo.avatar];
        contactModel.whatsUp = friendsInfo.whatsUp;
        contactModel.gender = friendsInfo.gender;
       
        [friendsModelArray addObject:contactModel];
    }
    [friendsModelArray sortUsingComparator:^NSComparisonResult(BRContactListModel *left, BRContactListModel *right) {
        return [left.username compare: right.username];
    }];
    self.dataArray = friendsModelArray;
}

#pragma mark - button action
-(void)clickAddNewFriend {
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRSearchFriendViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRSearchFriendViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == TableViewSectionZero ) {
        return self.storedListArray.count;
    } else {
        return self.dataArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TableViewSectionZero) {
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell.nickName.text = self.storedListArray[indexPath.row];
        cell.nickName.font = [UIFont systemFontOfSize:17];
        cell.imageIcon.image = self.storedIconArray[indexPath.row];
        
        // 有新好友请求
        if (indexPath.row == TableViewNewFriend) {
            NSUInteger friendRequestCount = [[BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile] integerValue];
            if (friendRequestCount) {
                cell.badgeLabel.hidden = NO;
                cell.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)friendRequestCount];
            } else {
                cell.badgeLabel.hidden = YES;
            }
        }
        // 有新群请求
        if (indexPath.row == TableVIewGroup) {
            NSUInteger groupRequestCount = [[BRFileWithNewRequestData countForNewRequestFromFile:newGroupRequestFile] integerValue];
            if (groupRequestCount) {
                cell.badgeLabel.hidden = NO;
                cell.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)groupRequestCount];
            } else {
                cell.badgeLabel.hidden = YES;
            }
        }
        return cell;
    } else {
        
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        id<IUserModel> contactListModel = [self.dataArray objectAtIndex:indexPath.row];
        cell.contactListModel = contactListModel;

        return cell;
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 60;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 群聊天
    if (indexPath.section == TableViewSectionZero) {
        if (indexPath.row == TableVIewGroup) {
            BRGroupListTableViewController *vc = [[BRGroupListTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }
        // 如果有好友请求，显示好友添加数量label
        if (indexPath.row == TableViewNewFriend) {
            BRContactListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            NSUInteger friendRequestCount = [[BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile] integerValue];
            
            if (friendRequestCount) {
                cell.badgeLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)friendRequestCount];
                BRNewFriendTableViewController *vc = [[BRNewFriendTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"No new friend.";
                [hud hideAnimated:YES afterDelay:1.5];

            }
        }
        else if (indexPath.row == TableVIewGroup) {
        }
    }
    // User contact list cell
    if (indexPath.section == TableViewSectionOne) {
        BRContactListModel *contactListModel = self.dataArray[indexPath.row];
        
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
        vc.contactListModel = contactListModel;
        vc.isFriend = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        
        if (!aError) {
            
            // 服务器返回好友列表为空 但是本地好友列表不为空，删除全部好友
            if (aList.count == 0 && self.dataArray.count != 0 ) {
                [[BRCoreDataManager sharedInstance] deleteFriendByID:nil];
                [self.dataArray removeAllObjects];
                [self.tableView reloadData];
                return;
            }
            NSMutableArray *contactsSource = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];

            for (NSInteger i = 0; i < aList.count; i++) {
                NSString *buddy = [aList objectAtIndex:i];
                if (![blockList containsObject:buddy]) {
                    [contactsSource addObject:buddy];
                }
            }
            
            [[BRClientManager sharedManager] getUserInfoWithUsernames:contactsSource andSaveFlag:YES success:^(NSMutableArray *aList) {
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObjectsFromArray:aList];
                [weakself.tableView reloadData];
                [weakself tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
            } failure:^(EMError *aError) {
                NSLog(@"%@", aError.errorDescription);
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = aError.description;
                [hud hideAnimated:YES afterDelay:1.5];
            }];
        } else {
            NSLog(@"%@", aError.errorDescription);
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

#pragma mark - EMContactManager delegate

// 好友请求时的回调
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BRContactListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // 收到有效的邀请
    if ((aUsername || aMessage) ) {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:aUsername, @"userID", aMessage, @"message",username, @"loginUser", nil];
        [BRFileWithNewRequestData savedToFileName:newFirendRequestFile withData:dataDict];
        
    }
    NSString *badgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile];
    cell.badgeLabel.text = badgeCount;
    cell.showBadge = YES;
    [self.tableView reloadData];
    self.tabBarItem.badgeValue = badgeCount;
}

// 好友通过邀请时的回调， 通过服务器加载好友列表
- (void)friendshipDidAddByUser:(NSString *)aUsername {
    [self tableViewDidTriggerHeaderRefresh];
}

//删除好友时，双方都会收到的回调
- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    if (aUsername.length == 0 || [aUsername isKindOfClass:[NSNull class]]) {
        return;
    }
    [[BRCoreDataManager sharedInstance] deleteFriendByID: [NSArray arrayWithObject:aUsername]];
    [self tableViewDidTriggerHeaderRefresh];
}

@end
