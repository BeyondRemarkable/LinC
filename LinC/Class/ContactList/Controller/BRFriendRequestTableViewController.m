//
//  BRFriendRequestTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendRequestTableViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRClientManager.h"
#import "BRFileWithNewFriendsRequestData.h"
#import <MBProgressHUD.h>
#import <SAMKeychain.h>
#import "BRClientManager.h"


@interface BRFriendRequestTableViewController ()
{
    MBProgressHUD *hud;
}
// User Info labels
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userWhatUp;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

@end

@implementation BRFriendRequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading...";
    
    self.messageLabel.text = self.message;
    self.userID.text = self.searchID;
    
    [[BRClientManager sharedManager] getUserInfoWithUsernames:[NSArray arrayWithObject:self.searchID] andSaveFlag:NO success:^(NSMutableArray *aList) {
        BRContactListModel *friendInfo = (BRContactListModel *)[aList firstObject];
        self.userIcon.image = friendInfo.avatarImage;
        self.userGender.text = friendInfo.gender;
        self.userWhatUp.text = friendInfo.whatsUp;
        if (!self.model.nickname) {
            self.userNickName.text = self.searchID;
        } else {
            self.userNickName.text = friendInfo.nickname;
        }
        [hud hideAnimated:YES];
    } failure:^(EMError *eError) {
        NSLog(@"%@", eError);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

/**
    同意好友请求, 并删除好友请求数据
 */
- (IBAction)agreeBtn {
    [BRFileWithNewFriendsRequestData deleteNewFriendRequest:self.searchID];
    [[EMClient sharedClient].contactManager acceptInvitationForUsername:self.searchID];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/**
    拒绝添加好友，并删除好友请求数据
 */
- (IBAction)refuseBtn {
    [BRFileWithNewFriendsRequestData deleteNewFriendRequest:self.searchID];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
