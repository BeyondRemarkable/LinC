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
#import "BRUserGenderTableViewController.h"
#import "BRLocationListViewController.h"
#import "BRWhatsUpViewController.h"
#import "BRLocationCitiListTableViewController.h"
#import "BRWhatsUpViewController.h"
#import "BRUserSettingTableViewController.h"
#import "BRQRCodeViewController.h"


@interface BRUserInfoViewController ()<UITableViewDelegate, UITableViewDataSource, sendGenderProtocol, sendUserNameProtocol, sendWhatUpProtocol>


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
    TableViewSectionZero = 0,
    TableViewSectionOne,
    TableViewSectionTwo
} TableViewSession;


typedef enum NSUInteger {
    
    // Section zero
    UserImageCell = 0,
    UserNameCell,
    UserAccountIDCell,
    UserQRCodeCell,
    UserGenderCell,
    
    // Section one
    UserLocationCell = 0,
    UserWhatsUpCell,
    
    // Section Two
    UserSettingCell = 0,
    
} UserInfo;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"location" object:nil];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
    
    // Section Zerro of table view
    if (indexPath.section == TableViewSectionZero ) {
        // Image cell
        if (indexPath.row == UserImageCell) {
            BRUserImageViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserImageViewController"];
            vc.imageIcon.image = self.imageIcon.image;
            [self.navigationController pushViewController:vc animated:YES];
        }
        // User nick name text field
        if (indexPath.row == UserNameCell) {
            BRUserNameTextViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserNameTextViewController"];
            vc.nameText = self.userName.text;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        // User's gender
        if (indexPath.row == UserGenderCell) {
        
            BRUserGenderTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserGenderTableViewController"];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if (indexPath.row == UserQRCodeCell) {
            BRQRCodeViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRQRCodeViewController"];
            
            vc.accountId = @"xjfklsdjfkladsjfe@gmail.com";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    // Section one of table view
    if (indexPath.section == TableViewSectionOne) {
        // User's location list cell
        if (indexPath.row == UserLocationCell) {
            
            BRLocationListViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRLocationListViewController"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        // What's up text view cell
        if (indexPath.row == UserWhatsUpCell) {
            BRWhatsUpViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRWhatsUpViewController"];
            vc.whatUpText = self.whatsup.text;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == TableViewSectionTwo) {
        // User's setting
        if (indexPath.row == UserSettingCell) {
            
            BRUserSettingTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserSettingTableViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark delegate methods

// Set up user gender from BRUserGenderViewCOntroller
- (void)sendGenderBack:(NSString *)gender
{
    self.gender.text = gender;
}

// Set up user nick name from BRUserNameTextViewController
- (void)sendUserNameBack:(NSString *)userName
{
    self.userName.text = userName;
}

// Set up user nick name from
-(void)sendWhatUpBack:(NSString *)text
{
    self.whatsup.text = text;
}

// Set up location BRWhatsUpViewController
-(void) receiveTestNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"location"])
    {
        NSDictionary* dict = notification.userInfo;
        self.location.text = (NSString *) dict[@"location"];
    }
}

@end
