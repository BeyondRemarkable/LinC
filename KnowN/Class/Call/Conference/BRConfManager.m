 //
//  BRConfManager.m
//
//  Copyright © 2016 zhe wu. All rights reserved.
//

#import "BRConfManager.h"
#import <Hyphenate/Hyphenate.h>
#import "BRConfManager.h"
#import "BRConfUserSelectionViewController.h"
#import "BRConferenceViewController.h"
#import "BRSDKHelper.h"
#import "BRMessageViewController.h"
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"

static BRConfManager *confManager = nil;

@interface BRConfManager()<EMConferenceManagerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) BRConferenceViewController *currentController;
@property (strong, nonatomic) NSString *groupID;
@end

@implementation BRConfManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        confManager = [[BRConfManager alloc] init];
    });
    
    return confManager;
}

- (void)dealloc
{
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (void)_initManager
{
    _currentController = nil;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    EMConferenceMode model = EMConferenceModeLarge;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *requestData = [userDefaults objectForKey:KBRAudioConferenceInviteExtKey];
    if (requestData) {
        [self receiveConferenceInvite: requestData];
    }
    id obj = [userDefaults objectForKey:@"audioMix"];
    if (obj) {
        model = (EMConferenceMode)[obj integerValue];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInteger:model] forKey:@"audioMix"];
        [userDefaults synchronize];
    }
    [[EMClient sharedClient].conferenceManager setMode:model];
}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidRecvInvite:(NSString *)aConfId
                 password:(NSString *)aPassword
                      ext:(NSString *)aExt
{
//    if ([BRAudioCallManager sharedManager].isCalling) {
//        return;
//    }

    NSData *jsonData = [aExt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *creater = [dic objectForKey:@"creater"];
    NSString *groupID = [dic objectForKey:@"groupID"];
    
    if (aConfId && creater && groupID) {
        self.currentController = [[BRConferenceViewController alloc] initWithJoinConferenceId:aConfId creater:creater andGroupID:groupID];
        UITabBarController *tac = (UITabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav = tac.viewControllers[tac.selectedIndex];
        UIViewController *v = [nav.childViewControllers lastObject];
        [v presentViewController:self.currentController animated:YES completion:nil];
    }
}

#pragma mark - conference

- (void)createConferenceWithFriendsList:(NSMutableArray *)friendArray fromGroupID:(NSString *)groupID
{
    
    self.currentController = [[BRConferenceViewController alloc] initWithCreateConference:friendArray andGroupID:groupID];
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self.currentController];
    UITabBarController *tac = (UITabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = tac.viewControllers[tac.selectedIndex];
    for (UIViewController *vc in nav.childViewControllers) {
        if ([vc isKindOfClass:[BRMessageViewController class]]) {
            [vc presentViewController:navc animated:YES completion:nil];
            break;
        }
    }
}

- (void)pushCustomVideoConferenceController
{
//    [[BRAudioCallManager sharedManager] setIsCalling:YES];
    
//    BRConferenceViewController *confController = [[BRConferenceViewController alloc] initVideoCallWithIsCustomData:YES];
//    [self.mainController.navigationController pushViewController:confController animated:NO];
}

- (void)receiveConferenceInvite:(NSDictionary *)conferenceData {
    
    NSString *externString = [conferenceData objectForKey:@"e"];
    NSString *confID = [externString componentsSeparatedByString:@":"][1];
    self.groupID = [externString componentsSeparatedByString:@":"][2];
    NSString *creater = [externString componentsSeparatedByString:@":"][3];
    if (confID && self.groupID && creater) {
        BRConferenceViewController *callVC = [[BRConferenceViewController alloc] initWithJoinConferenceId:confID creater:creater andGroupID: self.groupID];
        callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        UITabBarController *tac = (UITabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav1 = tac.viewControllers[tac.selectedIndex];
        UIViewController *v = [nav1.childViewControllers lastObject];
        [v presentViewController:callVC animated:YES completion:nil];
    }
    
}


@end
