//
//  WhatsUpViewController.m
//  LinC
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRWhatsUpViewController.h"

@interface BRWhatsUpViewController ()
@property (weak, nonatomic) IBOutlet UITextView *whatsUpTextView;
@end

@implementation BRWhatsUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.whatsUpTextView.textContainerInset = UIEdgeInsetsZero;
    
    if ([self.whatUpText isEqual: @"Detail"]) {
        self.whatsUpTextView.text = nil;
    } else {
        self.whatsUpTextView.text = self.whatUpText;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveBtn:(id)sender {
    
    if (![self.whatsUpTextView.text isEqualToString:self.whatUpText]) {
        [self.delegate sendWhatUpBack:self.whatsUpTextView.text];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}




@end
