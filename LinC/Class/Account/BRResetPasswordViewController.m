//
//  BRResetPasswordViewController.m
//  LinC
//
//  Created by zhe wu on 9/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRResetPasswordViewController.h"

@interface BRResetPasswordViewController ()

@end

@implementation BRResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.navigationController.navigationBar.hidden = NO;
}

- (IBAction)backBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
