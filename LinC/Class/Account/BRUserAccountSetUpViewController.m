//
//  BRUserInfoSetUpViewController.m
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserAccountSetUpViewController.h"

@interface BRUserAccountSetUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwd;

@end

@implementation BRUserAccountSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextBtn:(id)sender {

}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
