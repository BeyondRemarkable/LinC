//
//  BRMediaCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRMedia.h"
@class BRMediaCell;

@protocol BRMediaCellDelegate <NSObject>

@optional
- (void)mediaCell:(BRMediaCell *)cell didClickBackButton:(UIButton *)button;
- (void)mediaCell:(BRMediaCell *)cell didTapImage:(UIImage *)image;
@end

@interface BRMediaCell : UICollectionViewCell

@property (nonatomic, strong) BRMedia *media;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, weak) id<BRMediaCellDelegate> delegate;

@end
