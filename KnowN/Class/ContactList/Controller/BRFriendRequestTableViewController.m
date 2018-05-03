//
//  BRFriendRequestTableViewController.m
//  KnowN
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendRequestTableViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRClientManager.h"
#import "BRFileWithNewRequestData.h"
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
    
    if (self.doesJoinGroup) {
        self.messageLabel.text = self.requestDic[@"message"];
    } else {
        self.messageLabel.text = self.message;
    }
    
    self.userID.text = self.searchID;
    
    [[BRClientManager sharedManager] getFriendInfoWithUsernames:[NSArray arrayWithObject:self.searchID] andSaveFlag:NO success:^(NSMutableArray *aList) {
        BRContactListModel *friendInfo = (BRContactListModel *)[aList firstObject];
        self.userIcon.image = friendInfo.avatarImage ? friendInfo.avatarImage : [UIImage imageNamed:@"user_default"];
        self.userGender.text = friendInfo.gender;
        self.userWhatUp.text = friendInfo.whatsUp;
        self.userLocation.text = friendInfo.location;
        self.userNickName.text = friendInfo.nickname;

        [self->hud hideAnimated:YES];
    } failure:^(EMError *eError) {
        self->hud.label.text = @"Try again later.";
        [self->hud hideAnimated:YES afterDelay:1.5];
        
    }];
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
    同意群申请或者好友申请
 */
- (IBAction)agreeBtn {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.doesJoinGroup) {
        // 同意群申请
        [BRFileWithNewRequestData deleteRequestFromFile:newGroupRequestFile byID:self.searchID];
        [[EMClient sharedClient].groupManager approveJoinGroupRequest:self.requestDic[@"groupID"] sender:self.requestDic[@"userID"] completion:^(EMGroup *aGroup, EMError *aError) {
            if (!aError) {
                [self->hud hideAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:BRFriendRequestUpdateNotification object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else {
                self->hud.mode = MBProgressHUDModeText;
                self->hud.label.text = aError.errorDescription;
                [self->hud hideAnimated:YES afterDelay:1.5];
            }
        }];
    } else {
        // 同意好友申请
        [[EMClient sharedClient].contactManager approveFriendRequestFromUser:self.searchID completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                [BRFileWithNewRequestData deleteRequestFromFile:newFirendRequestFile byID:self.searchID];
                [[NSNotificationCenter defaultCenter] postNotificationName:BRFriendRequestUpdateNotification object:nil];
                [self->hud hideAnimated:YES];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else {
                self->hud.mode = MBProgressHUDModeText;
                self->hud.label.text = aError.errorDescription;
                [self->hud hideAnimated:YES afterDelay:1.5];
            }
        }];
    }
}


/**
    拒绝群申请或者好友申请
 */
- (IBAction)refuseBtn {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:BRFriendRequestUpdateNotification object:nil];
    if (self.doesJoinGroup) {
        // 拒绝群申请
        [[EMClient sharedClient].groupManager declineJoinGroupRequest:self.requestDic[@"groupID"] sender:self.requestDic[@"userID"] reason:@"" completion:^(EMGroup *aGroup, EMError *aError) {
            [BRFileWithNewRequestData deleteRequestFromFile:newGroupRequestFile byID:self.searchID];
            [self->hud hideAnimated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    } else {
        // 拒绝好友申请
        [[EMClient sharedClient].contactManager declineFriendRequestFromUser:self.searchID completion:^(NSString *aUsername, EMError *aError) {
            [BRFileWithNewRequestData deleteRequestFromFile:newFirendRequestFile byID:self.searchID];
            [self->hud hideAnimated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}


@end
