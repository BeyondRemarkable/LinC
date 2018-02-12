//
//  QRCodeViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/25/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "BRQRCodeViewController.h"
#import <CoreImage/CoreImage.h>
#import <MBProgressHUD.h>
#import "UIView+NavigationBar.h"

@interface BRQRCodeViewController ()
{
    MBProgressHUD *hud;
}
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation BRQRCodeViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BRColor(38, 38, 38);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    if (@available(iOS 11.0, *)) {
        [btn addNavigationBarConstraintsWithWidth:35 height:35];
    }
    [btn setImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = infoItem;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //    NSLog(@"filterAttributes:%@", filter.attributes);
    
    [filter setDefaults];
    
    NSData *data = [self.username dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    // Resize without interpolating
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    
    self.imageView.image = resized;
    
    CGImageRelease(cgImage);
}

- (void)moreAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save Image", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveBtnClick];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Scan QR Code", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Private

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

- (void)saveBtnClick {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    
    if(error != NULL){
       
        hud.label.text = NSLocalizedString(@"saveFail", @"Try again later.");
        [hud hideAnimated:YES afterDelay:1.5];
    }else{ 
        hud.label.text = NSLocalizedString(@"saveSuccess", @"Image saved.");
        [hud hideAnimated:YES afterDelay:1.5];
    }

}

@end
