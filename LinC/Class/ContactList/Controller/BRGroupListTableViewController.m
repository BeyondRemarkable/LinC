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

@interface BRGroupListTableViewController ()<UITableViewDataSource, UITableViewDelegate, EMGroupManagerDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSMutableArray *groupListArray;
@property (nonnull, strong) NSMutableArray *groupRequestArray;
@property (nonnull, strong) NSMutableArray *groupNameRequestArray;
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
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.groupNameRequestArray = [NSMutableArray array];
    self.groupRequestArray = [BRFileWithNewRequestData getAllNewRequestDataFromFile:newGroupRequestFile];
    
    // 获取群列表
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:-1 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            self.groupListArray = [aList copy];
            
            for (int i = 0; i < self.groupRequestArray.count; i++) {
                for (EMGroup *group in aList) {
                    NSString *requestGroupID = self.groupRequestArray[i][@"groupID"];
                    if ([group.groupId isEqualToString:requestGroupID]) {
                        [self.groupNameRequestArray addObject:group.subject];
                    }
                }
            }
            [self.tableView reloadData];
            [hud hideAnimated:YES];
        }
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setUpNavigationBarItem];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRGroupMemberTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"groupCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (self.groupNameRequestArray.count != 0) {
            NSString *groupName = self.groupNameRequestArray[indexPath.row];
            NSString *requestMessage = [NSString stringWithFormat: @"Join %@ group : ", groupName];
            cell.userMessage.text = [requestMessage stringByAppendingString: self.groupRequestArray[indexPath.row][@"message"]];
        }
        
        return cell;
    } else {
        BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
        //    cell.grounName.text = [NSString stringWithFormat:@"%@", self.groupArray[indexPath.row]];
        EMGroup *group = (EMGroup *)self.groupListArray[indexPath.row];
        cell.grounpName.text = group.subject;
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
        EMGroup *group = self.groupListArray[indexPath.row];
        
        BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:group.groupId conversationType:EMConversationTypeGroupChat];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMGroup *deleteGroup = self.groupListArray[indexPath.row];
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        if ([username isEqualToString: deleteGroup.owner]) {
            // 群主解散群
            UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Destory group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
               
                [[EMClient sharedClient].groupManager destroyGroup:deleteGroup.groupId finishCompletion:^(EMError *aError) {
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
            
            [[EMClient sharedClient].groupManager leaveGroup:deleteGroup.groupId completion:^(EMError *aError) {
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
