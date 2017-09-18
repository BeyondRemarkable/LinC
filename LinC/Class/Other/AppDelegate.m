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
#import "BRHTTPSessionManager.h"
#import "BRClientManager.h"
#import <SAMKeychain.h>

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *password = [SAMKeychain passwordForService:kLoginPasswordKey account:userName];
    
    if ([EMClient sharedClient].options.isAutoLogin) {
        
        [[BRClientManager sharedManager] loginWithUsername:userName password:password success:^(NSString *username) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
            [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
        } failure:^(EMError *error) {
            NSLog(@"%@", error.errorDescription);
        }];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        BRLoginViewController *loginVc = [storyboard instantiateInitialViewController];
        self.window.rootViewController = loginVc;
    }
    
    
//    if (token) {
//        BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSString *token = [userDefaults objectForKey:kLoginTokenKey];
//        [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
//        NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/profile/show"];
//        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSDictionary * dict = (NSDictionary *)responseObject;
//            if ([dict[@"status"] isEqualToString:@"success"]) {
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                BRTabBarController *mainVc = [storyboard instantiateInitialViewController];
//                self.window.rootViewController = mainVc;
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            
//        }];
//    }
//    else {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
//
//        BRLoginViewController *loginVc = [storyboard instantiateInitialViewController];
//        self.window.rootViewController = loginVc;
//    }
    
    
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

@end
