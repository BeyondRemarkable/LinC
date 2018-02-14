//
//  BRAddedFriendTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRRequestMessageTableViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>
#import "BRSDKHelper.h"

@interface BRRequestMessageTableViewController ()<UITextFieldDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *userMessage;

@end

@implementation BRRequestMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userMessage.delegate = self;
    [self setUpNavigationBarItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Add save and cancel buttons to navigation bar
- (void)setUpNavigationBarItem {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStylePlain target:self action:@selector(sendBtn)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn)];
}

/**
    发送好友请求
 */
- (void)sendBtn {
    [self.view endEditing:YES];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMessage *message = nil;
    if (self.doesJoinGroup && self.groupID) {
        NSString *groupKey = [[kBRGroupRequestExtKey stringByAppendingString:@":"] stringByAppendingString:self.groupID];
        // 构建群请求消息
        message = [BRSDKHelper getTextMessage:self.userMessage.text
                                                       to:self.groupOwner
                                              messageType:EMChatTypeChat
                                               messageExt: @{@"em_apns_ext":@{@"extern":groupKey}}];
        
        [[EMClient sharedClient].groupManager applyJoinPublicGroup:self.groupID message:nil error:nil];

        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
            hud.mode = MBProgressHUDModeText;
            if (aError) {
                hud.label.text = aError.errorDescription;
            }
            else {
                hud.label.text = @"Send Successfully";
                [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.5];
            }
            [hud hideAnimated:YES afterDelay:1.5];
        }];
        
    } else {
        // 构建好友请求消息
        message = [BRSDKHelper getTextMessage:self.userMessage.text
                                            to:self.searchID
                                   messageType:EMChatTypeChat
                                    messageExt: @{@"em_apns_ext":@{@"extern":kBRFriendRequestExtKey}}];
    }
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        hud.mode = MBProgressHUDModeText;
        if (aError) {
            hud.label.text = aError.errorDescription;
        }
        else {
            hud.label.text = @"Send Successfully";
            [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.5];
        }
        [hud hideAnimated:YES afterDelay:1.5];
    }];
   

}

- (void)dismissVC {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtn {
    [self dismissVC];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendBtn];
    return YES;
}

@end
