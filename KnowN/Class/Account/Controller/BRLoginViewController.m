//
//  BRLoginViewController.m
//  KnowN
//
//  Created by zhe wu on 8/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRTabBarController.h"
#import "BRResetPasswordViewController.h"
#import "BRHTTPSessionManager.h"
#import "UIView+Animation.h"
#import "BRClientManager.h"
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <Hyphenate/Hyphenate.h>
#import <SAMKeychain.h>



@interface BRLoginViewController () <UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;


@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    // 从userdefault和keychai 获取用户名 密码
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefaults objectForKey:kLoginUserNameKey];

    NSString *savedPassword = [SAMKeychain passwordForService:kLoginPasswordKey account:savedUserName];
    
    if (savedUserName) {
        self.userNameTextField.text = savedUserName;
    }
    if (savedPassword) {
        self.passwordTextField.text = savedPassword;
    }
    
    BRUserInfo *userInfo = [[BRCoreDataManager sharedInstance] getUserInfo];
    if (userInfo.avatar) {
        UIImage *avatarImage = [UIImage imageWithData:userInfo.avatar];
        self.userAvatarView.image = avatarImage;
        self.userAvatarView.hidden = NO;
        self.userAvatarView.layer.cornerRadius = 5.0f;
        self.userAvatarView.layer.masksToBounds = YES;
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
    
    // 用我们服务器做登录
    [[BRClientManager sharedManager] loginWithUsername:userName password:password success:^(NSString *username) {
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
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        return YES;
    }
    if (self.userNameTextField.text.length && self.passwordTextField.text.length) {
        [self login];
    }
    else if (textField == self.userNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.userNameTextField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Sign Up Method"]) {
        UIPopoverPresentationController *ppc = segue.destinationViewController.popoverPresentationController;
        ppc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        CGRect rect = self.signUpButton.bounds;
        rect.origin.y -= 5;
        ppc.sourceRect = rect;
        ppc.delegate = self;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
