//
//  BRNavigationController.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRNavigationController.h"

@interface BRNavigationController ()

@end

@implementation BRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[UIColor blueColor]];
//    [self.navigationBar setBackgroundColor:[UIColor blueColor]];
    
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
    }

    [super pushViewController:viewController animated:animated];
}

@end
