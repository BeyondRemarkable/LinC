//
//  BRPasswordViewController.m
//  LinC
//
//  Created by zhe wu on 8/23/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRPasswordViewController.h"

@interface BRPasswordViewController ()



@end

@implementation BRPasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtn)];
    self.navigationItem.rightBarButtonItem = saveBtn;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveBtn {
    
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 54;
    } else {
        return 20;
    }
}

@end
