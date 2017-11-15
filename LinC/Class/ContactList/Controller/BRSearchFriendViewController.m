//
//  BRAddingFriendViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRSearchFriendViewController.h"
#import "BRScannerViewController.h"
#import "BRFriendInfoTableViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "BRFriendRequestTableViewController.h"
#import <SAMKeychain.h>
#import "BRClientManager.h"

@interface BRSearchFriendViewController () <UITextFieldDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *friendIDTextField;

@end

@implementation BRSearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.friendIDTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self setupNavigationBarItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO];
}

// Set up Nagigation Bar Items
- (void)setupNavigationBarItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)searchByID {
  
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    
    // 不能添加自己
    if ([self.friendIDTextField.text isEqualToString:currentUsername]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Can not add yourself.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] getUserInfoWithUsernames:[NSArray arrayWithObject:self.friendIDTextField.text] andSaveFlag:NO success:^(NSMutableArray *aList) {
        [hud hideAnimated:YES];
        
        BRContactListModel *model = [aList firstObject];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendInfoTableViewController"];
        vc.contactListModel = model;
        // 如果已经是好友
        NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
        if ([contactArray containsObject:self.friendIDTextField.text]) {
            vc.isFriend = YES;
        }
        else {
            vc.isFriend = NO;
        }
        // Push BRFriendInfoTableViewController
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(EMError *aError) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = aError.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (IBAction)scanQRCodeBtn {
    BRScannerViewController *vc = [[BRScannerViewController alloc] initWithNibName:@"BRScannerViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
//    [self presentViewController:vc animated:YES completion: nil];
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self searchByID];
    }
    return YES;
}

@end
