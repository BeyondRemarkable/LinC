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

@interface BRAddingFriendViewController () <UITextFieldDelegate>

@end

@implementation BRAddingFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setupNavigationBarItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)setupNavigationBarItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)searchByID:(NSString *)ID {
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
    
//    BRFriendInfoTableViewController
    [self.navigationController pushViewController:vc animated:YES];
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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
