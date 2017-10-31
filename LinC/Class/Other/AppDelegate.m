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
    NSString *apnsCertName = @"BeyondRemarkableLinc";
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
    
    EMPushOptions *emoptions = [[EMClient sharedClient] pushOptions];
    
    //设置有消息过来时的显示方式:1.显示收到一条消息2.显示具体消息内容.
    
    //自己可以测试下
    
    emoptions.displayStyle = EMPushDisplayStyleMessageSummary;
    
    [[EMClient sharedClient] updatePushOptionsToServer];

/**
 
 注册APNS离线推送iOS8注册APNS
 
 */

if([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
    
    [application registerForRemoteNotifications];
    
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge| UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes: notificationTypes categories:nil];
    
    [application registerUserNotificationSettings:settings];
    
}

    
else{
    
    UIRemoteNotificationType notificationTypes =UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:notificationTypes];
    
}

//添加监听在线推送消息

[[EMClient sharedClient].chatManager addDelegate: self delegateQueue:nil];

return YES;

}

//监听环信在线推送消息

- (void)messagesDidReceive:(NSArray*)aMessages{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString  stringWithFormat:@"%@",aMessages] delegate: nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    
    [alertView show];
    
    //aMessages是一个对象,包含了发过来的所有信息,怎么提取想要的信息我会在后面贴出来.
    
}

//将得到的deviceToken传给SDK

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSLog(@"deviceToken--%@", deviceToken );
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
    
}

//注册deviceToken失败

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    
    NSLog(@"deviceToken--error -- %@",error);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
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
