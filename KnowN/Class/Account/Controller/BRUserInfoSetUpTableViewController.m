//
//  BRUserInfoSetUpTableViewController.m
//  KnowN
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserInfoSetUpTableViewController.h"
#import "BRNicknameTextViewController.h"
#import "BRUserGenderTableViewController.h"
#import "BRLocationListViewController.h"

@interface BRUserInfoSetUpTableViewController ()<BRUserGenderTableViewControllerDelegate, BRNicknameTextViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation BRUserInfoSetUpTableViewController

typedef enum NSUInteger {
    
    UserNameCell = 0,
    UserGenderCell,
    UserLocationCell,
    
} UserSettingCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    // Set navigationBar background color
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    UIImageView *ig = [[UIImageView alloc] initWithFrame:self.view.bounds];
    ig.image = [UIImage imageNamed:@"background"];
    self.tableView.backgroundView = ig;
    
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
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];

    // User nick name text field
    if (indexPath.row == UserNameCell) {
        BRNicknameTextViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserNameTextViewController"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    //    // User's gender
    if (indexPath.row == UserGenderCell) {

        BRUserGenderTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserGenderTableViewController"];
        vc.status = true;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == UserLocationCell) {
        BRLocationListViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLocationListViewController"];
        //            vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark delegate methods

// Set up user gender from BRUserGenderViewCOntroller
- (void)genderDidChangeTo:(NSString *)newGender {
    self.userGender.text = newGender;
}

// Set up user nick name from BRUserNameTextViewController
- (void)nicknameDidChangeTo:(NSString *)newNickname {
    self.userName.text = newNickname;
}
- (IBAction)finishBtn:(id)sender {
}

@end
