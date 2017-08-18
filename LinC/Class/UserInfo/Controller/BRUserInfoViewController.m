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
#import "BRLocationListViewController.h"
#import "BRWhatsUpViewController.h"


@interface BRUserInfoViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *accountID;
@property (weak, nonatomic) IBOutlet UILabel *qrCode;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *whatsup;

@end

@implementation BRUserInfoViewController

typedef enum : NSInteger {
    TableViewSectionZerro = 0,
    TableViewSectionOne,
} TableViewSession;


typedef enum NSUInteger {
    
    // Section zerro
    UserImageCell = 0,
    UserNameCell,
    UserAccountIDCell,
    UserQRCodeCell,
    UserGenderCell,
    
    // Section one
    UserLocationCell = 0,
    UserWhatsUpCell,

} UserSettingCell;



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
    // Section Zerro of table view
    if (indexPath.section == TableViewSectionZerro ) {
        // Image cell
        if (indexPath.row == UserImageCell) {
            BRUserImageViewController *vc = [[BRUserImageViewController alloc] initWithNibName:@"BRUserImageViewController" bundle:nil];
            vc.imageIcon.image = self.imageIcon.image;
            [self.navigationController pushViewController:vc animated:YES];
        }
        // User nick name text field
        if (indexPath.row == UserNameCell) {
            BRUserNameTextViewController *vc = [[BRUserNameTextViewController alloc] initWithNibName:@"BRUserNameTextViewController" bundle:nil];
            vc.nameText = self.userName.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        //    // User's gender
            if (indexPath.row == UserGenderCell) {
                BRUserGenderViewController *vc = [[BRUserGenderViewController alloc] initWithNibName:@"BRUserGenderViewController" bundle:nil];
                if ([self.gender.text.lowercaseString isEqual: @"male"]) {
                    vc.isMale = true;
                } else {
                    vc.isMale = false;
                }
                [self.navigationController pushViewController:vc animated:YES];
            }

        
    }
    
    // Section one of table view
    if (indexPath.section == TableViewSectionOne) {
        // User's location list cell
        if (indexPath.row == UserLocationCell) {
            BRLocationListViewController *vc = [[BRLocationListViewController alloc] initWithNibName:@"BRLocationListViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        // What's up text view cell
            if (indexPath.row == UserWhatsUpCell) {
                BRWhatsUpViewController *vc = [[BRWhatsUpViewController alloc] initWithNibName:@"BRWhatsUpViewController" bundle:nil];
                vc.whatsUpTextView.text = self.whatsup.text;
                [self.navigationController pushViewController:vc animated:YES];
            }
    }
}

@end
