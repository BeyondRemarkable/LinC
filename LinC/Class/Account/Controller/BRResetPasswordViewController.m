//
//  BRResetPasswordViewController.m
//  LinC
//
//  Created by zhe wu on 9/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRResetPasswordViewController.h"
#import "BRHTTPSessionManager.h"
#import "UIView+Animation.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>

@interface BRResetPasswordViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *emailID;
@property (weak, nonatomic) IBOutlet UIView *emailContentView;

@end

@implementation BRResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    
}
- (IBAction)backBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)resetPasswordBtn {
    
    if (self.emailID.text.length == 0) {
        [self.emailContentView shakeAnimation];
        return;
    }
    
    NSString *email = self.emailID.text;
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/password/reset"];
    NSDictionary *parameters = @{@"email" : email};
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            hud.mode = MBProgressHUDModeText;
            hud.label.text = dict[@"message"];
            NSLog(@"%@", hud.label.text);

            if ([dict[@"status"] isEqualToString:@"success"]) {
            
                [self performSelector:@selector(resetPassword) withObject:nil afterDelay:1.0f];
            } else {
                [hud hideAnimated:YES afterDelay:1.5];
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES afterDelay:1.0];
        NSLog(@"%@", error.localizedDescription);
    }];

}

- (void)resetPassword {
    [hud hideAnimated:YES];
    [self backBtn];
    }

@end
