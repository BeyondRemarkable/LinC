//
//  UserGenderViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserGenderViewController.h"

@interface BRUserGenderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *maleIconCheck;
@property (weak, nonatomic) IBOutlet UIImageView *femaleIconCheck;

@end

@implementation BRUserGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpUserGender {
    if (self.isMale) {
        self.maleIconCheck.hidden = NO;
        self.femaleIconCheck.hidden = YES;
        [self.delegate sendGenderBack:@"Male"];
    } else {
        self.femaleIconCheck.hidden = YES;
        self.maleIconCheck.hidden = NO;
        [self.delegate sendGenderBack:@"Female"];
    }
}
- (IBAction)maleClick:(id)sender {
    self.isMale = true;
    [self setUpUserGender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)femaleClick:(id)sender {
    self.isMale = false;
    [self setUpUserGender];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
