//
//  BRPasswordViewController.m
//  KnowN
//
//  Created by zhe wu on 8/23/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRPasswordViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRPasswordViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation BRPasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtn)];
    self.navigationItem.rightBarButtonItem = saveBtn;

}

- (void)saveBtn {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //密码是否一样
    if (![self.updatePasswordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Password does not match", nil);
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    // 密码是否符合要求
    if (![self ispasswordStrong:self.updatePasswordTextField.text]) {
        [hud hideAnimated:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rule", nil) message:NSLocalizedString(@"Password not strong message", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [[BRClientManager sharedManager] updatePasswordWithCurrentPassword:self.oldPasswordTextField.text newPassword:self.updatePasswordTextField.text success:^(NSString *message) {
        [hud hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

// Password regex check
- (BOOL)ispasswordStrong:(NSString *)passwordString {
    NSPredicate *regexPassword = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?=.{6,32}$)(?=.*\\d)(?=.*[a-zA-Z]).*$"];
    
    return [regexPassword evaluateWithObject:passwordString];
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 54;
    } else {
        return 20;
    }
}

@end
