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
    [self scannerView];
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
    
        [self searchFriendWithUserID:(NSString *)metadataObject.stringValue];
        
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
        NSLog(@"%@", model);
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
    }];
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
