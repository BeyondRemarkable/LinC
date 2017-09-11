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

@interface BRUserSettingTableViewController ()

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
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
               
                UIStoryboard *sc = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
                BRLoginViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLoginViewController"];
                [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
                
            }];

            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [actionSheet addAction:logOut];
            [actionSheet addAction:cancel];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
            
            
            
            //    [UIView transitionWithView:self.view
            //                      duration:0.8
            //                       options:UIViewAnimationOptionTransitionCurlUp
            //                    animations:^{ [[UIApplication sharedApplication].keyWindow setRootViewController:vc]; }
            //                    completion:nil];
            
            
        }
    }
}


@end
