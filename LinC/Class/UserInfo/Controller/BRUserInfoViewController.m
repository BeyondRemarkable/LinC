//
//  BRUserInfoViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserInfoViewController.h"
#import "BRUserImageViewController.h"
#import "BRUserNameTextViewController.h"
#import "BRUserGenderViewController.h"
#import "BRLocationListTableViewController.h"
#import "BRWhatsUpViewController.h"


@interface BRUserInfoViewController ()<UITableViewDelegate, UITableViewDataSource>

// Image Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *imageIconCell;
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;

// User Name Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *userNameCell;
@property (weak, nonatomic) IBOutlet UILabel *userName;

// Account ID Label
@property (weak, nonatomic) IBOutlet UILabel *accountID;

// QR code Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *QRcodeCell;
@property (weak, nonatomic) IBOutlet UILabel *qrCode;

// Gender Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *genderCell;
@property (weak, nonatomic) IBOutlet UILabel *gender;

// Location Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UILabel *location;

// What's up Cell
@property (weak, nonatomic) IBOutlet UITableViewCell *whatsUpCell;
@property (weak, nonatomic) IBOutlet UILabel *whatsup;

@end

@implementation BRUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Image cell click
    if (cell == self.imageIconCell) {
        BRUserImageViewController *vc = [[BRUserImageViewController alloc] initWithNibName:@"BRUserImageViewController" bundle:nil];
        vc.imageIcon.image = self.imageIcon.image;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // User name click
    if (cell == self.userNameCell) {
        BRUserNameTextViewController *vc = [[BRUserNameTextViewController alloc] initWithNibName:@"BRUserNameTextViewController" bundle:nil];
        vc.userNameTextField.text = self.userName.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // User's gender
    if (cell == self.genderCell) {
        BRUserGenderViewController *vc = [[BRUserGenderViewController alloc] initWithNibName:@"BRUserGenderViewController" bundle:nil];
        if ([self.gender.text.lowercaseString isEqual: @"male"]) {
            vc.isMale = true;
        } else {
            vc.isMale = false;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // Location List
    if (cell == self.locationCell) {
        BRLocationListTableViewController *vc = [[BRLocationListTableViewController alloc] initWithNibName:@"BRLocationListTableViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    // What's up text view
    if (cell == self.whatsUpCell) {
        BRWhatsUpViewController *vc = [[BRWhatsUpViewController alloc] initWithNibName:@"BRWhatsUpViewController" bundle:nil];
        vc.whatsUpTextView.text = self.whatsup.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
