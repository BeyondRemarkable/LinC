//
//  BRAboutViewController.m
//  LinC
//
//  Created by Yingwei Fan on 10/26/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRAboutViewController.h"
#import <SAMKeychain.h>

@interface BRAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@end

@implementation BRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDict[@"CFBundleShortVersionString"];
    NSString *appBuildVersion = infoDict[@"CFBundleVersion"];
    self.appVersionLabel.text = [NSString stringWithFormat:@"LinC %@.%@", appVersion, appBuildVersion];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    NSLog(@"token: %@", token);
}


@end
