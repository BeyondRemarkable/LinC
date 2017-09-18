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
#import <MBProgressHUD.h>
#import <SAMKeychain.h>

@interface BRUserSettingTableViewController ()
{
    MBProgressHUD *hud;
}

@end

@implementation BRUserSettingTableViewController

typedef enum : NSInteger {
    TableViewSectionZerro = 0,
    TableViewSectionOne,
    TableViewSectionTwo,
} TableViewSession;

typedef enum NSUInteger {
    
    // Section zerro
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
    
    if (indexPath.section == TableViewSectionZerro) {
        if (indexPath.row == SettingPassword) {
            
            BRPasswordViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRPasswordViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == TableViewSectionTwo) {
        if (indexPath.row == SettingLogout) {
            
            UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *logOut = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                // 登出
                BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *accountName = [userDefaults objectForKey:kLoginUserNameKey];
                NSString *token = [SAMKeychain passwordForService:kServiceName account:accountName];
                
                [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
                NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/logout"];
                [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary *dict = (NSDictionary *)responseObject;
                    if ([dict[@"status"] isEqualToString:@"success"]) {
                        [hud hideAnimated:YES];
                        // 删除保存的token
                        [SAMKeychain deletePasswordForService:kServiceName account:accountName];
                        // 显示登录界面
                        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                        BRLoginViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLoginViewController"];
                        [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
                    }
                    else {
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = dict[@"message"];
                        [hud hideAnimated:YES afterDelay:1.5];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [hud hideAnimated:YES];
                    NSLog(@"%@", error.localizedDescription);
                }];
                
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


@end
