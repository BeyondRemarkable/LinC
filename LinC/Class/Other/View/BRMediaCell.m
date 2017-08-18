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

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation BRMediaCell

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UIView *)videoView {
    if (_videoView == nil) {
        _videoView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_videoView];
        
        // 添加playButton
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _playButton.backgroundColor = [UIColor redColor];
        _playButton.center = _videoView.center;
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
        [_playButton setTitle:@"Pause" forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:_playButton];
        
        // 添加backButton
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
        _backButton.backgroundColor = [UIColor whiteColor];
        [_backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:_backButton];
    }
    return _videoView;
}

#pragma mark - private methods

// 设置AVPlayer
- (void)setupPlayerWithURL:(NSURL *)videoURL {
    // 设置item
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    // 监听视频状态
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听视频缓冲进度
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 监听播放器处于缓冲状态
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲已经完成
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    // 注册播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    
    // 设置player
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    // 设置playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.videoView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    [self.playButton setSelected:NO];
    NSLog(@"播放结束");
}

- (void)clickPlayButton:(UIButton *)button {
    if (button.isSelected) {
        [button setSelected:NO];
    }
    else {
        [button setSelected:YES];
    }
    if (self.player.rate == 0) {
        [self.player play];
    }
    else if (self.player.rate == 1.0) {
        [self.player pause];
    }
}

- (void)clickBackButton {
    NSLog(@"后退");
}

- (void)cleanSubviews {
    if (_playerLayer) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
        self.playerItem = nil;
        self.player = nil;
        self.playerLayer = nil;
    }
    if (_imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    if (_videoView) {
        [self.videoView removeFromSuperview];
        self.videoView = nil;
    }
}

- (void)removeObserverFromPlayerItem {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)removeNotificationFromPlayerItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.imageView setImage:_image];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [self.imageView sd_setImageWithURL:_imageURL placeholderImage:[UIImage imageNamed:@""]];
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.videoView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.videoView.layer addSublayer:self.playerLayer];
}

#pragma mark - 监听方法

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", keyPath);
}

- (void)dealloc {
    [self removeNotificationFromPlayerItem];
    [self removeObserverFromPlayerItem];
    [self cleanSubviews];
}

@end
