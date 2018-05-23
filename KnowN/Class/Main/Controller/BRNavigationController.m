 //
//  BRNavigationController.m
//  KnowN
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
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
    }

    [super pushViewController:viewController animated:animated];
}

- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}

@end
