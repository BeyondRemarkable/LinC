//
//  CreateChatViewController.m
//  LinC
//
//  Created by Yingwei Fan on 6/16/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCreateChatViewController.h"
#import "BRMessageViewController.h"
#import "BRContactListModel.h"
#import "BRContactListTableViewCell.h"
#import "BRClientManager.h"
#import "BRCoreDataManager.h"
#import "BRFriendsInfo+CoreDataClass.h"

@interface BRCreateChatViewController ()
@property (nonatomic, strong) NSArray *friendList;
@property (nonatomic, strong) NSMutableArray *selectedList;
@end

@implementation BRCreateChatViewController

- (NSMutableArray *)selectedList {
    if (_selectedList == nil) {
        _selectedList = [NSMutableArray array];
    }
    return _selectedList;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupFriendList];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setupFriendList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使空cell不显示
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BRContactListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BRContactListTableViewCell cellIdentifierWithModel:nil]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create chat", nil) style:UIBarButtonItemStylePlain target:self action:@selector(createChat)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

#pragma mark - private methods
- (void)setupFriendList {
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContacts];
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSString *userID in buddyList) {
         BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:userID];
        if (friendInfo) {

            BRContactListModel *contactModel = [[BRContactListModel alloc] initWithBuddy:friendInfo.username];
            contactModel.username = friendInfo.username;
            contactModel.nickname = friendInfo.nickname;
            contactModel.avatarImage = [UIImage imageWithData:friendInfo.avatar];
            contactModel.gender = friendInfo.gender;
            contactModel.location = friendInfo.location;
            contactModel.whatsUp = friendInfo.whatsUp;
            contactModel.email = friendInfo.email;
            [resultArr addObject:contactModel];
        }
    }
    
    self.friendList = resultArr;
    [self.tableView reloadData];
    
}

- (void)createChat {
    // 只选择一个好友，不创建群聊
    if (self.selectedList.count == 1) {
        // 退出创建界面
        [self.navigationController popViewControllerAnimated:YES];
        
        NSInteger index = [[self.selectedList objectAtIndex:0] integerValue];
        BRContactListModel *model = [self.friendList objectAtIndex:index];
        // push聊天界面
        BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:model.buddy conversationType:EMConversationTypeChat];
        vc.title = model.nickname;
        
        [self dismissViewControllerAnimated:YES completion:^{
            self.dismissCompletionBlock(vc);
        }];
    }
    // 选择了两个以上的好友，创建群聊
    else {
        NSMutableArray *groupInviteeList = [NSMutableArray array];
        for (NSNumber *number in self.selectedList) {
            NSInteger index = [number integerValue];
            [groupInviteeList addObject:[[self.friendList objectAtIndex:index] buddy]];
        }
        
        // 创建群聊
        EMGroupOptions *setting = [[EMGroupOptions alloc] init];
        setting.maxUsersCount = 500;
        setting.style = EMGroupStylePublicJoinNeedApproval;
        [[EMClient sharedClient].groupManager createGroupWithSubject:[NSString stringWithFormat:NSLocalizedString(@"%@'s group", nil), [EMClient sharedClient].currentUsername] description:@"" invitees:groupInviteeList message:@"" setting:setting completion:^(EMGroup *aGroup, EMError *aError) {
            if(!aError){
                // 退出创建界面
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"创建成功 -- %@", aGroup);
                BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:aGroup.groupId conversationType:EMConversationTypeGroupChat];
                vc.title = aGroup.subject;
                [self dismissViewControllerAnimated:YES completion:^{
                    self.dismissCompletionBlock(vc);
                }];
            }
            else {
                NSLog(@"创建失败 -- %@", aError.errorDescription);
            }
        }];
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [BRContactListTableViewCell cellIdentifierWithModel:nil];
    BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BRContactListModel *friendModel = [self.friendList objectAtIndex:indexPath.row];
    if (friendModel) {
        cell.contactListModel = friendModel;
    }
    
    if (self.selectedList.count) {
        if ([self.selectedList containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *obj = [NSNumber numberWithInteger:indexPath.row];
    if (self.selectedList.count) {
        if ([self.selectedList containsObject:obj]) {
            [self.selectedList removeObject:obj];
        }
        else {
            [self.selectedList addObject:obj];
        }
    }
    else {
        [self.selectedList addObject:obj];
    }
    
    if (self.selectedList.count) {
        // 设置按钮可用
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else {
        // 没有选中任何好友，按钮不可用
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    [tableView reloadData];
}


@end
