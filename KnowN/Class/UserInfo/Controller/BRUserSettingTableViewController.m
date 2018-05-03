//
//  BRUserSettingTableViewController.m
//  KnowN
//
//  Created by zhe wu on 8/23/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserSettingTableViewController.h"
#import "BRLoginViewController.h"
#import "BRPasswordViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRClientManager.h"
#import "BRAboutViewController.h"
#import "BRGeneralSettingViewController.h"
#import <MBProgressHUD.h>
#import <SAMKeychain.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BRUserSettingTableViewController () <MFMailComposeViewControllerDelegate>
{
    MBProgressHUD *hud;
}

@end

@implementation BRUserSettingTableViewController

typedef enum : NSInteger {
    TableViewSectionZero = 0,
    TableViewSectionOne,
    TableViewSectionTwo,
} TableViewSession;

typedef enum NSUInteger {
    
    // Section zero
    SettingGeneral = 0,
    SettingPassword,
    
    // Section one
    SettingHelpFeedBack = 0,
    SettingAboutUs,
    
    //Section Two
    SettingLogout = 0
    
} UserSetting;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
}


#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
    
    if (indexPath.section == TableViewSectionZero) {
        if (indexPath.row == SettingGeneral) {
            BRGeneralSettingViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRGeneralSettingViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == SettingPassword) {
            
            BRPasswordViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRPasswordViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == TableViewSectionOne) {
        if (indexPath.row == SettingHelpFeedBack) {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                [mail setSubject:@"Feedback"];
                [mail setMessageBody:@"Thank you for your feedback!" isHTML:NO];
                [mail setToRecipients:@[@"info@beyondremarkable.com"]];
                [self presentViewController:mail animated:YES completion:NULL];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Please login your mail account.";
                [hud hideAnimated:YES afterDelay:1.5];
            }
        }
        else if (indexPath.row == SettingAboutUs) {
            BRAboutViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRAboutViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == TableViewSectionTwo) {
        if (indexPath.row == SettingLogout) {
            
            UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *logOut = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self logoutBtn];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [actionSheet addAction:logOut];
            [actionSheet addAction:cancel];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
    }
}

// 登出
- (void)logoutBtn {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    [[BRClientManager sharedManager] logoutIfSuccess:^(NSString *message) {

        // 删除保存的token
        [SAMKeychain deletePasswordForService:kLoginTokenKey account:username];
        //手动登出后， 设置自动登录为false
        [[EMClient sharedClient].options setIsAutoLogin:NO];
        
    } failure:^(EMError *error) {
        self->hud.mode = MBProgressHUDModeText;
        self->hud.label.text = error.errorDescription;
        [self->hud hideAnimated:YES afterDelay:1.5];
    }];

    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        if (aError) {
            self->hud.mode = MBProgressHUDModeText;
            self->hud.label.text = @"Try again later.";
            [self->hud hideAnimated:YES afterDelay:1.5];
        } else {
        // 显示登录界面
        [self->hud hideAnimated:YES];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        BRLoginViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLoginViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
