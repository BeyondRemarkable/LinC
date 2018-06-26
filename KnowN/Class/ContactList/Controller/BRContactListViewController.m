//
//  BRRefreshViewController.m
//  KnowN
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import "BRContactListViewController.h"
#import "BRContactListTableViewCell.h"
#import "IUserModel.h"
#import "BRSearchFriendViewController.h"
#import "BRFriendInfoTableViewController.h"
#import "BRFriendRequestTableViewController.h"
#import "BRMessageViewController.h"
#import "BRClientManager.h"
#import "BRFileWithNewRequestData.h"
#import "BRNewFriendTableViewController.h"
#import "BRGroupListTableViewController.h"
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRSearchResultTableViewController.h"
#import "BRNavigationController.h"
#import "BRSearchController.h"

@interface BRContactListViewController () <EMContactManagerDelegate, UISearchControllerDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSMutableArray *contactSectionArray;
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;

@property (nonatomic, strong) NSArray *storedListArray;
@property (nonatomic, strong) NSArray *storedIconArray;

@property (nonatomic, copy) NSString *friendUserID;
@property (nonatomic, copy) NSString *friendMessage;

/** 上一次从服务器获取好友信息的时间 */
@property (nonatomic, strong) NSDate *lastUpdateTime;

@property (nonatomic, strong) BRSearchController *searchController;

@end

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionZero = 0,
    TableViewSectionOne,
};

typedef NS_ENUM(NSUInteger, UITableViewRow) {
    TableViewNewFriend = 0,
    TableViewGroup,
};

@implementation BRContactListViewController

// Tableview cell identifier
static NSString * const cellIdentifier = @"ContactListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //如果进入预编辑状态,searchBar消失(UISearchController套到TabBarController可能会出现这个情况),请添加下边这句话
    self.definesPresentationContext = YES;
    
    [self loadFriendsInfoFromCoreData];
    [self setUpTableView];
    [self setUpNavigationBarItem];
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self tableViewDidTriggerHeaderRefresh];
    
    if (self.searchController.active) {
        self.tabBarController.tabBar.hidden = YES;
    }
    else {
        self.tabBarController.tabBar.hidden = NO;
    }
}

#pragma mark - lazy loading
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

- (NSMutableArray *)sectionTitleArray {
    if (_sectionTitleArray == nil) {
        _sectionTitleArray = [NSMutableArray array];
    }
    return _sectionTitleArray;
}

- (NSMutableArray *)contactSectionArray {
    if (_contactSectionArray == nil) {
        _contactSectionArray = [NSMutableArray array];
    }
    return _contactSectionArray;
}

- (BRSearchController *)searchController {
    if (_searchController == nil) {
        BRSearchResultTableViewController *searchResultVc = [[BRSearchResultTableViewController alloc] initWithStyle:UITableViewStylePlain];
        searchResultVc.dataArray = self.dataArray;
        _searchController = [[BRSearchController alloc] initWithSearchResultsController:searchResultVc];
        _searchController.searchResultsUpdater = searchResultVc;
        searchResultVc.searchBar = _searchController.searchBar;
        _searchController.delegate = self;
        
        // 修改searchBar外观
        _searchController.searchBar.tintColor = [UIColor orangeColor];
        _searchController.searchBar.barTintColor = BRColor(235, 235, 236);
        _searchController.searchBar.placeholder = NSLocalizedString(@"Search Friend", nil);
        //去掉searchController.searchBar的上下边框（黑线）
        UIImageView *barImageView = [[[_searchController.searchBar.subviews firstObject] subviews] firstObject];
        barImageView.layer.borderColor = BRColor(235, 235, 236).CGColor;
        barImageView.layer.borderWidth = 1;
    }
    return _searchController;
}

#pragma mark - initialization methods
/**
 * Set up tableView
 */
- (void)setUpTableView
{
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.rowHeight = 50.0;
    self.tableView.sectionIndexColor = [UIColor grayColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    //设置搜索headerView，使用一层UIView使得搜索框不会被sectionIndex挤压
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.searchController.searchBar.height)];
    [headerView addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = headerView;
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
    self.dataArray = [[BRCoreDataManager sharedInstance] fetchAllFriends];
    [self sectionalizeContacts:self.dataArray];
    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
}

- (void)setupNotifications {
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequest:)
                                                 name:kBRFriendRequestExtKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequest:)
                                                 name:kBRGroupRequestExtKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequest:) name:BRFriendRequestUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList:) name:BRContactUpdateNotification object:nil];
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
    return self.sectionTitleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == TableViewSectionZero ) {
        return self.storedListArray.count;
    } else {
        return [self.contactSectionArray[section] count];
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
        if (indexPath.row == TableViewGroup) {
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
        
        id<IUserModel> contactListModel = [self.contactSectionArray[indexPath.section] objectAtIndex:indexPath.row];
        cell.contactListModel = contactListModel;
        cell.badgeLabel.hidden = YES;

        return cell;
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    else {
        return self.sectionTitleArray[section];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 群聊天
    if (indexPath.section == TableViewSectionZero) {
        if (indexPath.row == TableViewGroup) {
            BRGroupListTableViewController *vc = [[BRGroupListTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }
        // 如果有好友请求，显示好友添加数量label
        else if (indexPath.row == TableViewNewFriend) {
            
            NSUInteger friendRequestCount = [[BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile] integerValue];
            
            if (friendRequestCount) {
                BRNewFriendTableViewController *vc = [[BRNewFriendTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"No new friend request", nil);
                [hud hideAnimated:YES afterDelay:1.5];

            }
        }
    }
    // User contact list cell
    else {
        BRContactListModel *contactListModel = self.contactSectionArray[indexPath.section][indexPath.row];
        
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
        vc.contactListModel = contactListModel;
        vc.isFriend = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification

- (void)updateContactList:(NSNotification *)notification {
    BRContactListModel *model = notification.object;
    if (model) {
        NSString *operation = notification.userInfo[@"Operation"];
        if ([operation isEqualToString:@"delete"]) {
            [self.dataArray removeObject:model];
        }
        else if ([operation isEqualToString:@"add"]) {
            [self.dataArray addObject:model];
        }
        [self sectionalizeContacts:self.dataArray];
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
    }
}

- (void)updateFriendRequest:(NSNotification *)notification {
    [self updateFriendRequestCell];
}

#pragma mark - private

- (void)updateFriendRequestCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.tableView cellForRowAtIndexPath:indexPath]) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self updateFriendRequestCell];
    
    NSDate *currentTime = [NSDate dateWithTimeIntervalSinceNow:0];
    if (self.lastUpdateTime) {
        NSTimeInterval interval = [currentTime timeIntervalSinceDate:self.lastUpdateTime];
        if ((int)interval/60%60 < 1) {
            return;
        }
    }
    self.lastUpdateTime = currentTime;
    
    __weak typeof(self) weakself = self;
    
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSMutableArray *contactsSource = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];

            for (NSInteger i = 0; i < aList.count; i++) {
                NSString *buddy = [aList objectAtIndex:i];
                if (![blockList containsObject:buddy]) {
                    [contactsSource addObject:buddy];
                }
            }
            
            [[BRClientManager sharedManager] getFriendInfoWithUsernames:contactsSource andSaveFlag:YES success:^(NSMutableArray *aList) {
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObjectsFromArray:aList];
                [weakself sectionalizeContacts:weakself.dataArray];
                [weakself tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:BRDataUpdateNotification object:nil]];
            } failure:^(EMError *aError) {
                self->hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self->hud.mode = MBProgressHUDModeText;
                self->hud.label.text = aError.description;
                [self->hud hideAnimated:YES afterDelay:1.5];
            }];
        } else {
            self->hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self->hud.mode = MBProgressHUDModeText;
            self->hud.label.text = aError.errorDescription;
            [self->hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

/**
 将好友根据首字母分组
 */
- (NSArray *)sectionalizeContacts:(NSArray *)contactArray {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSArray *allSectionTitles = [collation sectionTitles];
    NSUInteger sectionTitlesCount = [allSectionTitles count];
    NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
    for (NSUInteger i = 0; i < sectionTitlesCount; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [sectionArray addObject:array];
    }
    for (BRContactListModel *contactModel in contactArray) {
        NSInteger section;
        if (contactModel.nickname != nil) {
            section = [collation sectionForObject:contactModel collationStringSelector:@selector(nickname)];
        }
        else {
            section = [collation sectionForObject:contactModel collationStringSelector:@selector(username)];
        }
        
        [sectionArray[section] addObject:contactModel];
    }
    
    [self.sectionTitleArray removeAllObjects];
    [self.sectionTitleArray addObject:@"🔍"];
    [self.contactSectionArray removeAllObjects];
    [self.contactSectionArray addObject:[NSMutableArray array]];
    for (NSUInteger i = 0; i < sectionArray.count; i++) {
        NSMutableArray *array = sectionArray[i];
        if (array.count != 0) {
            //将数组中的Model进行排序
            [array sortUsingComparator:^NSComparisonResult(BRContactListModel*  _Nonnull model1, BRContactListModel*  _Nonnull model2) {
                NSString *str1 = model1.nickname?model1.nickname:model1.username;
                NSString *str2 = model2.nickname?model2.nickname:model2.username;
                return [str1 localizedCompare:str2];
            }];
            
            [self.sectionTitleArray addObject:allSectionTitles[i]];
            [self.contactSectionArray addObject:array];
        }
    }
    return self.contactSectionArray;
}

#pragma mark - EMContactManager delegate

// 好友请求时的回调
//- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
//
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//
//    BRContactListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//
//    // 收到有效的邀请
//    if ((aUsername || aMessage) ) {
//        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
//        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:aUsername, @"userID", aMessage, @"message",username, @"loginUser", nil];
//        [BRFileWithNewRequestData savedToFileName:newFirendRequestFile withData:dataDict];
//
//    }
//    NSString *badgeCount = [BRFileWithNewRequestData countForNewRequestFromFile:newFirendRequestFile];
//    cell.badgeLabel.text = badgeCount;
//    cell.showBadge = YES;
//    [self.tableView reloadData];
//    self.tabBarItem.badgeValue = badgeCount;
//}

// 好友通过邀请时的回调， 通过服务器加载好友列表
- (void)friendshipDidAddByUser:(NSString *)aUsername {
    [[BRClientManager sharedManager] getFriendInfoWithUsernames:@[aUsername] andSaveFlag:YES success:^(NSMutableArray *modelArray) {
        BRContactListModel *model = modelArray.firstObject;
        NSNotification *notification = [NSNotification notificationWithName:BRContactUpdateNotification object:model userInfo:@{@"Operation":@"add"}];
        [self updateContactList:notification];
    } failure:^(EMError *error) {
        
    }];
}

// 删除好友时，双方都会收到的回调
- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    if (aUsername == nil || aUsername.length == 0 || [aUsername isEqualToString:[EMClient sharedClient].currentUsername]) {
        return;
    }
    [[BRCoreDataManager sharedInstance] deleteFriendByID: [NSArray arrayWithObject:aUsername]];
    for (BRContactListModel *model in self.dataArray) {
        if ([model.username isEqualToString:aUsername]) {
            NSNotification *notification = [NSNotification notificationWithName:BRContactUpdateNotification object:model userInfo:@{@"Operation":@"delete"}];
            [self updateContactList:notification];
            break;
        }
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    UITabBar *tabBar = self.tabBarController.tabBar;
    tabBar.hidden = NO;
    
    // 适配iPhoneX的tabBar挤压问题
    if (@available(iOS 11.0, *)) {
        CGFloat bottomInset = tabBar.safeAreaInsets.bottom;
        if (bottomInset > 0 && tabBar.height < 50 && (tabBar.height + bottomInset < 90)) {
            tabBar.height += bottomInset;
            tabBar.y -= bottomInset;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
