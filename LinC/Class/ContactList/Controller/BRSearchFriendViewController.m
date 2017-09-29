//
//  BRAddingFriendViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRSearchFriendViewController.h"
#import "BRScannerViewController.h"
#import "BRFriendInfoTableViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import "BRFriendRequestTableViewController.h"
#import <SAMKeychain.h>
#import "BRHTTPSessionManager.h"

@interface BRSearchFriendViewController () <UITextFieldDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *friendIDTextField;

@end

@implementation BRSearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.friendIDTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self setupNavigationBarItem];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO];
}

// Set up Nagigation Bar Items
- (void)setupNavigationBarItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)searchByID:(NSString *)searchID {
  
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefaults objectForKey:kLoginUserNameKey];
    
    // 不能添加自己
    if ([self.friendIDTextField.text isEqualToString:savedUserName]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Can not add yourself.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    // 如果已经是好友，则不能继续添加
    NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
    
    if ([contactArray containsObject:self.friendIDTextField.text]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Already your friend.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    // 从服务器获取好友信息
    [self loadDataFromServer];
    
    }

/**
    从服务器获取好友JSON信息
 */
- (void)loadDataFromServer {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *savedUserName = [userDefault objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account: savedUserName];
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/users/find"];
    NSDictionary *parameters = @{@"key":@"username", @"value":self.friendIDTextField.text};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self setUpUserInfoFrom: responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


/**
    好友信息判断，成功跳转BRFriendInfoTableViewController
    失败，显示信息
 @param responseObject responseObject 服务器返回的数据
 */
- (void)setUpUserInfoFrom:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"dict--%@", dict);
        
        // 成功获取好友信息，并跳转到BRFriendInfoTableViewController
        if ([dict[@"status"]  isEqual: @"success"]) {
            
            NSArray *userArray = [dict[@"data"][@"users"] lastObject];
            
            NSDictionary *friendDict = (NSDictionary *)userArray;
            NSLog(@"%@", friendDict);
            [hud hideAnimated:YES];
            UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
            BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendInfoTableViewController"];
            vc.isFriend = NO;
            vc.friendDict = friendDict;
        
            // Push BRFriendInfoTableViewController
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            // 获取好友信息失败， 显示失败信息
            hud.mode = MBProgressHUDModeText;
            hud.label.text = dict[@"message"];
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }
}

- (IBAction)scanQRCodeBtn {
    BRScannerViewController *vc = [[BRScannerViewController alloc] initWithNibName:@"BRScannerViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
//    [self presentViewController:vc animated:YES completion: nil];
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self searchByID:textField.text];
    }
    return YES;
}

@end
