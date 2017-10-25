//
//  AppDelegate.m
//  LinC
//
//  Created by Yingwei Fan on 8/7/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "AppDelegate.h"
#import "BRSDKHelper.h"
#import <Hyphenate/Hyphenate.h>
#import "BRTabBarController.h"
#import "BRLoginViewController.h"
#import "BRClientManager.h"
#import <SAMKeychain.h>
#import "BRCoreDataManager.h"


@interface AppDelegate () <EMClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *appkey = @"1153170608178531#linc-dev";
    NSString *apnsCertName = @"";
    [[BRSDKHelper shareHelper] hyphenateApplication:application
                      didFinishLaunchingWithOptions:launchOptions
                                             appkey:appkey
                                       apnsCertName:apnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    if ([EMClient sharedClient].options.isAutoLogin) {
        // 之前登录过，可以显示主界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
        
        self.window.rootViewController = vc;
        // 检查是否token过期
        [self updateAuthorization];
    } else {
        [self showStoryboardWithName:@"Account" identifier:@"BRLoginViewController"];
    }
    [self setupOptions];
    
    //初始化数据库
    [[BRCoreDataManager sharedInstance] managedObjectContext];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - self-defined methods
- (void)setupOptions {
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].options setIsAutoAcceptGroupInvitation:YES];
}

- (void)showStoryboardWithName:(NSString *)name identifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]];
    BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.window.rootViewController = vc;
}

- (void)updateAuthorization {
    [[BRClientManager sharedManager] getSelfInfoWithSuccess:^(BRContactListModel *model) {
        [self showStoryboardWithName:@"Main" identifier:@"BRTabBarController"];
    } failure:^(EMError *error) {
        if ([error.errorDescription containsString:@"(401)"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
            NSString *password = [SAMKeychain passwordForService:kLoginPasswordKey account:username];
            [[BRClientManager sharedManager] loginWithUsername:username password:password success:^(NSString *message) {
                [self showStoryboardWithName:@"Main" identifier:@"BRTabBarController"];
            } failure:^(EMError *error) {
                NSLog(@"%@", error.errorDescription);
            }];
        }
    }];
}

@end
