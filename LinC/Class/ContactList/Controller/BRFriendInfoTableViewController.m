//
//  BRFriendInfoTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendInfoTableViewController.h"
#import "BRAddingFriendViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRAddedFriendTableViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <SAMKeychain.h>

@interface BRFriendInfoTableViewController ()
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

// User Info labels
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userWhatUp;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;


@end

@implementation BRFriendInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: NO];
    
    if (self.isFriend) {
        [self.addFriendButton setHidden:YES];
    }
    else {
        [self.chatButton setHidden:YES];
        [self.deleteFriendButton setHidden:YES];
    }

    [self setupNavigationBarItem];
    [self loadDataFromServer];
    }


- (void)setupNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

// Load JSON Data of user info from server
- (void)loadDataFromServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefault objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account: savedUserName];
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/users/find"];
    NSDictionary *parameters = @{@"key":@"username", @"value":self.searchID};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [self setUpUserInfoFrom:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"53946ec09e4811e79ffc87f0172ce81b---%@", error.localizedDescription);
    }];
}

// set up all data to user labels
- (void)setUpUserInfoFrom:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"dict--%@", dict);
        if ([dict[@"status"]  isEqual: @"success"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSArray *userArray = [dict[@"data"][@"users"] lastObject];
            NSDictionary *userDict = (NSDictionary *)userArray;
            self.userID.text = userDict[@"username"];
        }
    }
}

#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - button actions
- (void)clickMoreInfo {
    
}

- (IBAction)clickAddFriend:(id)sender {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRAddedFriendTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRAddedFriendTableViewController"];
    vc.userID = self.searchID;
    [self.navigationController pushViewController:vc animated:YES];
}


// delete friend 
- (IBAction)clickDeleteFriend:(id)sender {
    [[EMClient sharedClient].contactManager deleteContact:self.searchID isDeleteConversation:YES completion:^(NSString *aUsername, EMError *aError) {
        if (!aError) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"Delete successful";
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

- (IBAction)clickChat:(id)sender {
}


@end
