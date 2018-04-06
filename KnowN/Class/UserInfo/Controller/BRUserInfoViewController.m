//
//  BRUserInfoViewController.m
//  KnowN
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRNavigationController.h"
#import "BRUserInfoViewController.h"
#import "BRUserImageViewController.h"
#import "BRNicknameTextViewController.h"
#import "BRUserGenderTableViewController.h"
#import "BRLocationListViewController.h"
#import "BRWhatsUpViewController.h"
#import "BRWhatsUpViewController.h"
#import "BRUserSettingTableViewController.h"
#import "BRQRCodeViewController.h"
#import "BRClientManager.h"
#import <UIImageView+WebCache.h>
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"


@interface BRUserInfoViewController ()<UITableViewDelegate, UITableViewDataSource, BRUserImageViewControllerDelegate, BRUserGenderTableViewControllerDelegate, BRNicknameTextViewControllerDelegate,BRLocationListViewControllerDelegate, BRWhatsUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *username;
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
    UserNicknameCell,
    UserNameCell,
    UserQRCodeCell,
    UserGenderCell,
    
    // Section one
    UserLocationCell = 0,
    UserWhatsUpCell,
    
    // Section Two
    UserSettingCell = 0,
    
} UserInfoCellName;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.imageIcon setUserInteractionEnabled:YES];
    [self.imageIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)]];
    
    self.location.adjustsFontSizeToFitWidth = YES;
    self.whatsup.adjustsFontSizeToFitWidth = YES;
   
    // 从Core data获取登录用户
    BRUserInfo *userInfo = [[BRCoreDataManager sharedInstance] getUserInfo];

    UIImage *avatar = [UIImage imageWithData:userInfo.avatar];
    self.imageIcon.image = avatar ? avatar : [UIImage imageNamed:@"user_default"];
    self.username.text = userInfo.username;
    self.nickname.text = userInfo.nickname;
    self.gender.text = userInfo.gender;
    self.location.text = userInfo.location;
    self.whatsup.text = userInfo.whatsUp;

}

- (void)imageClicked {
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
    BRUserImageViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserImageViewController"];
    vc.delegate = self;
    vc.image = self.imageIcon.image;
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == [tableView numberOfSections] - 1) {
        return 20;
    } else {
        return 0.01;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRUserInfo" bundle:[NSBundle mainBundle]];
    
    // Section Zerro of table view
    if (indexPath.section == TableViewSectionZero ) {
        // User nick name text field
        if (indexPath.row == UserNicknameCell) {
            BRNicknameTextViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRNicknameTextViewController"];
            vc.nameText = self.nickname.text;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        // User's gender
        if (indexPath.row == UserGenderCell) {
        
            BRUserGenderTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRUserGenderTableViewController"];
            vc.gender = self.gender.text;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if (indexPath.row == UserQRCodeCell) {
            BRQRCodeViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRQRCodeViewController"];
            
            vc.username = self.username.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    // Section one of table view
    if (indexPath.section == TableViewSectionOne) {
        // User's location list cell
        if (indexPath.row == UserLocationCell) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Location" ofType:@"plist"];
            NSArray *locationArray = [NSArray arrayWithContentsOfFile:filePath];
            BRLocationListViewController *vc = [[BRLocationListViewController alloc] initWithSytle:UITableViewStyleGrouped locationArray:locationArray];
            vc.delegate = self;
            BRNavigationController *navigationVc = [[BRNavigationController alloc] initWithRootViewController:vc];
            
            [self presentViewController:navigationVc animated:YES completion:nil];
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

// Set up user avatar from BRUserImageViewController
- (void)userDidUpdateAvatarTo:(UIImage *)newAvatar {
    self.imageIcon.image = newAvatar;
}

// Set up user gender from BRUserGenderViewController
- (void)genderDidChangeTo:(NSString *)newGender {
    self.gender.text = newGender;
}

// Set up user nick name from BRUserNameTextViewController
- (void)nicknameDidChangeTo:(NSString *)newNickname {
    self.nickname.text = newNickname;
}

// Set up user location from BRLocationListViewController
- (void)locationDidUpdateTo:(NSString *)newLocation {
    self.location.text = newLocation;
}

// Set up user nick name from BRWhatsUpViewController
- (void)whatsUpDidChangeTo:(NSString *)newWhatsUp {
    self.whatsup.text = newWhatsUp;
}

// Set up location BRWhatsUpViewController
- (void)receiveTestNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"location"])
    {
        NSDictionary* dict = notification.userInfo;
        self.location.text = (NSString *) dict[@"location"];
    }
}

@end
