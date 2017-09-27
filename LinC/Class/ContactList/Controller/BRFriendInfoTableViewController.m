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
#import "BRMessageViewController.h"
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
        
        [self setUpUserInfoFrom:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
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

/**
    删除好友
 */
- (IBAction)clickDeleteFriend:(id)sender {
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Confirm Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[EMClient sharedClient].contactManager deleteContact:self.searchID isDeleteConversation:YES completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Delete successful";
                [hud hideAnimated:YES afterDelay:1.5];
                [self performSelector:@selector(dismissVC) withObject:nil afterDelay:1.0];
            }
        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheet addAction:delete];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (void)dismissVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)clickChat:(id)sender {
    BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:self.searchID conversationType:EMConversationTypeChat];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
