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
#import "BRClientManager.h"
#import "BRGroupChatSettingTableViewController.h"


@interface BRSearchFriendViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *friendIDTextField;
@property (nonatomic, strong) NSString *searchID;
@end

@implementation BRSearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendIDTextField.delegate = self;
    [self.friendIDTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self setupNavigationBarItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO];
    self.searchID = nil;
}

// Set up Nagigation Bar Items
- (void)setupNavigationBarItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action: @selector(searchByID)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}



/**
    根据输入或者扫描或者识别的ID搜索
 */
- (void)searchByID {
    
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    if (!self.searchID) {
        self.searchID = self.friendIDTextField.text;
    }
    // 不能添加自己
    if ([self.searchID isEqualToString:currentUsername]) {
        self.searchID = nil;
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Can not add yourself.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    if ([self.searchID hasSuffix:@"group"]) {
        self.searchID = [self.searchID stringByReplacingOccurrencesOfString:@"group" withString:@""];
        [self searchGroupID:self.searchID];
    } else if (self.searchID.length == GroupIDLength) {
        [self searchGroupID:self.searchID];
    } else {
        [self searchFriendID: self.searchID];
    }
    self.searchID = nil;
}


/**
    搜索好友ID
 
 @param friendID 需要添加的好友ID
 */
- (void)searchFriendID:(NSString *)friendID {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] getUserInfoWithUsernames:[NSArray arrayWithObject:friendID] andSaveFlag:NO success:^(NSMutableArray *aList) {
        [hud hideAnimated:YES];
        
        BRContactListModel *model = [aList firstObject];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendInfoTableViewController"];
        vc.contactListModel = model;
        // 如果已经是好友
        NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
        if ([contactArray containsObject:self.friendIDTextField.text]) {
            vc.isFriend = YES;
        }
        else {
            vc.isFriend = NO;
        }
        // Push BRFriendInfoTableViewController
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(EMError *aError) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = aError.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}


/**
    搜索的群ID

 @param groupID 搜索群ID
 */
- (void)searchGroupID:(NSString *)groupID {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRGroupChatSettingTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRGroupChatSettingTableViewController"];
    vc.doesJoinGroup = YES;
    vc.groupID = groupID;
    [hud hideAnimated:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)scanQRCodeBtn {
    
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *scan = [UIAlertAction actionWithTitle:@"Scan camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self scanQRCodeBtnTapped];
    }];
    UIAlertAction *load = [UIAlertAction actionWithTitle:@"Load from album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self readQRCodeFromAlbum];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [actionSheet addAction:scan];
    [actionSheet addAction:load];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)scanQRCodeBtnTapped {
    BRScannerViewController *vc = [[BRScannerViewController alloc] initWithNibName:@"BRScannerViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)readQRCodeFromAlbum {
    // 判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>

/**
 识别图片中的二维码

 @param info 用户选取的图片信息
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *qrImage = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    NSData *imageData = UIImagePNGRepresentation(qrImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    NSArray *features = [detector featuresInImage: ciImage];
    
    if (features.count == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"QR code not found.";
        [hud hideAnimated:YES afterDelay:1.5];
    } else if (features.count > 1) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Multi QR code found.";
        [hud hideAnimated:YES afterDelay:1.5];
    } else {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        self.searchID = scannedResult;
        [self searchByID];
    }
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
        [self searchByID];
    }
    return YES;
}

@end
