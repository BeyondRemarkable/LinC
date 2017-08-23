//
//  UserNameTextViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserNameTextViewController.h"

@interface BRUserNameTextViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;


@end

@implementation BRUserNameTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self.nameText isEqualToString: @"Detail"]) {
        self.userNameTextField.text = nil;
    } else {
        self.userNameTextField.text = self.nameText;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBtn:(id)sender {
    [self.delegate sendUserNameBack:self.userNameTextField.text];
    [self.navigationController popViewControllerAnimated:YES];
}


@end