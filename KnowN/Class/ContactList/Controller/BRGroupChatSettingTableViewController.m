//
//  BRGroupChatSettingTableViewController.m
//  KnowN
//
//  Created by zhe wu on 12/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRGroupChatSettingTableViewController.h"
#import "BRGroupMemberTableViewCell.h"
#import "BRClientManager.h"
#import "BRQRCodeViewController.h"
#import "BRRequestMessageTableViewController.h"
#import <MBProgressHUD.h>
#import <Hyphenate/Hyphenate.h>
#import "BRContactListModel.h"
#import "BRFriendInfoTableViewController.h"
#import "BRCoreDataManager.h"
#import "BRCreateChatViewController.h"
#import "BRMessageViewController.h"
#import "BRNavigationController.h"
#import "BRContactListViewController.h"
#import "BRCoreDataManager.h"
#import "BRGroup+CoreDataClass.h"
#import "BRFriendsInfo+CoreDataClass.h"


@interface BRGroupChatSettingTableViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *hud;
    NSString *groupOwner;
    EMGroupOptions *groupSetting;
    BRGroup *currentGroup;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *copiedGroupIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupIDLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveGroupView;
@property (nonatomic, strong) NSMutableArray *groupMembersName;


@end

@implementation BRGroupChatSettingTableViewController

typedef enum : NSInteger {
    TableViewGroupSetting = 0,
    TableViewGroupMembers,
} TableViewSession;

typedef enum : NSInteger {
    TableViewGroupID = 0,
    TableViewGroupName,
    TableViewGroupQRCode,
    TableViewGroupDescription,
} TableViewRow;

// Tableview cell identifier
static NSString * const cellIdentifier = @"groupCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTableView];
    [self setUpNavigationRightItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpGroupInfo];
}

// 设置群信息
- (void)setUpGroupInfo {
    
    [self.copiedGroupIDLabel setTitle:@"Copy" forState:UIControlStateNormal];
    [self.copiedGroupIDLabel setTitle:@"Copied" forState:UIControlStateSelected];
    [self.copiedGroupIDLabel addTarget:self action:@selector(copyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.doesJoinGroup) {
        [self setUpJoinGroupInfo];
    } else {
        [self setupGroupSettingInfo];
    }
}


/**
    申请加群时的群设置
 */
- (void)setUpJoinGroupInfo {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.leaveGroupView.hidden = YES;
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            self.groupIDLabel.text = aGroup.groupId;
            self.groupNameLabel.text = aGroup.subject;
            if (aGroup.description.length == 0) {
                self.groupDescriptionLabel.text = @"None";
            } else {
                self.groupDescriptionLabel.text = aGroup.description;
            }
            self->groupOwner = aGroup.owner;
            self->groupSetting = aGroup.setting;
           
            [self.tableView reloadData];
            [self->hud hideAnimated:YES];
        } else {
            self->hud.mode = MBProgressHUDModeText;
            self->hud.label.text = aError.errorDescription;
            [self->hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}


/**
    查看群设置
 */
- (void)setupGroupSettingInfo {
    self.leaveGroupView.hidden = NO;
    BRGroup *group = [[[BRCoreDataManager sharedInstance] fetchGroupsWithGroupID:self.groupID] lastObject];
    currentGroup = group;
    self.groupIDLabel.text = group.groupID;
    self.groupNameLabel.text = group.groupName;
    
    groupOwner = group.groupOwner;
    if (group.groupDescription.length == 0) {
        self.groupDescriptionLabel.text = @"None";
    } else {
        self.groupDescriptionLabel.text = group.groupDescription;
    }
    NSArray *groupMembersInfo = [group.friendsInfo allObjects];
    NSMutableArray *groupMembersArray = [NSMutableArray array];
    self.groupMembersName = [NSMutableArray array];
    for (BRFriendsInfo *groupMember in groupMembersInfo) {
        BRContactListModel *model = [[BRContactListModel alloc] init];
        model.username = groupMember.username;
        model.nickname = groupMember.nickname;
        model.gender = groupMember.gender;
        model.whatsUp = groupMember.whatsUp;
        model.location = groupMember.location;
        model.avatarImage = [UIImage imageWithData:groupMember.avatar];
        [groupMembersArray addObject:model];
        [self.groupMembersName addObject:model.username];
    }
    [groupMembersArray sortUsingComparator:^NSComparisonResult(BRContactListModel *left, BRContactListModel *right) {
        return [left.nickname compare: right.nickname];
    }];
    
    self.dataArray = groupMembersArray;
    
    if (self.dataArray.count == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // 群主允许加新组员 或
    // 群权限为EMGroupStylePrivateMemberCanInvite 或
    // 群权限为EMGroupStylePublicOpenJoin 允许加新组员
    BOOL canAddMoreMember = [group.groupOwner isEqualToString:[EMClient sharedClient].currentUsername] || groupSetting.style == EMGroupStylePrivateMemberCanInvite || groupSetting.style == EMGroupStylePublicOpenJoin;
    if (canAddMoreMember) {
        [self setUpAddMembersBtn];
    }
    
    // 获取群成员，并保存或更新
    
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupID cursor:nil pageSize:-1 completion:^(EMCursorResult *aResult, EMError *aError) {
        
        NSArray *groupMembersArray = nil;
        if (!aError) {
            if (aResult.list > 0 && group.groupOwner) {
                groupMembersArray = [[aResult.list mutableCopy] arrayByAddingObject:group.groupOwner];
            }
            // 获取群成员信息
            [[BRClientManager sharedManager] getFriendInfoWithUsernames:groupMembersArray andSaveFlag:NO success:^(NSMutableArray *groupMembersInfoArray) {
                [groupMembersInfoArray sortUsingComparator:^NSComparisonResult(BRContactListModel *left, BRContactListModel *right) {
                    return [left.nickname compare: right.nickname];
                }];
                self.dataArray = groupMembersInfoArray;
                // 保存到数据库
                [[BRCoreDataManager sharedInstance] saveGroupMembersToCoreData:groupMembersInfoArray toGroup:self.groupID];
                
                [hud hideAnimated:YES];
                [self.tableView reloadData];
            } failure:^(EMError *error) {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = error.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
            }];
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }
        
    }];
    
}


/**
    群权限允许时，邀请好友加群
 */
- (void)setUpAddMembersBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickAddMoreMembers) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setUpTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 90;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRGroupMemberTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)copyBtnClicked:(UIButton *)copyBtn {
    copyBtn.selected = !copyBtn.selected;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.groupIDLabel.text;
}

- (void)setUpNavigationRightItem {
    
    [self.navigationController setNavigationBarHidden: NO];
    if (self.doesJoinGroup) {
        // 请求加群
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(clickJoinGroup)];
    }
}

/**
 点击请求加群按钮(根据群权限判断)
 */
- (void)clickJoinGroup {

    switch (groupSetting.style) {
        case EMGroupStylePrivateOnlyOwnerInvite:
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Only host invite to join";
            [hud hideAnimated:YES afterDelay:1.5];
            break;
        case EMGroupStylePrivateMemberCanInvite:
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Only members invite to join";
            [hud hideAnimated:YES afterDelay:1.5];
            break;
        case EMGroupStylePublicJoinNeedApproval:
            [self sendInviteMessage];
            break;
        case EMGroupStylePublicOpenJoin:
            [self joinGroupAutomatically];
            break;
        default:
            break;
    }
    
}

- (void)sendInviteMessage {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRRequestMessageTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRRequestMessageTableViewController"];
    vc.groupOwner = groupOwner;
    vc.doesJoinGroup = YES;
    vc.groupID = self.groupID;
    [self.navigationController pushViewController:vc animated:YES];
}


/**
    邀请更多好友加群
 */
- (void)clickAddMoreMembers {
    BRCreateChatViewController *vc = [[BRCreateChatViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.doesAddMembers = YES;
    vc.groupID = self.groupID;
    vc.groupMembersArray = self.groupMembersName;
    [self.navigationController pushViewController:vc animated:YES];
 }


- (void)joinGroupAutomatically {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[EMClient sharedClient].groupManager joinPublicGroup:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Join Successfully";
            [self performSelector:@selector(pushToGroupMessageBy:) withObject:aGroup afterDelay:1.5];
            
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

- (void)pushToGroupMessageBy:(EMGroup *)group {
    [hud hideAnimated:YES];
    BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:group.groupId conversationType:EMConversationTypeGroupChat];
    vc.title = group.subject;
    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (int i = 0; i < vcArray.count; i++) {
        UIViewController *vc = [vcArray objectAtIndex:i];
        if (![vc isKindOfClass:[BRContactListViewController class]]) {
            [deleteArr addObject:vc];
        }
    }
    [vcArray removeObjectsInArray:deleteArr];
    [vcArray addObject:vc];
    [self.navigationController setViewControllers:vcArray animated:YES];
}

/**
 退出群聊
 */
- (IBAction)leaveGroupBtnClicked {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
     UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = nil;
    if ([username isEqualToString: groupOwner]) {
        // 群主解散群
        delete = [UIAlertAction actionWithTitle:@"Destory group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[EMClient sharedClient].groupManager destroyGroup:self.groupID finishCompletion:^(EMError *aError) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                if (!aError) {
                    hud.label.text = @"Destory group successfully.";
                    [[BRCoreDataManager sharedInstance] deleteGroupByGoupID:self.groupID];
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                } else {
                    hud.label.text = aError.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }];
    } else {
        // 群成员退出群
        delete = [UIAlertAction actionWithTitle:@"Comfirm leave group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[EMClient sharedClient].groupManager  leaveGroup:self.groupID completion:^(EMError *aError) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                if (!aError) {
                    hud.label.text = @"Leave group successfully.";
                    [[BRCoreDataManager sharedInstance] deleteGroupByGoupID:self.groupID];
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                } else {
                    hud.label.text = aError.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        self.tableView.editing = NO;
    }];
    
    [actionSheet addAction:delete];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)dismissVie {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableViewGroupSetting) {
        return [super tableView:tableView numberOfRowsInSection: section];
    } else {
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == TableViewGroupSetting) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupSetting && indexPath.row == TableViewGroupDescription ) {
        return UITableViewAutomaticDimension;
    } else {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupMembers) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewGroupSetting]];
    }else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupSetting && indexPath.row == TableViewGroupQRCode) {
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
        BRQRCodeViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRQRCodeViewController"];
        //拼接group字符串，以group结尾的二维码为群二维码
        vc.username = [self.groupID stringByAppendingString:@"group"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == TableViewGroupMembers) {
        // 查看群成员信息
        BRContactListModel *model = self.dataArray[indexPath.row];
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
        vc.group = currentGroup;
        if ([username isEqualToString:model.username]) {
            
            vc.isSelf = YES;
            vc.contactListModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy: model.username];
            
            if (friendInfo) {
                vc.isFriend = YES;
            }
            vc.contactListModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == TableViewGroupMembers) {
        return 60;
    } else {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

@end
