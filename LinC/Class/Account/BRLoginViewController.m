//
//  BRLoginViewController.m
//  LinC
//
//  Created by zhe wu on 8/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRTabBarController.h"
#import "BRResetPasswordViewController.h"
#import "BRHTTPSessionManager.h"
#import "UIView+Animation.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <Hyphenate/Hyphenate.h>
#import <SAMKeychain.h>



@interface BRLoginViewController () <UITextFieldDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;



@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefaults objectForKey:kLoginUserNameKey];
    
//    NSString *savedPassword = [[[SAMKeychain accountsForService:kLoginPasswordKey] lastObject] objectForKey:@"acct"];
    NSString *savedPassword = [SAMKeychain passwordForService:kServiceName account:savedUserName];
    
    if (savedUserName) {
        self.userNameTextField.text = savedUserName;
    }
    if (savedPassword) {
        self.passwordTextField.text = savedPassword;
    }
}

- (IBAction)login {
    // 收起键盘
    [self.view endEditing:YES];
    
    NSString *userName = self.userNameTextField.text;
    if (userName.length == 0) {
        // 抖动提示用户
        [self.userNameView shakeAnimation];
        [self.userNameTextField becomeFirstResponder];
        return;
    }
    NSString *password = self.passwordTextField.text;
    if (password.length == 0) {
        // 抖动提示用户
        [self.passwordView shakeAnimation];
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/login"];
    NSDictionary *parameters;
    if ([userName containsString:@"@"] && [userName containsString:@"."]) {
        parameters = @{@"email":userName, @"password":password};
    }
    else {
        parameters = @{@"username":userName, @"password":password};
    }
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        // 登录成功
        if ([dict[@"status"] isEqualToString:@"success"]) {
            [hud hideAnimated:YES];
            
            // 存储用户名, token和密码
            NSError *error = nil;

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userName forKey:kLoginUserNameKey];
            [userDefaults synchronize];
            
            [SAMKeychain setPassword:dict[@"data"][@"token"] forService:kServiceName account:userName error:&error];
            [SAMKeychain setPassword:password forService:kLoginUserNameKey account:userName];
            EMError *loginError = [[EMClient sharedClient] loginWithUsername:userName password: password];
            
            if (!loginError) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
                [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
            }
            
        }
        // 登录失败
        else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = dict[@"message"];
            [hud hideAnimated:YES afterDelay:1.5];
            
            [self.passwordTextField becomeFirstResponder];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
}

- (IBAction)clickForgetPassword {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    BRResetPasswordViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRResetPasswordViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

// Email regex check
-(BOOL)isValidEmail:(NSString *)emailString
{
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self login];
    return YES;
}

@end
