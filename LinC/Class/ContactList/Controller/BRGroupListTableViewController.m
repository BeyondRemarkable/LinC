//
//  BRGroupListTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/27/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRGroupListTableViewController.h"
#import "BRGroupMemberTableViewCell.h"
#import "BRMessageViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <MBProgressHUD.h>
#import "BRFileWithNewRequestData.h"
#import "BRNewFriendTableViewCell.h"
#import "BRFriendRequestTableViewController.h"
#import "BRCoreDataManager.h"
#import "BRGroup+CoreDataClass.h"
#import "BRGroupIconGenerator.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRGroupModel.h"

@interface BRGroupListTableViewController ()<UITableViewDataSource, UITableViewDelegate, EMGroupManagerDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSMutableArray *groupListArray;
@property (nonatomic, strong) NSMutableArray *groupRequestArray;
@property (nonatomic, strong) NSArray *groupNameRequestArray;
@property (nonatomic, strong) NSArray *groupMembersIconArray;
@end

@implementation BRGroupListTableViewController

typedef enum : NSInteger {
    TableViewNewGroupRequest = 0,
    TableViewGroupList,
} TableViewSession;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.groupRequestArray = [BRFileWithNewRequestData getAllNewRequestDataFromFile:newGroupRequestFile];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setUpNavigationBarItem];
    [self setUpGroupInfo];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRGroupMemberTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"groupCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
    获取及更新群信息
 */
- (void)setUpGroupInfo {
    self.groupNameRequestArray = [NSMutableArray array];
    self.groupRequestArray = [BRFileWithNewRequestData getAllNewRequestDataFromFile:newGroupRequestFile];
    
    for (int i = 0; i < self.groupRequestArray.count; i++) {
        BRGroup *requestGroup = [[[BRCoreDataManager sharedInstance] fetchGroupsWithGroupID:self.groupRequestArray[i][@"groupID"]] lastObject];
        [self.groupNameRequestArray arrayByAddingObject:requestGroup.groupName];
    }
    
    NSArray *groupsArray = [[[BRCoreDataManager sharedInstance] fetchGroupsWithGroupID:nil] mutableCopy];
    NSMutableArray *groupModelArray = [NSMutableArray array];
    for (BRGroup *group in groupsArray) {
        BRGroupModel *groupModel = [[BRGroupModel alloc] init];
        groupModel.groupID = group.groupID;
        groupModel.groupName = group.groupName;
        groupModel.groupOwner = group.groupOwner;
        groupModel.groupDescription = group.groupDescription;
        groupModel.groupIcon = [UIImage imageWithData:group.groupIcon];
        [groupModelArray addObject:groupModel];
    }
    [groupModelArray sortUsingComparator:^NSComparisonResult(BRGroup *left, BRGroup *right) {
        return [left.groupName compare:right.groupName];
    }];
    self.groupListArray = groupModelArray;
    if (!self.groupListArray.count) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // 更新群模型数据
    [[BRClientManager sharedManager] getGroupInfoWithSuccess:^(NSMutableArray *groupInfoArray) {
        NSMutableArray *groupsArray = [groupInfoArray mutableCopy];
        [groupsArray sortUsingComparator:^NSComparisonResult(BRGroup *left, BRGroup *right) {
            return [left.groupName compare:right.groupName];
        }];
        NSMutableArray *groupList = [NSMutableArray array];
        // 删除已经不存在的群
        for (BRGroupModel *group in groupsArray) {
            [groupList addObject:group.groupID];
        }
        for (BRGroupModel *group in self.groupListArray) {
            if (![groupList containsObject:group.groupID]) {
                [[BRCoreDataManager sharedInstance] deleteGroupByGoupID:group.groupID];
            }
        }
        if (groupsArray.count) {
            self.groupListArray = groupsArray;
            [self.tableView reloadData];
        }
//        [self.tableView reload RowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1], nil] withRowAnimation:UITableViewRowAnimationNone];
        
        [hud hideAnimated:YES];

     } failure:^(EMError *error) {
         hud.mode = MBProgressHUDModeText;
         hud.label.text = error.errorDescription;
         [hud hideAnimated:YES afterDelay:1.5];
     }];
}

// Set up navigation bar items
- (void)setUpNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_new_friend_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickGroupSetting) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)clickGroupSetting {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing){
        //        self.navigationItem.rightBarButtonItem.image =
    }
    else{
        //        self.navigationItem.rightBarButtonItem.image =
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableViewNewGroupRequest) {
        return self.groupRequestArray.count;
    } else {
        return self.groupListArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == TableViewNewGroupRequest) {
        BRNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
        if (!cell) {
            cell= (BRNewFriendTableViewCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"BRNewFriendTableViewCell" owner:self options:nil]  lastObject];
        }
        cell.userID.text = self.groupRequestArray[indexPath.row][@"userID"];
        BRGroup *group = self.groupListArray[indexPath.row];
        NSString *requestMessage = [NSString stringWithFormat: @"Join %@ group : ", group.groupName];
        cell.userMessage.text = [requestMessage stringByAppendingString: self.groupRequestArray[indexPath.row][@"message"]];
        
        return cell;
    } else {
        BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
        BRGroupModel *group = self.groupListArray[indexPath.row];
        cell.grounpName.text = group.groupName;
        if (!group.groupIcon) {
            cell.grounpIcon.image = [UIImage imageNamed:@"group_default"];
            
        } else {
            cell.grounpIcon.image = group.groupIcon;
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewNewGroupRequest) {
        // 跳转到发送群申请信息VC
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendRequestTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendRequestTableViewController"];
        vc.doesJoinGroup = YES;
        vc.searchID = self.groupRequestArray[indexPath.row][@"userID"];
        vc.requestDic = self.groupRequestArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.groupListArray) {
        //获取群聊模型， 跳转到群聊天VC
        BRGroup *group = self.groupListArray[indexPath.row];
        
        BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:group.groupID conversationType:EMConversationTypeGroupChat];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BRGroup *deleteGroup = self.groupListArray[indexPath.row];
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        if ([username isEqualToString: deleteGroup.groupOwner]) {
            // 群主解散群
            UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Destory group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [[EMClient sharedClient].groupManager destroyGroup:deleteGroup.groupID finishCompletion:^(EMError *aError) {
                    if (!aError) {
                        self.groupListArray = [[[EMClient sharedClient].groupManager getJoinedGroups] copy];
                        [self.tableView reloadData];
                    } else {
                        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = aError.errorDescription;
                        [hud hideAnimated:YES afterDelay:1.5];
                    }
                }];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                self.tableView.editing = NO;
            }];
            
            [actionSheet addAction:delete];
            [actionSheet addAction:cancel];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
        } else {
            // 成员退出群
            
            [[EMClient sharedClient].groupManager leaveGroup:deleteGroup.groupID completion:^(EMError *aError) {
                if (!aError) {
                    self.groupListArray = [[[EMClient sharedClient].groupManager getJoinedGroups] copy];
                    [self.tableView reloadData];
                } else {
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = aError.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }
    }
}



@end
