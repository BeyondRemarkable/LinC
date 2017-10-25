//
//  BRFriendInfoTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendInfoTableViewController.h"
#import "BRSearchFriendViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRRequestMessageTableViewController.h"
#import "BRMessageViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <SAMKeychain.h>
#import "BRCoreDataManager.h"

@interface BRFriendInfoTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

// User Info labels
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userWhatsUp;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;


@end

@implementation BRFriendInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: NO];
    
    [self setupNavigationBarItem];
    
    [self setupFriendInfo];
    [self setFriend:self.isFriend];
}


- (void)setupFriendInfo {
    self.userNickName.text = self.contactListModel.nickname;
    self.userID.text = self.contactListModel.username;
    self.userGender.text = self.contactListModel.gender;
    self.userWhatsUp.text = self.contactListModel.whatsUp;
    self.userLocation.text = self.contactListModel.location;
}

- (void)setupNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setFriend:(BOOL)isFriend {
    _isFriend = isFriend;
    if (isFriend) {
        [self.addFriendButton setHidden:YES];
    }
    else {
        [self.chatButton setHidden:YES];
        [self.deleteFriendButton setHidden:YES];
    }
}

- (void)setContactListModel:(BRContactListModel *)contactListModel {
    _contactListModel = contactListModel;
    self.userNickName.text = contactListModel.nickname;
    self.userID.text = contactListModel.username;
    self.userGender.text = contactListModel.gender;
    self.userWhatsUp.text = contactListModel.whatsUp;
    self.userLocation.text = contactListModel.location;
}

#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - button actions
- (void)clickMoreInfo {
    
}

- (IBAction)clickAddFriend{
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRRequestMessageTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRRequestMessageTableViewController"];
    vc.userID = self.userID.text;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 删除好友
 */
- (IBAction)clickDeleteFriend:(id)sender {
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Confirm Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[EMClient sharedClient].contactManager deleteContact:self.contactListModel.username isDeleteConversation:YES completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Successful delete";
                [hud hideAnimated:YES afterDelay:1.5];
                [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
            }
        }];
        // 从core data中 删除好友数据
        [[BRCoreDataManager sharedInstance] deleteFriendByID:[NSArray arrayWithObject:self.contactListModel.username]];
    }];
   
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheet addAction:delete];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];

}

- (void)dismissVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)clickChat:(id)sender {
    BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:self.contactListModel.username conversationType:EMConversationTypeChat];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
