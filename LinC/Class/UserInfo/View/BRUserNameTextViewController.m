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
    
    self.userNameTextField.text = self.nameText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveBtn:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
