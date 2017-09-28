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
#import "BRAddingFriendViewController.h"
#import "BRFriendInfoTableViewController.h"
#import "BRFriendRequestTableViewController.h"
#import "BRClientManager.h"
#import <MJRefresh.h>
#import "BRFileWithNewFriendsRequestData.h"
#import "BRNewFriendTableViewController.h"

@interface BRContactListViewController () <EMContactManagerDelegate, UITableViewDelegate, UITableViewDataSource>

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
    
    [self setUpTableView];
    [self setUpNavigationBarItem];
    
    [self tableViewDidTriggerHeaderRefresh];
    
    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    //    //移除好友回调
    //    [[EMClient sharedClient].contactManager removeDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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

#pragma mark - button action
-(void)clickAddNewFriend {
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRAddingFriendViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRAddingFriendViewController"];
    
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
        
        if (indexPath.row == TableViewNewFriend) {
            NSUInteger friendRequestCount = [[BRFileWithNewFriendsRequestData countForNewFriendRequest] integerValue];
            if (friendRequestCount) {
                cell.badgeLabel.hidden = NO;
                cell.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)friendRequestCount];
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

/**
 * Set up white space between groups
 */
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // New friend and group session
    if (indexPath.section == TableViewSectionZero) {
        if (indexPath.row == TableVIewGroup) {
            
        }
        // 如果有好友请求，显示好友添加数量label
        if (indexPath.row == TableViewNewFriend) {
            BRContactListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

            NSUInteger friendRequestCount = [[BRFileWithNewFriendsRequestData countForNewFriendRequest] integerValue];
            
            if (friendRequestCount) {
                cell.badgeLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)friendRequestCount];
                BRNewFriendTableViewController *vc = [[BRNewFriendTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    // User contact list cell
    if (indexPath.section == TableViewSectionOne) {
        BRContactListModel *contactListModel = self.dataArray[indexPath.row];
        
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
        vc.searchID = contactListModel.username;
        vc.isFriend = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            NSMutableArray *contactsSource = [NSMutableArray arrayWithArray:buddyList];
            NSMutableArray *tempDataArray = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
            for (NSInteger i = 0; i < buddyList.count; i++) {
                NSString *buddy = [buddyList objectAtIndex:i];
                NSLog(@"%@", buddy);
                if (![blockList containsObject:buddy]) {
                    [contactsSource addObject:buddy];
                    
                    BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:buddy];
                    
                    if(model){
                        [tempDataArray addObject:model];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObjectsFromArray:tempDataArray];
                [weakself.tableView reloadData];
            });
        }
        [weakself tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
    });
}

#pragma mark - EMContactManager delegate

// 好友请求时的回调
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BRContactListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // 收到有效的邀请
    if ((aUsername || aMessage) ) {
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:aUsername, @"userID", aMessage, @"message", nil];
        [BRFileWithNewFriendsRequestData savedToPlistWithData:dataDict];
    }
    
    cell.badgeLabel.text = [BRFileWithNewFriendsRequestData countForNewFriendRequest];
    cell.showBadge = YES;
    [self.tableView reloadData];
}

// 好友通过邀请时的回调， 通过服务器加载好友列表
- (void)friendshipDidAddByUser:(NSString *)aUsername {
    [self tableViewDidTriggerHeaderRefresh];
}

//删除好友时，双方都会收到的回调
- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    [self tableViewDidTriggerHeaderRefresh];
}

@end
