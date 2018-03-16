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

@interface BRVideoPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playButtonSmall;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *restTimeLabel;

@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BRVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 添加手势
        self.userInteractionEnabled = YES;
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideo:)];
        [self addGestureRecognizer:_tapGesture];
        
        // 添加playButton
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _playButton.center = self.center;
        [_playButton setImage:[UIImage imageNamed:@"play_big"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"pause_big"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setHidden:YES];
        [self addSubview:_playButton];
        
        // 添加控制台
        CGFloat controlH = 34;
        CGFloat controlPanelW = self.bounds.size.width;
        CGFloat controlPanelH = controlH + 20 + iPhoneX_BOTTOM_HEIGHT;
        CGFloat controlPanelX = 0;
        CGFloat controlPanelY = self.bounds.size.height - controlPanelH;
        _controlPanel = [[UIView alloc] initWithFrame:CGRectMake(controlPanelX, controlPanelY, controlPanelW, controlPanelH)];
        _controlPanel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        
        _playButtonSmall = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, controlH, controlH)];
        [_playButtonSmall setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playButtonSmall setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playButtonSmall addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_controlPanel addSubview:_playButtonSmall];
        
        CGFloat currentTimeLabelX = CGRectGetMaxX(_playButtonSmall.frame);
        CGFloat currentTimeLabelW = 44;
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentTimeLabelX, 10, currentTimeLabelW, controlH)];
        [_currentTimeLabel setTextColor:[UIColor whiteColor]];
        [_currentTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_currentTimeLabel setText:@"00:00"];
        [_controlPanel addSubview:_currentTimeLabel];
        
        CGFloat progressSliderX = CGRectGetMaxX(_currentTimeLabel.frame);
        CGFloat progressSliderW = controlPanelW - _playButtonSmall.bounds.size.width - 2 * currentTimeLabelW - controlPanelPadding;
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(progressSliderX, 10, progressSliderW, controlH)];
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
        
        CGFloat restTimeLabelX = CGRectGetMaxX(_progressSlider.frame) + 5;
        _restTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(restTimeLabelX, 10, currentTimeLabelW, controlH)];
        [_restTimeLabel setTextColor:[UIColor whiteColor]];
        [_restTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_restTimeLabel setText:@"00:00"];
        [_controlPanel addSubview:_restTimeLabel];
        
        [self addSubview:_controlPanel];
        
        // 添加backButton
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
        [_backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"close_highlighted"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        
        _isShowDownloadProcess = NO;
    }
    return self;
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

#pragma mark - Action

- (void)tapVideo:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.backButton.alpha) {
            self.backButton.alpha = 0;
            self.controlPanel.alpha = 0;
        }
        else {
            self.backButton.alpha = 1;
            self.controlPanel.alpha = 1;
        }
    }];
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
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    __weak typeof(self) weakSelf = self;
    // 添加视频播放进度监听
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.playerItem.duration);
        weakSelf.progressSlider.value = currentTime / totalTime;
        weakSelf.currentTimeLabel.text = [weakSelf formatTimeFromDuration:currentTime];
        weakSelf.restTimeLabel.text = [weakSelf formatTimeFromDuration:totalTime - currentTime];
    }];

    
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

- (void)clickBackButton:(UIButton *)button {
    [self cleanUp];

    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerView:didClickBackButton:)]) {
        [_delegate videoPlayerView:self didClickBackButton:button];
    }
}

- (NSString *)formatTimeFromDuration:(NSTimeInterval)duration {
    NSInteger minute = duration / 60;
    NSInteger second = (NSInteger)duration % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
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
            [self clickPlayButton:self.playButton];
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

@end
