//
//  BRVideoPlayerView.m
//  LinC
//
//  Created by Yingwei Fan on 3/13/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>

#define controlPanelPadding 10
#define controlPanelHeight 34

@interface BRVideoPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playButtonSmall;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *restTimeLabel;

@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) UIView *originSuperView;
@property (nonatomic, strong) NSLayoutConstraint *centerXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *centerYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *playButtonSmallLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *restTimeLabelTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *controlPanelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *fullScreenButtonTopConstraint;

@end

@implementation BRVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
        [self setupDefaultProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubviews];
        [self setupDefaultProperties];
    }
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor blackColor];
    // 添加手势
    self.userInteractionEnabled = YES;
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideo:)];
    [self addGestureRecognizer:_tapGesture];
    
    // 添加playButton
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"play_big"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"pause_big"] forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    _playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_playButton.widthAnchor constraintEqualToConstant:100].active = YES;
    [_playButton.heightAnchor constraintEqualToAnchor:_playButton.widthAnchor].active = YES;
    [_playButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_playButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    // 添加控制台
    _controlPanel = [[UIView alloc] init];
    _controlPanel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    
    // 添加小播放按钮
    _playButtonSmall = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButtonSmall setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButtonSmall setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [_playButtonSmall addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [_controlPanel addSubview:_playButtonSmall];
    _playButtonSmall.translatesAutoresizingMaskIntoConstraints = NO;
    [_playButtonSmall.topAnchor constraintEqualToAnchor:_controlPanel.topAnchor constant:controlPanelPadding].active = YES;
    _playButtonSmallLeadingConstraint = [_playButtonSmall.leadingAnchor constraintEqualToAnchor:_controlPanel.leadingAnchor];
    _playButtonSmallLeadingConstraint.active = YES;
    [_playButtonSmall.widthAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    [_playButtonSmall.heightAnchor constraintEqualToAnchor:_playButtonSmall.widthAnchor].active = YES;
    
    // 添加已经播放的时间
    CGFloat timeLabelW = 35;
    _currentTimeLabel = [[UILabel alloc] init];
    [_currentTimeLabel setTextColor:[UIColor whiteColor]];
    [_currentTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
    _currentTimeLabel.adjustsFontSizeToFitWidth = YES;
    [_currentTimeLabel setText:@"00:00"];
    [_controlPanel addSubview:_currentTimeLabel];
    _currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_currentTimeLabel.topAnchor constraintEqualToAnchor:_controlPanel.topAnchor constant:controlPanelPadding].active = YES;
    [_currentTimeLabel.leadingAnchor constraintEqualToAnchor:_playButtonSmall.trailingAnchor].active = YES;
    [_currentTimeLabel.widthAnchor constraintEqualToConstant:timeLabelW].active = YES;
    [_currentTimeLabel.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    
    // 添加播放的剩余时间
    _restTimeLabel = [[UILabel alloc] init];
    [_restTimeLabel setTextColor:[UIColor whiteColor]];
    [_restTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
    _restTimeLabel.adjustsFontSizeToFitWidth = YES;
    [_restTimeLabel setText:@"00:00"];
    [_controlPanel addSubview:_restTimeLabel];
    _restTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_restTimeLabel.topAnchor constraintEqualToAnchor:_controlPanel.topAnchor constant:controlPanelPadding].active = YES;
    _restTimeLabelTrailingConstraint = [_restTimeLabel.trailingAnchor constraintEqualToAnchor:_controlPanel.trailingAnchor constant:-controlPanelPadding];
    _restTimeLabelTrailingConstraint.active = YES;
    [_restTimeLabel.widthAnchor constraintEqualToConstant:timeLabelW].active = YES;
    [_restTimeLabel.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    
    // 添加进度条
    _progressSlider = [[UISlider alloc] init];
    [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_progressSlider setMaximumTrackTintColor:[UIColor blackColor]];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [_progressSlider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventValueChanged];
    // 添加进度条点击手势
    UITapGestureRecognizer *sliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSlider:)];
    [_progressSlider addGestureRecognizer:sliderTapGesture];
    [_controlPanel addSubview:_progressSlider];
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressSlider.leadingAnchor constraintEqualToAnchor:_currentTimeLabel.trailingAnchor constant:controlPanelPadding].active = YES;
    [_progressSlider.trailingAnchor constraintEqualToAnchor:_restTimeLabel.leadingAnchor constant:-controlPanelPadding].active = YES;
    [_progressSlider.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    [_progressSlider.centerYAnchor constraintEqualToAnchor:_currentTimeLabel.centerYAnchor].active = YES;
    
    [self addSubview:_controlPanel];
    _controlPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [_controlPanel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_controlPanel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_controlPanel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    _controlPanelHeightConstraint = [_controlPanel.heightAnchor constraintEqualToConstant:controlPanelHeight + 2 * controlPanelPadding];
    _controlPanelHeightConstraint.active = YES;
}

- (void)setupDefaultProperties {
    self.contentMode = UIViewContentModeScaleAspectFit;
    _isShowDownloadProcess = NO;
    _fullScreenEnabled = NO;
    _rotateWithDevice = NO;
    _autoPlayWhenReady = NO;
    _orientation = BRVideoPlayerViewOrientationNormal;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    if (self.bounds.size.height != 812) {
        self.controlPanelHeightConstraint.constant = controlPanelHeight + 2 * controlPanelPadding;
        self.fullScreenButtonTopConstraint.constant = 20;
    }
    else {
        self.controlPanelHeightConstraint.constant = controlPanelHeight + 2 * controlPanelPadding + iPhoneX_BOTTOM_HEIGHT;
        self.fullScreenButtonTopConstraint.constant = 30;
    }
}

#pragma mark - getter

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] init];
        _hud.mode = MBProgressHUDModeDeterminate;
        [self insertSubview:_hud aboveSubview:self.controlPanel];
    }
    return _hud;
}

- (BOOL)showDownloadProcess {
    return self.isShowDownloadProcess;
}

#pragma mark - setter

- (void)setDownloadProgress:(double)downloadProgress {
    if (self.isShowDownloadProcess) {
        _downloadProgress = downloadProgress;
        self.hud.progress = downloadProgress;
    }
}

- (void)setShowDownloadProcess:(BOOL)showDownloadProcess {
    self.isShowDownloadProcess = showDownloadProcess;
    
    if (showDownloadProcess) {
        self.hud.progress = 0;
        [self.hud showAnimated:YES];
    }
    else {
        [self.hud hideAnimated:YES];
    }
}

- (void)setFullScreenEnabled:(BOOL)fullScreenEnabled {
    _fullScreenEnabled = fullScreenEnabled;
    
    // 添加全屏按钮
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
    [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"exit_full_screen"] forState:UIControlStateSelected];
    [_fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_fullScreenButton];
    _fullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat padding = 30.0;
    CGFloat width = 30.0;
    _fullScreenButtonTopConstraint = [_fullScreenButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:padding];
    _fullScreenButtonTopConstraint.active = YES;
    [_fullScreenButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding].active = YES;
    [_fullScreenButton.widthAnchor constraintEqualToConstant:width].active = YES;
    [_fullScreenButton.heightAnchor constraintEqualToAnchor:_fullScreenButton.widthAnchor].active = YES;
}

- (void)setAutoPlayWhenReady:(BOOL)autoPlayWhenReady {
    _autoPlayWhenReady = autoPlayWhenReady;
    
    if (autoPlayWhenReady && self.playButton.state == UIControlStateNormal) {
        self.playButton.hidden = YES;
    }
}

#pragma mark - Action

- (void)tapVideo:(UITapGestureRecognizer *)tap {
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerViewIsTapped:)]) {
        [_delegate videoPlayerViewIsTapped:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        if (self.controlPanel.alpha) {
            self.controlPanel.alpha = 0;
            self.fullScreenButton.alpha = 0;
        }
        else {
            self.controlPanel.alpha = 1;
            self.fullScreenButton.alpha = 1;
        }
    }];
}

- (void)fullScreenAction:(UIButton *)button {
    if (self.orientation == BRVideoPlayerViewOrientationNormal) {
        self.orientation = BRVideoPlayerViewOrientationFullScreen;
        [button setSelected:YES];
        self.originSuperView = self.superview;
        
        if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:didChangeToOrientation:)]) {
            [_delegate videoPlayerView:self didChangeToOrientation:self.orientation];
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        self.centerXConstraint = [self.centerXAnchor constraintEqualToAnchor:window.centerXAnchor];
        self.centerYConstraint = [self.centerYAnchor constraintEqualToAnchor:window.centerYAnchor];
        self.widthConstraint = [self.widthAnchor constraintEqualToConstant:window.bounds.size.height];
        self.heightConstraint = [self.heightAnchor constraintEqualToConstant:window.bounds.size.width];
        [UIView animateWithDuration:0.3 animations:^{
            self.centerXConstraint.active = YES;
            self.centerYConstraint.active = YES;
            self.widthConstraint.active = YES;
            self.heightConstraint.active = YES;
            self.playButtonSmallLeadingConstraint.constant = controlPanelPadding;
            self.restTimeLabelTrailingConstraint.constant = - 2 * controlPanelPadding;
            self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        }];
    }
    else if (self.orientation == BRVideoPlayerViewOrientationFullScreen) {
        self.orientation = BRVideoPlayerViewOrientationNormal;
        [button setSelected:NO];
        
        [self removeConstraints:@[self.centerXConstraint, self.centerYConstraint, self.widthConstraint, self.heightConstraint]];
        [self.originSuperView addSubview:self];
        if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:didChangeToOrientation:)]) {
            [_delegate videoPlayerView:self didChangeToOrientation:self.orientation];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.playButtonSmallLeadingConstraint.constant = 0;
            self.restTimeLabelTrailingConstraint.constant = - controlPanelPadding;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)dragSlider:(UISlider *)slider {
    NSTimeInterval totalTime = CMTimeGetSeconds(self.playerItem.duration);
    NSTimeInterval newTime = slider.value * totalTime;
    CMTime seekTime = CMTimeMake(newTime, 1);
    [self.player seekToTime:seekTime];
}

- (void)tapSlider:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.progressSlider];
    CGFloat value = touchPoint.x / self.progressSlider.bounds.size.width;
    [self.progressSlider setValue:value];
    
    NSTimeInterval totalTime = CMTimeGetSeconds(self.playerItem.duration);
    NSTimeInterval newTime = totalTime * value;
    CMTime seekTime = CMTimeMake(newTime, 1);
    [self.player seekToTime:seekTime];
}

- (void)sliderTouchDown {
    self.tapGesture.enabled = NO;
}

- (void)sliderTouchUp {
    self.tapGesture.enabled = YES;
}

#pragma mark - setter

- (void)setVideoLocalPath:(NSString *)videoLocalPath {
    _videoLocalPath = videoLocalPath;
    
    self.image = nil;

    [self setupPlayerWithURL:[NSURL fileURLWithPath:videoLocalPath]];
}

- (void)setVideoRemotePath:(NSString *)videoRemotePath {
    _videoRemotePath = videoRemotePath;
    
    self.image = nil;
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    [self setupPlayerWithURL:[NSURL URLWithString:videoRemotePath]];
}

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
    self.playerLayer.frame = self.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    __weak typeof(self) weakSelf = self;
    // 添加视频播放进度监听
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.playerItem.duration);
        weakSelf.progressSlider.value = currentTime / totalTime;
        weakSelf.currentTimeLabel.text = [weakSelf formatTimeFromDuration:currentTime];
        weakSelf.restTimeLabel.text = [weakSelf formatTimeFromDuration:totalTime - currentTime];
    }];
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    // 回到视频最开始
    [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        // 设置按钮状态
        [self.playButton setHidden:NO];
        [self.playButton setSelected:NO];
        [self.playButtonSmall setSelected:NO];
    }];
}

- (void)clickPlayButton:(UIButton *)button {
    BOOL isPlaying = button.isSelected;
    [self.playButton setSelected:!isPlaying];
    [self.playButtonSmall setSelected:!isPlaying];
    if (button.isSelected) {
        [self.playButton setHidden:YES];
    }
    
    if (self.player.rate == 0) {
        [self.player play];
    }
    else if (self.player.rate == 1.0) {
        [self.player pause];
    }
}

- (NSString *)formatTimeFromDuration:(NSTimeInterval)duration {
    NSInteger minute = duration / 60;
    NSInteger second = (NSInteger)duration % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
}

- (void)removeNotificationFromPlayerItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObserverFromPlayerItem {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)cleanUp {
    [self removeNotificationFromPlayerItem];
    [self removeObserverFromPlayerItem];
    
    if (_playerLayer) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
        [self.player removeTimeObserver:self.timeObserverToken];
        self.playerItem = nil;
        self.player = nil;
        self.playerLayer = nil;
    }
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

#pragma mark - 监听方法

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [MBProgressHUD hideHUDForView:self animated:YES];
            if (self.autoPlayWhenReady) {
                [self clickPlayButton:self.playButton];
            }
        }
        else if (status == AVPlayerStatusFailed) {
            
        }
        else {
            NSLog(@"AVPlayerStatusUnknown");
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        //        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        //        float startSeconds = CMTimeGetSeconds(timeRange.start);
        //        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //
        //        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        //        CGFloat totalDuration = CMTimeGetSeconds(playerItem.duration);
        //        hud.progress = timeInterval / totalDuration;
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
    }
}

- (void)dealloc {
    [self cleanUp];
}

@end
