//
//  UIImagePickerController+Open.h
//  Table
//
//  Created by Yingwei Fan on 3/22/18.
//  Copyright © 2018 Yingwei Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (Open)

- (void)openCameraWithSuccess:(void (^)(void))successBlock failure:(void (^)(void))failureBlock;

- (void)openAlbumWithSuccess:(void (^)(void))successBlock failure:(void (^)(void))failureBlock;

@end
