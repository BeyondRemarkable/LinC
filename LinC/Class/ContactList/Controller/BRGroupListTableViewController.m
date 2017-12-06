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

@interface BRGroupListTableViewController ()<UITableViewDataSource, UITableViewDelegate, EMGroupManagerDelegate>
{
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSMutableArray *groupArray;

@end

@implementation BRGroupListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.groupArray = [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:i pageSize:500 error: &error];
    
    self.groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
//    cell.grounName.text = [NSString stringWithFormat:@"%@", self.groupArray[indexPath.row]];
    EMGroup *group = (EMGroup *)self.groupArray[indexPath.row];
    cell.grounName.text = group.subject;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.groupArray) {
        //获取群聊模型， 跳转到群聊天VC
        EMGroup *group = self.groupArray[indexPath.row];
        
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
        EMGroup *deleteGroup = self.groupArray[indexPath.row];
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        if ([username isEqualToString: deleteGroup.owner]) {
            UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Destory group" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self.groupArray removeObjectAtIndex:indexPath.row];
                [[EMClient sharedClient].groupManager destroyGroup:deleteGroup.groupId finishCompletion:^(EMError *aError) {
                    if (!aError) {
                        self.groupArray = [[[EMClient sharedClient].groupManager getJoinedGroups] copy];
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
            [self.groupArray removeObjectAtIndex:indexPath.row];
            [[EMClient sharedClient].groupManager leaveGroup:deleteGroup.groupId completion:^(EMError *aError) {
                if (!aError) {
                    self.groupArray = [[[EMClient sharedClient].groupManager getJoinedGroups] copy];
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
