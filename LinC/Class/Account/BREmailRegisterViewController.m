//
//  BREmailRegisterViewController.m
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BREmailRegisterViewController.h"
#import "BRLoginViewController.h"

@interface BREmailRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;

@end

@implementation BREmailRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendBtn:(id)sender {
}
- (IBAction)backBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
