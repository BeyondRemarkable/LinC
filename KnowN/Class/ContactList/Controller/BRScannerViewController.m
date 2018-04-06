//
//  ScannerViewController.m
//  Track
//
//  Created by zhe wu on 10/22/16.
//  Copyright © 2016 zhe wu. All rights reserved.
//

#import "BRScannerViewController.h"
#import "BRFriendInfoTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BRClientManager.h"
#import <MBProgressHUD.h>
#import "BRGroupChatSettingTableViewController.h"

@interface BRScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession * session;
    MBProgressHUD *hud;
}

/** Scanner's layer */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *scanlayer;

///** Tracking number from scanner */
//@property (nonatomic, strong) NSString *trackingNumber;

@end

@implementation BRScannerViewController

//@synthesize scannerDelegate;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //setup scanner frame
    self.scanlayer.frame= self.view.bounds;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden: YES];
    [self cameraAuthorizationCheck];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 相机授权提示判断
 */
- (void)cameraAuthorizationCheck
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        // 没有权限。弹出alertView
        [self showAuthorizationAlert];
    }else{
        //获取了权限，直接调用相机接口
         [self scannerView];
    }
}

/**
  提示开启相机权限设置
 */
- (void)showAuthorizationAlert
{
    
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable to access camera.", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *open = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleDestructive handler:nil];
    
    [actionSheet addAction:open];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

/**
 *  Run the scanner
 */
- (void)scannerView
{
    //get carma
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //setup inuput
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //setup output
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    self.scanlayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.scanlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer insertSublayer: self.scanlayer atIndex:0];
    [session startRunning];
}

/**
 *  Return scan result
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
       
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0];
        
        // 判断二维码是否是群聊二维码
        if ([metadataObject.stringValue hasSuffix:@"group"]) {
            NSString *groupID = [[metadataObject.stringValue componentsSeparatedByString:@"group"] firstObject];
            [self searchGroupByGroupID: groupID];
        } else {
            [self searchFriendWithUserID:(NSString *)metadataObject.stringValue];
        }
        
        [session stopRunning];
        [self.scanlayer removeFromSuperlayer];
        
    }
}


/**
     把扫描结果userID传到服务器获取User模型， 并判断好友关系
     跳转到BRFriendInfoTableViewController
 
 @param searchID NSString searchID 扫描结果
 */
- (void)searchFriendWithUserID:(NSString *)searchID {
    NSArray *userIDArr = [NSArray arrayWithObject:searchID];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] getUserInfoWithUsernames:userIDArr andSaveFlag:NO
    success:^(NSMutableArray *aList) {
        [hud hideAnimated:YES];
        
        BRContactListModel *model = [aList firstObject];
        
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendInfoTableViewController"];
        vc.contactListModel = model;
        // 如果已经是好友
        NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
        if ([contactArray containsObject:searchID]) {
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
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self cancalButton:nil];
        });
    }];
}

/**
 群聊二维码，跳转到群设置页面

 @param groupID 群ID
 */
- (void)searchGroupByGroupID:(NSString *)groupID {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRGroupChatSettingTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRGroupChatSettingTableViewController"];
    vc.doesJoinGroup = YES;
    vc.groupID = groupID;
    [hud hideAnimated:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

/**
 *  Cancel scan
 */
- (IBAction)cancalButton:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Turn on or off flash light
 */
- (IBAction)flashlightSwitch:(UIButton *)flashlight {
    if (flashlight.selected) flashlight.selected = NO;
    else flashlight.selected = YES;
    
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive]) {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            } else {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            [flashLight unlockForConfiguration];
        }
    }
}

@end
