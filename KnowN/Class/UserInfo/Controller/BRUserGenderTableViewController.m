//
//  UserGenderViewController.m
//  KnowN
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserGenderTableViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRUserGenderTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *maleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *femaleCell;
@end

@implementation BRUserGenderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.status) {
        // Set navigationBar background color
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    }
    
    if ([self.gender isEqualToString:@"Male"]) {
        self.maleCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if ([self.gender isEqualToString:@"Female"]) {
        self.femaleCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveBtn)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)saveBtn {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] updateSelfInfoWithKeys:@[@"gender"] values:@[self.gender] success:^(NSString *message) {
        [self->hud hideAnimated:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(genderDidChangeTo:)]) {
            [self.delegate genderDidChangeTo:self.gender];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(EMError *error) {
        self->hud.mode = MBProgressHUDModeText;
        self->hud.label.text = error.errorDescription;
        [self->hud hideAnimated:YES afterDelay:1.5];
    }];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.maleCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.femaleCell.accessoryType = UITableViewCellAccessoryNone;
        self.gender = @"Male";
    }
    else if (indexPath.row == 1) {
        self.femaleCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.maleCell.accessoryType = UITableViewCellAccessoryNone;
        self.gender = @"Female";
    }
}

@end
