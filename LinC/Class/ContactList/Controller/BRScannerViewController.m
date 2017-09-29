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

@interface BRScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession * session;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden: YES];
    [self scannerView];
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
        [session stopRunning];
        [self.scanlayer removeFromSuperlayer];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0];
        
        NSLog(@"%@",  metadataObject.stringValue);
        
        [self searchFriendWithUserID:(NSString *)metadataObject.stringValue];
    }
}

// Send scan result to BRAddingFriendViewController
- (void)searchFriendWithUserID:(NSString *)searchID {
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];

    BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
//    [self.navigationController setNavigationBarHidden: NO];
    vc.isFriend = NO;
//    vc.searchID = searchID;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  Cancel scan
 */
- (IBAction)cancalButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
