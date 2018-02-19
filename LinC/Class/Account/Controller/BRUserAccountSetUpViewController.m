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

@interface BRUserAccountSetUpViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSString *email;
    NSString *phoneNumber;
    MBProgressHUD *hud;
    NSDictionary *areaCodeDict;
    NSArray *areaCodeArray;
}

// Input text field
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *areaCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

// Constraints for layout email view and register view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewRightConstraint;


// Constraints for adding details labels
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordConfirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeViewTopConstraint;

// All subviews
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIView *emailRegisterView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *phoneRegisterView;
@property (weak, nonatomic) IBOutlet UIView *areaCodeView;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *passwordConfirmView;
@property (weak, nonatomic) IBOutlet UIView *codeView;

// Detail Labels
@property (nonatomic, strong) UILabel *userNameDetailsLabel;
@property (nonatomic, strong) UILabel *passwordDetailsLabel;
@property (nonatomic, strong) UILabel *passwordConfirmDetailsLabel;

// picker view for area code
@property (nonatomic, strong) UIPickerView *areaCodePickerView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BRUserAccountSetUpViewController

- (UIPickerView *)areaCodePickerView {
    if (_areaCodePickerView == nil) {
        _areaCodePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
        _areaCodePickerView.backgroundColor = [UIColor clearColor];
        _areaCodePickerView.delegate = self;
        _areaCodePickerView.dataSource = self;
    }
    return _areaCodePickerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpTextFeildDelegate];
    [self setUpRegisterUI];
    
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

- (void)setUpRegisterUI {
    self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
    self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
    
    switch (self.registerType) {
        case BRRegisterTypeEmail:
            self.phoneRegisterView.hidden = YES;
            [self.emailTextField becomeFirstResponder];
            break;
            
        case BRRegisterTypeMobile:
            self.emailRegisterView.hidden = YES;
            [self.areaCodeTextField becomeFirstResponder];
            break;
    }
    
    self.areaCodeTextField.inputView = self.areaCodePickerView;
    areaCodeDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Area Code" ofType:@"plist"]];
    areaCodeArray = areaCodeDict.allKeys;
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

- (IBAction)getCodeAction:(UIButton *)sender {
    [self.view endEditing:YES];

    switch (self.registerType) {
        case BRRegisterTypeEmail: {
            email = self.emailTextField.text;
            if (email.length == 0) {
                [self.emailView shakeAnimation];
                return;
            } else if(![self isValidEmail:email]) {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Invalid email address";
                [hud hideAnimated:YES afterDelay:1.5];
                return;
            }

            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[BRClientManager sharedManager] getCodeWithEmail:email success:^{
                [hud hideAnimated:YES];
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.registerViewLeftConstraint.constant = 0;
                    self.registerViewRightConstraint.constant = 0;

                    self.emailViewLeftConstraint.constant = -SCREEN_WIDTH;
                    self.emailViewRightConstraint.constant = SCREEN_WIDTH;
                    
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self.userNameTextField becomeFirstResponder];
                }];

                // 清空emailTextField
                self.emailTextField.text = @"";
            } failure:^(EMError *error) {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = error.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
            }];
            break;
        }
            
        case BRRegisterTypeMobile: {
            if (self.areaCodeTextField.text.length == 0) {
                [self.areaCodeView shakeAnimation];
                return;
            }
            if (self.phoneNumberTextField.text.length == 0) {
                [self.phoneNumberView shakeAnimation];
                return;
            }
            phoneNumber = [NSString stringWithFormat:@"%@%@", self.areaCodeTextField.text, self.phoneNumberTextField.text];
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            [[BRClientManager sharedManager] getcodeWithPhoneNumber:phoneNumber success:^{
                [hud hideAnimated:YES];
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.registerViewLeftConstraint.constant = 0;
                    self.registerViewRightConstraint.constant = 0;
                    
                    self.phoneViewLeftConstraint.constant = -SCREEN_WIDTH;
                    self.phoneViewRightConstraint.constant = SCREEN_WIDTH;
                    
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                    }];
                    [hud hideAnimated:YES];
                    [self.userNameTextField becomeFirstResponder];
                }];
                
                // 清空emailTextField
                self.areaCodeTextField.text = @"";
                self.phoneNumberTextField.text = @"";
            } failure:^(EMError *error) {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = error.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
            }];
            break;
        }
    }
}

- (IBAction)resendAction:(id)sender {
    [self.view endEditing:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *title = self.registerType == BRRegisterTypeEmail ? @"Use different email" : @"Use different phone number";
    [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearRegisterInformation];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // 平移动画
            self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
            self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
            if (self.registerType == BRRegisterTypeEmail) {
                self.emailViewLeftConstraint.constant = 0;
                self.emailViewRightConstraint.constant = 0;
            }
            else if (self.registerType == BRRegisterTypeMobile) {
                self.phoneViewLeftConstraint.constant = 0;
                self.phoneViewRightConstraint.constant = 0;
                [self.areaCodePickerView selectRow:0 inComponent:0 animated:NO];
            }
            [self.view layoutIfNeeded];
        } completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Resend code" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        switch (self.registerType) {
            case BRRegisterTypeEmail: {
                [[BRClientManager sharedManager] getCodeWithEmail:email success:^{
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"Sent successfully";
                    [hud hideAnimated:YES afterDelay:1.5];
                } failure:^(EMError *error) {
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = error.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }];
                break;
            }
                
            case BRRegisterTypeMobile: {
                if (self.timer.isValid) {
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = NSLocalizedString(@"Code is sent, please try again later", nil);
                    [hud hideAnimated:YES afterDelay:2.0];
                    break;
                }
                [[BRClientManager sharedManager] getcodeWithPhoneNumber:phoneNumber success:^{
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"Sent successfully";
                    [hud hideAnimated:YES afterDelay:1.5];
                    
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                    }];
                } failure:^(EMError *error) {
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = error.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }];
                break;
            }
        }
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
    void (^successBlock)(NSString*, NSString*) = ^(NSString *username, NSString *password) {
        // 注册完成后执行登录
        [[BRClientManager sharedManager] loginWithUsername:username password:password success:^(NSString *username) {
            [hud hideAnimated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
        } failure:^(EMError *error) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = error.errorDescription;
            hud.label.numberOfLines = 0;
            [hud hideAnimated:YES afterDelay:1.5];
        }];
    };
    
    void (^failureBlock)(EMError *) = ^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        hud.label.numberOfLines = 0;
        [hud hideAnimated:YES afterDelay:1.5];
    };
    switch (self.registerType) {
        case BRRegisterTypeEmail:
            [[BRClientManager sharedManager] registerWithEmail:email phoneNumber:nil username:self.userNameTextField.text password:self.passwordTextField.text code:self.codeTextField.text success:successBlock failure:failureBlock];
            break;
            
        case BRRegisterTypeMobile:
            [[BRClientManager sharedManager]  registerWithEmail:nil phoneNumber:phoneNumber username:self.userNameTextField.text password:self.passwordTextField.text code:self.codeTextField.text success:successBlock failure:failureBlock];
            break;
    }
    
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
    
    if (textField == self.phoneNumberTextField) {
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
    if (textField == self.userNameTextField) {
        if (textField.text.length > 0 && ![self isVaildUserName:textField.text]) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Only contains letters and digits";
            hud.label.numberOfLines = 0;
            [hud hideAnimated:YES afterDelay:2.0];
            self.userNameTextField.text = @"";
        }
    }
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

// 输入用户名只能包含字母和数字
- (BOOL)isVaildUserName:(NSString *)userName {
    if (userName.length == 0) return NO;
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:userName];
}

- (BOOL)inputShouldLetterOrNum:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return areaCodeArray.count;
}

#pragma mark - UIPickViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return areaCodeArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.areaCodeTextField.text = areaCodeDict[areaCodeArray[row]];
}


@end
