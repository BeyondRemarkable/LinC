//
//  BRFriendInfoTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendInfoTableViewController.h"
#import "BRAddingFriendViewController.h"


@interface BRFriendInfoTableViewController ()

@end

@implementation BRFriendInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: NO];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToVC)];
    
    [self.navigationItem setLeftBarButtonItem:backBtn];
    
    
}

- (void)backToVC{
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[BRAddingFriendViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (IBAction)MessageOrConfirmBtn:(UIButton *)sender {

}




@end
