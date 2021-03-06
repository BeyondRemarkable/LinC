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
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRFileWithNewFriendsRequestData.h"

@interface AppDelegate () <EMClientDelegate, EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *appkey = @"1153170608178531#linc-dev";
    NSString *apnsCertName = @"pushCertificates";
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
    
    emoptions.displayStyle = EMPushDisplayStyleMessageSummary;
    
    [[EMClient sharedClient] updatePushOptionsToServer];

if([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
    
    [application registerForRemoteNotifications];
    
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge| UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes: notificationTypes categories:nil];
    
    [application registerUserNotificationSettings:settings];
    
}

    //添加监听在线推送消息
    [[EMClient sharedClient].chatManager addDelegate: self delegateQueue:nil];

    return YES;
}

//监听环信在线推送消息
-(void)didReceiveMessages:(NSArray *)aMessages{
    
    //判断是不是后台，如果是后台就发推送
    if (aMessages.count == 0) {
        return ;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:@"receivedMessage"];
    for (EMMessage *message in aMessages) {
        UIApplicationState state =[[UIApplication sharedApplication] applicationState];
        switch (state) {
                //前台运行
            case UIApplicationStateActive:
                [self showPushNotificationMessage:message];
                break;
                //待激活状态
            case UIApplicationStateInactive:
                break;
                //后台状态
            case UIApplicationStateBackground:
                [self showPushNotificationMessage:message];
                break;
            default:
                break;
        }
    }
}

-(void)showPushNotificationMessage:(EMMessage *)message{
    NSString *friendReqFlag = [message.ext valueForKeyPath:@"em_apns_ext.extern"];
    if (friendReqFlag && [kBRFriendRequestExtKey isEqualToString:friendReqFlag]) {
        NSDictionary *friendDict = [NSDictionary dictionaryWithObjectsAndKeys:((EMTextMessageBody *)message.body).text, @"message", message.from ,@"userID" ,nil];
        [BRFileWithNewFriendsRequestData savedToPlistWithData:friendDict];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:message.from];
        if (friendInfo.nickname) {
            notification.alertTitle = friendInfo.nickname;
        } else {
            notification.alertTitle = friendInfo.username;
        }
        notification.fireDate = [NSDate date];
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.alertBody = @"Friend request";
        notification.timeZone = [NSTimeZone defaultTimeZone];
        [UIApplication sharedApplication].applicationIconBadgeNumber +=1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        return;
    }
    
    
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
                
            case EMMessageBodyTypeText:
                messageStr = ((EMTextMessageBody *)messageBody).text;
                break;
            case EMMessageBodyTypeImage:
                messageStr = NSLocalizedString(@"Image Received.", @"Image");
                break;
            case EMMessageBodyTypeLocation:
                messageStr = NSLocalizedString(@"Shared location.", @"Location");
                break;
            case EMMessageBodyTypeVoice:
                messageStr = NSLocalizedString(@"Voice message", @"Voice");
                break;
            case EMMessageBodyTypeVideo:
                messageStr = NSLocalizedString(@"Shared video", @"Video");
                break;
            default:
                break;
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:message.from];
        if (friendInfo.nickname) {
            notification.alertTitle = friendInfo.nickname;
        } else {
            notification.alertTitle = friendInfo.username;
        }
        notification.fireDate = [NSDate date];
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.alertBody = messageStr;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        [UIApplication sharedApplication].applicationIconBadgeNumber +=1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if (application.applicationState == UIApplicationStateActive) return;
    
    if (application.applicationState == UIApplicationStateInactive) {
        // 当应用在后台收到本地通知时执行的跳转代码
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

//将得到的deviceToken传给SDK
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

//注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"deviceToken--error -- %@",error);
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
