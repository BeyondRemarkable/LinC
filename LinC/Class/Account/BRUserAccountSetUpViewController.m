//
//  BRUserInfoSetUpViewController.m
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//


#import "BRUserAccountSetUpViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRUserInfoSetUpTableViewController.h"
#import "BRTabBarController.h"
#import "UIView+Animation.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRUserAccountSetUpViewController () <UITextFieldDelegate>
{
    NSString *email;
    MBProgressHUD *hud;
}

// Input text field
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

// Constraints for layout email view and register view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailConentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailContentViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewRightConstraint;


// Constraints for adding details labels
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordConfirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeViewTopConstraint;

// All subviews
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIView *emailRegisterView;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *passwordConfirmView;
@property (weak, nonatomic) IBOutlet UIView *codeView;

// Detail Labels
@property (nonatomic, strong) UILabel *userNameDetailsLabel;
@property (nonatomic, strong) UILabel *passwordDetailsLabel;
@property (nonatomic, strong) UILabel *passwordConfirmDetailsLabel;

@end

@implementation BRUserAccountSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTextFeildDelegate];
    [self.emailTextField becomeFirstResponder];
    // 修改背景图片
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
    self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
    
    // Set navigationBar background color
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setUpTextFeildDelegate {
    self.userNameTextField.delegate = self;
    self.passwordConfirmTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.codeTextField.delegate = self;
}

#pragma mark - button action

- (IBAction)backAction:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getCodeAction:(id)sender {
    [self.view endEditing:YES];
    
    email = self.emailTextField.text;
    if (email.length == 0) {
        [self.emailRegisterView shakeAnimation];
        return;
    } else if(![self isValidEmail:email]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Invalid email address";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/verify/"];
    NSDictionary *parameters = @{@"email":email};
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud hideAnimated:YES];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            self.registerViewLeftConstraint.constant = 0;
            self.registerViewRightConstraint.constant = 0;
            
            self.emailViewLeftConstraint.constant = -SCREEN_WIDTH;
            self.emailViewRightConstraint.constant = SCREEN_WIDTH;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self.userNameTextField becomeFirstResponder];
            }];
            
            // 清空emailTextField
            self.emailTextField.text = @"";
        }
        else if ([dict[@"status"] isEqualToString:@"error"]) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = dict[@"message"];
            [hud hideAnimated:YES afterDelay:1.5];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (IBAction)resendAction:(id)sender {
    [self.view endEditing:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Use different email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearRegisterInformation];
        
        // 平移动画
        self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
        self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
        self.emailViewLeftConstraint.constant = 0;
        self.emailViewRightConstraint.constant = 0;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Resend code" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
        NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/verify"];
        NSDictionary *parameters = @{@"email":email};
        [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            hud.mode = MBProgressHUDModeCustomView;
            [hud hideAnimated:YES afterDelay:1.5];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            NSLog(@"%@", error.localizedDescription);
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)registerAction:(id)sender {
    [self.view endEditing:YES];
    
    // 如果存在未填信息
    if ([self isTextFieldEmpty]) {
        return;
    }
    // 如果密码信息有误
    if (self.passwordDetailsLabel || self.passwordConfirmDetailsLabel) {
        return;
    }
    

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] registerWithEmail:self.emailTextField.text username:self.userNameTextField.text password:self.passwordTextField.text code:self.codeTextField.text success:^(NSString *username, NSString *password) {
        // 注册完成后执行登录
        [[BRClientManager sharedManager] loginWithUsername:username password:password success:^(NSString *username) {
            [hud hideAnimated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
        } failure:^(EMError *error) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = error.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }];
        
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
    
}

#pragma mark - private methods

- (void)clearRegisterInformation {
    // 清空所有TextField
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.passwordConfirmTextField.text = @"";
    self.codeTextField.text = @"";
    
    // 删除红字提示
    if (self.passwordDetailsLabel) {
        self.passwordConfirmViewTopConstraint.constant = 10;
        [self.passwordConfirmTextField layoutIfNeeded];
        [self.passwordDetailsLabel removeFromSuperview];
        self.passwordDetailsLabel = nil;
    }
    if (self.passwordConfirmDetailsLabel) {
        self.codeViewTopConstraint.constant = 10;
        [self.codeTextField layoutIfNeeded];
        [self.passwordConfirmDetailsLabel removeFromSuperview];
        self.passwordConfirmDetailsLabel = nil;
    }
}

- (BOOL)isTextFieldEmpty {
    if (self.userNameTextField.text.length == 0 /* check user name available later */) {
        [self.userNameView shakeAnimation];
        return YES;
    } else  if (self.passwordTextField.text.length == 0 /*check password strong later*/) {
        [self.passwordView shakeAnimation];
        return YES;
    } else if (self.passwordConfirmTextField.text.length == 0) {
        [self.passwordConfirmView shakeAnimation];
        return YES;
    } else if (self.codeTextField.text.length == 0 /*check code match later*/) {
        [self.codeView shakeAnimation];
        return YES;
    }
    return NO;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [self getCodeAction:nil];
    }
    
    if (textField == self.userNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField) {
        [self.passwordConfirmTextField becomeFirstResponder];
    }
    if (textField == self.passwordConfirmTextField) {
        [self.codeTextField becomeFirstResponder];
    }
    if (textField == self.codeTextField) {
        [self registerAction:nil];
    }
    return true;
}


/**
 Check all textfield 
 Show details label if textfield requirement not match.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Add detail label for password textfield
    if (textField == self.passwordTextField) {
        if (![self ispasswordStrong:self.passwordTextField.text]) {
            if (!self.passwordDetailsLabel) {
                UILabel *label = [[UILabel alloc] init];
                label.textColor = [UIColor redColor];
                label.font = [UIFont systemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.numberOfLines = 0;
                label.text = @"Password at least 8 characters( letters and digits ).";
                [label sizeToFit];
                
                label.frame = CGRectMake(self.passwordView.frame.origin.x, CGRectGetMaxY(self.passwordView.frame) + 5, self.passwordView.frame.size.width, 36);
                
                self.passwordDetailsLabel = label;
                self.passwordConfirmViewTopConstraint.constant = 46;
                
                [textField layoutIfNeeded];
                [UIView animateWithDuration:0.4 animations:^{
                    [self.registerView layoutIfNeeded];
                    if (self.passwordConfirmDetailsLabel) {
                        self.passwordConfirmDetailsLabel.frame = CGRectMake(self.passwordConfirmView.frame.origin.x, CGRectGetMaxY(self.passwordConfirmView.frame) + 5, self.passwordConfirmView.frame.size.width, 30);
                    }
                } completion:^(BOOL finished) {
                    [self.registerView addSubview:self.passwordDetailsLabel];
                }];
            }
        } else {
            // Remove detail label for password textfield
            self.passwordConfirmViewTopConstraint.constant = 10;
            [textField layoutIfNeeded];
            [self.passwordDetailsLabel removeFromSuperview];
            self.passwordDetailsLabel = nil;
            [UIView animateWithDuration:0.4 animations:^{
                [self.registerView layoutIfNeeded];
                if (self.passwordConfirmDetailsLabel) {
                    self.passwordConfirmDetailsLabel.frame = CGRectMake(self.passwordConfirmView.frame.origin.x, CGRectGetMaxY(self.passwordConfirmView.frame) + 5, self.passwordConfirmView.frame.size.width, 30);
                }
                
            } completion: nil];
        }
    }
    // Add detail label for password confrim textfield
    if (textField == self.passwordConfirmTextField) {
        if (textField.text.length > 0 && ![textField.text isEqualToString:self.passwordTextField.text]) {
            
            if (!self.passwordConfirmDetailsLabel) {
                UILabel *label = [[UILabel alloc] init];
                label.textColor = [UIColor redColor];
                label.font = [UIFont systemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.frame = CGRectMake(self.passwordConfirmView.frame.origin.x, CGRectGetMaxY(self.passwordConfirmView.frame) + 5, self.passwordConfirmView.frame.size.width, 30);
                label.text = @"password are not match.";
                self.codeViewTopConstraint.constant = 40;
                self.passwordConfirmDetailsLabel = label;
                [textField layoutIfNeeded];
                [UIView animateWithDuration:0.4 animations:^{
                    [self.registerView layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self.registerView addSubview:self.passwordConfirmDetailsLabel];
                }];
            }
        } else {
            // Remove detail label for password confirm textfield
            self.codeViewTopConstraint.constant = 10;
            [textField layoutIfNeeded];
            [self.passwordConfirmDetailsLabel removeFromSuperview];
            self.passwordConfirmDetailsLabel = nil;
            
            [UIView animateWithDuration:0.4 animations:^{
                [self.registerView layoutIfNeeded];

            } completion: nil];
        }
    }
}

// Password regex check
- (BOOL)ispasswordStrong:(NSString *)passwordString {
    NSPredicate *regexPassword = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?=.{6,32}$)(?=.*\\d)(?=.*[a-zA-Z]).*$"];

    return [regexPassword evaluateWithObject:passwordString];
}

// Email regex check
-(BOOL)isValidEmail:(NSString *)emailString
{
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
