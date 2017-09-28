//
//  BRAddingFriendViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRAddingFriendViewController.h"
#import "BRScannerViewController.h"
#import "BRFriendInfoTableViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "BRFriendRequestTableViewController.h"

@interface BRAddingFriendViewController () <UITextFieldDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *friendIDTextField;

@end

@implementation BRAddingFriendViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)searchByID:(NSString *)searchID {
  
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefaults objectForKey:kLoginUserNameKey];
    
    // 不能添加自己
    if ([self.friendIDTextField.text isEqualToString:savedUserName]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Can not add yourself.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRFriendRequestTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendRequestTableViewController"];
    vc.searchID = self.friendIDTextField.text;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
//    BRFriendInfoTableViewController
    [self presentViewController:nav animated:YES completion:nil];
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
        [self searchByID:textField.text];
    }
    return YES;
}

@end
