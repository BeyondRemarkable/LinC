//
//  UserImageViewController.h
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRUserImageViewControllerDelegate <NSObject>

@optional
- (void)userDidUpdateAvatarTo:(UIImage *)newAvatar;

@end

@interface BRUserImageViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<BRUserImageViewControllerDelegate> delegate;

@end
