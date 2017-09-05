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
#import <MBProgressHUD.h>

@interface BRUserAccountSetUpViewController ()
{
    NSString *email;
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewRightContraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailConentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailContentViewRightConstraint;
@end

@implementation BRUserAccountSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 修改背景图片
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
    self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getCodeAction:(id)sender {
    [self.view endEditing:YES];
    
    email = self.emailTextField.text;
    if (email.length == 0) {
        self.emailConentViewLeftConstraint.constant = 40;
        self.emailContentViewRightConstraint.constant = 60;
        
        self.emailConentViewLeftConstraint.constant = 60;
        self.emailContentViewRightConstraint.constant = 40;
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.15 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.emailConentViewLeftConstraint.constant = 50;
            self.emailContentViewRightConstraint.constant = 50;
        }];
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
            self.emailViewRightContraint.constant = SCREEN_WIDTH;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
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
        self.registerViewLeftConstraint.constant = SCREEN_WIDTH;
        self.registerViewRightConstraint.constant = -SCREEN_WIDTH;
        
        self.emailViewLeftConstraint.constant = 0;
        self.emailViewRightContraint.constant = 0;
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
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *userName = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *code = self.codeTextField.text;
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/confirm"];
    NSDictionary *parameters = @{
                                 @"username":userName,
                                 @"password":password,
                                 @"email":email,
                                 @"code":code
                                 };
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            [hud hideAnimated:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
            BRUserInfoSetUpTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UserInfoQuickSetup"];
            [self.navigationController pushViewController:vc animated:YES];
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

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
