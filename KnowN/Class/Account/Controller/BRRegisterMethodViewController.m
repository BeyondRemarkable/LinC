//
//  BRRegisterMethodViewController.m
//  KnowN
//
//  Created by Yingwei Fan on 2/12/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRRegisterMethodViewController.h"
#import "BRUserAccountSetUpViewController.h"
#import "BRAccountNavigationController.h"

@interface BRRegisterMethodViewController ()

@property (weak, nonatomic) IBOutlet UIStackView *methodView;

@end

@implementation BRRegisterMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize fittedSize = [self.methodView sizeThatFits:UILayoutFittingCompressedSize];
    self.preferredContentSize = CGSizeMake(fittedSize.width + 10, fittedSize.height + 10);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BRAccountNavigationController *nav = segue.destinationViewController;
    BRUserAccountSetUpViewController *registerVc = (BRUserAccountSetUpViewController *)nav.topViewController;
    if ([segue.identifier isEqualToString:@"Phone Number Sign Up"]) {
        registerVc.registerType = BRRegisterTypeMobile;
    }
    else if ([segue.identifier isEqualToString:@"Email Sign Up"]) {
        registerVc.registerType = BRRegisterTypeEmail;
    }
}

@end
