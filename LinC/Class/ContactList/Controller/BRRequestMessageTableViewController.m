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

@interface BRRequestMessageTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *userMessage;

@end

@implementation BRRequestMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    // 构建需要发送的message
    EMMessage *message = [BRSDKHelper sendTextMessage:self.userMessage.text
                                                   to:self.userID
                                          messageType:EMChatTypeChat
                                           messageExt: @{@"em_apns_ext":@{@"extern":kBRFriendRequestExtKey}}];
    
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
    
    
//    [[EMClient sharedClient].contactManager addContact:self.userID message:self.userMessage.text completion:^(NSString *aUsername, EMError *aError) {
//        if (aError) {
//            hud.mode = MBProgressHUDModeText;
//            hud.label.text = aError.errorDescription;
//        } else {
//            hud.label.text = @"Send Successfully";
//            [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
//        }
//        [hud hideAnimated:YES afterDelay:1.5];
//    }];
    
//    EMError *error = [[EMClient sharedClient].contactManager addContact:self.userID message: self.userMessage.text];
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        if (error) {
//            hud.label.text = error.errorDescription;
//
//        } else {
//            hud.label.text = @"Send Successfully";
//        }
//
//    [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
//    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtn {
    [self dismissVC];
}

@end
