//
//  BRUserSettingTableViewController.m
//  LinC
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
#import <MBProgressHUD.h>
#import <SAMKeychain.h>

@interface BRUserSettingTableViewController ()
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
            
        }
        else if (indexPath.row == SettingPassword) {
            
            BRPasswordViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRPasswordViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == TableViewSectionOne) {
        if (indexPath.row == SettingHelpFeedBack) {
            
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    [[BRClientManager sharedManager] logoutIfSuccess:^(NSString *message) {
        [hud hideAnimated:YES];
        // 删除保存的token
        [SAMKeychain deletePasswordForService:kLoginTokenKey account:username];
        //手动登出后， 设置自动登录为false
        [[EMClient sharedClient].options setIsAutoLogin:NO];
        // 显示登录界面
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        BRLoginViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLoginViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

@end
