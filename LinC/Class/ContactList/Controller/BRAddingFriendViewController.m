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

@interface BRAddingFriendViewController ()

@end

@implementation BRAddingFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setUpNavigationBarItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNavigationBarItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)searchByID {
    
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

@end
