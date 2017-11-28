//
//  UserImageViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserImageViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRUserImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BRUserImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageView setImage:self.image];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.imageView setImage:image];
}

- (void)clickMoreInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openImagePickerControllerWithType:(UIImagePickerControllerSourceType) type {
    if ([UIImagePickerController isSourceTypeAvailable:type] == 0) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = type;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@", info);
    hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    // 获取选择的图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    [[BRClientManager sharedManager] updateSelfInfoWithKeys:@[@"avatar"] values:@[imageData] success:^(NSString *message) {
        [hud hideAnimated:YES];
        [self.imageView setImage:image];
        if (_delegate && [_delegate respondsToSelector:@selector(userDidUpdateAvatarTo:)]) {
            [_delegate userDidUpdateAvatarTo:image];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

@end
