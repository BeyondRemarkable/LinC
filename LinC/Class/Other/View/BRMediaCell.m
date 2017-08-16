//
//  BRMediaCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMediaCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>

@interface BRMediaCell ()

@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIImageView *mediaView;

@end

@implementation BRMediaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - setter

- (void)setMedia:(BRMedia *)media {
    _media = media;
    if (media.type == BRMediaImage) {
        self.image = media.image;
    }
    else if (media.type == BRMediaWebImage) {
        self.imageURL = media.imageURL;
    }
    else if (media.type == BRMediaVideo) {
        self.videoURL = media.videoURL;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.mediaView setImage:_image];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [self.mediaView sd_setImageWithURL:_imageURL placeholderImage:[UIImage imageNamed:@""]];
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    self.item = [AVPlayerItem playerItemWithURL:_videoURL];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.contentView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.mediaView.layer addSublayer:self.playerLayer];
}

@end
