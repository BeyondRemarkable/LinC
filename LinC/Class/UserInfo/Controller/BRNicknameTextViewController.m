//
//  UserNameTextViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRNicknameTextViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRNicknameTextViewController () <UITextFieldDelegate>
{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@end

@implementation BRNicknameTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nicknameTextField.text = self.nameText;
    [self.nicknameTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.nicknameTextField becomeFirstResponder];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    saveBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
}

- (void)saveAction {
    [self.nicknameTextField resignFirstResponder];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] updateSelfInfoWithKeys:@[@"nickname"] values:@[self.nicknameTextField.text] success:^(NSString *message) {
        [hud hideAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(nicknameDidChangeTo:)]) {
            [_delegate nicknameDidChangeTo:[self.nicknameTextField.text trimString]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (void)textFieldDidChange {
    if ([self.nicknameTextField.text isEqualToString:self.nameText]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveAction];
    return YES;
}

@end
