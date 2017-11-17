//
//  BRGeneralSettingViewController.m
//  LinC
//
//  Created by Yingwei Fan on 11/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRGeneralSettingViewController.h"
#import "BRBlackListViewController.h"

@interface BRGeneralSettingViewController ()

@end

@implementation BRGeneralSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        BRBlackListViewController *vc = [[BRBlackListViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
