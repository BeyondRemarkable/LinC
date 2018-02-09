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
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <SAMKeychain.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BRCoreDataManager.h"

@interface BRFriendInfoTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

// User Info labels
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userWhatsUp;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UIButton *removeFromGroup;


@end

@implementation BRFriendInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: NO];
    
    //[self setupNavigationBarItem];
    
    [self setupFriendInfo];
    // 群主有权限删除群成员
    if ([[EMClient sharedClient].currentUsername isEqualToString: self.group.groupOwner] && !self.isSelf) {
        [self.removeFromGroup setHidden:NO];
    } 
    if (self.isSelf) {
        [self.addFriendButton setHidden:YES];
        [self.chatButton setHidden:YES];
        [self.deleteFriendButton setHidden:YES];
    }
}


- (void)setupFriendInfo {
    if (self.contactListModel) {
        [self setContactListModel:self.contactListModel];
    }
    [self setIsFriend:self.isFriend];
}

//以后需要在实现的功能------------------
//- (void)setupNavigationBarItem {
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setFrame:CGRectMake(0, 0, 35, 35)];
//    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
//    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//}
//------------------------------------

- (void)setIsFriend:(BOOL)isFriend {
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
    if (contactListModel.avatarImage)
        self.userIcon.image = contactListModel.avatarImage;
    else {
        NSURL *avatarURL = [NSURL URLWithString:contactListModel.avatarURLPath];
        [self.userIcon sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Report", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
}

- (IBAction)clickAddFriend{
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRRequestMessageTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRRequestMessageTableViewController"];
    vc.searchID = self.userID.text;
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
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            if (!aError) {
                hud.label.text = @"Deleted Successfully.";
                // 从core data中 删除好友数据
                NSArray *deleteArr = [NSArray arrayWithObject:self.contactListModel.username];
                if (deleteArr.count != 0) {
                    [[BRCoreDataManager sharedInstance] deleteFriendByID: deleteArr];
                }
                [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
            } else {
                [hud hideAnimated:YES afterDelay:1.5];
                hud.label.text = aError.errorDescription;
            }
        }];
      
    }];
   
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheet addAction:delete];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];

}


/**
    群主从群中删除群成员
 */
- (IBAction)clickRemoveGroup {
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Confirm Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EMClient sharedClient].groupManager removeMembers:[NSArray arrayWithObject:self.contactListModel.username] fromGroup:self.group.groupID completion:^(EMGroup *aGroup, EMError *aError) {
            if (!aError) {
                hud.label.text = @"Deleted Successfully.";
                [self performSelector:@selector(popVC) withObject:nil afterDelay:1.0];
            } else {
                hud.label.text = aError.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
            }
        }];
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

- (void)popVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChat:(id)sender {
    BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:self.contactListModel.username conversationType:EMConversationTypeChat];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
