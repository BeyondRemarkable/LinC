//
//  BRAddedFriendTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRAddedFriendTableViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRAddedFriendTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *userMessage;

@end

@implementation BRAddedFriendTableViewController

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

// Send add friend request to server
- (void)sendBtn {
    
    [self.view endEditing:YES];
    EMError *error = [[EMClient sharedClient].contactManager addContact:self.userID message: self.userMessage.text];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    if (error) {
        hud.label.text = error.errorDescription;
        
    } else {
        hud.label.text = @"Send Successfully";
        [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
    }
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
