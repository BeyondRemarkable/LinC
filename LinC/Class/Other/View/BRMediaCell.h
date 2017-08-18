//
//  BRMediaCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRMedia.h"

@interface BRMediaCell : UICollectionViewCell

@property (nonatomic, strong) BRMedia *media;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *videoURL;

@end
