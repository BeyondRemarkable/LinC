//
//  BRUserInfoSetUpTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserInfoSetUpTableViewController.h"
#import "BRUserNameTextViewController.h"
#import "BRUserGenderViewController.h"
#import "BRLocationListViewController.h"

@interface BRUserInfoSetUpTableViewController ()<sendGenderProtocol, sendUserNameProtocol>
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation BRUserInfoSetUpTableViewController

typedef enum NSUInteger {
    
    UserNameCell,
    UserGenderCell,
    UserLocationCell,
    
} UserSettingCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        // User nick name text field
        if (indexPath.row == UserNameCell) {
            BRUserNameTextViewController *vc = [[BRUserNameTextViewController alloc] initWithNibName:@"BRUserNameTextViewController" bundle:nil];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        //    // User's gender
        if (indexPath.row == UserGenderCell) {
            BRUserGenderViewController *vc = [[BRUserGenderViewController alloc] initWithNibName:@"BRUserGenderViewController" bundle:nil];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    
        if (indexPath.row == UserLocationCell) {
            BRLocationListViewController *vc = [[BRLocationListViewController alloc] initWithNibName:@"BRLocationListViewController" bundle:nil];
//            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
}

#pragma mark delegate methods

// Set up user gender from BRUserGenderViewCOntroller
- (void)sendGenderBack:(NSString *)gender
{
    self.userGender.text = gender;
}

// Set up user nick name from BRUserNameTextViewController
- (void)sendUserNameBack:(NSString *)userName
{
    self.userName.text = userName;
}
- (IBAction)finishBtn:(id)sender {
}

@end
