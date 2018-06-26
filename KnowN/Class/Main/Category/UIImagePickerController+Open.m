//
//  UIImagePickerController+Open.m
//  Table
//
//  Created by Yingwei Fan on 3/22/18.
//  Copyright © 2018 Yingwei Fan. All rights reserved.
//

#import "UIImagePickerController+Open.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImagePickerController (Open)

- (void)openCameraWithSuccess:(void (^)(void))successBlock failure:(void (^)(void))failureBlock {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    successBlock();
                }
            }];
        }
        else if (authStatus == AVAuthorizationStatusAuthorized) {
            successBlock();
        }
        else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            failureBlock();
        }
    }
}

- (void)openAlbumWithSuccess:(void (^)(void))successBlock failure:(void (^)(void))failureBlock {
    if ([[self class] isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                        successBlock();
                        break;
                        
                    default:
                        break;
                }
            }];
        }
        else if (authStatus == PHAuthorizationStatusAuthorized) {
            successBlock();
        }
        else if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
            failureBlock();
        }
    }
}

@end
