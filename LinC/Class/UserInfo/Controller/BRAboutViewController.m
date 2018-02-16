//
//  BRAboutViewController.m
//  LinC
//
//  Created by Yingwei Fan on 10/26/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRAboutViewController.h"

@interface BRAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@end

@implementation BRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDict[@"CFBundleShortVersionString"];
    NSString *appBuildVersion = infoDict[@"CFBundleVersion"];
    self.appVersionLabel.text = [NSString stringWithFormat:@"LinC %@.%@", appVersion, appBuildVersion];
}


@end
