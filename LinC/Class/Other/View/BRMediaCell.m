//
//  BRMediaCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMediaCell.h"
#import "BRMessageModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>

#define controlPanelPadding 15

@interface BRMediaCell () <UIScrollViewDelegate>
{
    MBProgressHUD *hud;
}

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, strong) UIButton *playButtonSmall;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *restTimeLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BRMediaCell

- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (UIScrollView *)imageScrollView {
    if (_imageScrollView == nil) {
        _imageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _imageScrollView.contentSize = self.bounds.size;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.minimumZoomScale = 1.0;
        _imageScrollView.maximumZoomScale = 5.0;
        _imageScrollView.delegate = self;
        [self.contentView addSubview:_imageScrollView];
    }
    return _imageScrollView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.imageScrollView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        // 添加菊花
        self.activityIndicator.center = _imageView.center;
        [_imageView addSubview:self.activityIndicator];
        // 添加手势
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [_imageView addGestureRecognizer:tap];
        [self.imageScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (UIView *)videoView {
    if (_videoView == nil) {
        _videoView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_videoView];
        
        // 添加菊花
        self.activityIndicator.center = _videoView.center;
        [_videoView addSubview:self.activityIndicator];
        
        // 添加手势
        _videoView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideo:)];
        [_videoView addGestureRecognizer:tap];
        
        // 添加backButton
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
        [_backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"close_highlighted"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_backButton];
        
        // 添加playButton
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _playButton.center = _videoView.center;
        [_playButton setImage:[UIImage imageNamed:@"play_big"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"pause_big"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setHidden:YES];
        [self.contentView addSubview:_playButton];
        
        
        // 添加控制台
        CGFloat controlPanelW = _videoView.bounds.size.width;
        CGFloat controlPanelH = 34;
        CGFloat controlPanelX = 0;
        CGFloat controlPanelY = _videoView.bounds.size.height - controlPanelH - iPhoneX_BOTTOM_HEIGHT;
        _controlPanel = [[UIView alloc] initWithFrame:CGRectMake(controlPanelX, controlPanelY, controlPanelW, controlPanelH)];
        _controlPanel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        
        _playButtonSmall = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, controlPanelH, controlPanelH)];
        [_playButtonSmall setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playButtonSmall setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playButtonSmall addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [_controlPanel addSubview:_playButtonSmall];
        
        CGFloat currentTimeLabelX = CGRectGetMaxX(_playButtonSmall.frame);
        CGFloat currentTimeLabelW = 44;
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentTimeLabelX, 0, currentTimeLabelW, controlPanelH)];
        [_currentTimeLabel setTextColor:[UIColor whiteColor]];
        [_currentTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_currentTimeLabel setText:@"00:00"];
        [_controlPanel addSubview:_currentTimeLabel];
        
        CGFloat progressSliderX = CGRectGetMaxX(_currentTimeLabel.frame);
        CGFloat progressSliderW = controlPanelW - _playButtonSmall.bounds.size.width - 2 * currentTimeLabelW - controlPanelPadding;
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(progressSliderX, 0, progressSliderW, controlPanelH)];
        [_progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventValueChanged];
        // 添加进度条点击手势
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSlider:)];
        [_progressSlider addGestureRecognizer:self.tapGesture];
        [_controlPanel addSubview:_progressSlider];
        
        CGFloat restTimeLabelX = CGRectGetMaxX(_progressSlider.frame) + 5;
        _restTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(restTimeLabelX, 0, currentTimeLabelW, controlPanelH)];
        [_restTimeLabel setTextColor:[UIColor whiteColor]];
        [_restTimeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_restTimeLabel setText:@"00:00"];
        [_controlPanel addSubview:_restTimeLabel];
        
        [self.contentView addSubview:_controlPanel];
        
    }
    return _videoView;
}

#pragma mark - touch methods

- (void)tapImage:(UITapGestureRecognizer *)tap {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didTapImage:)]) {
        [_delegate mediaCell:self didTapImage:self.image];
    }
}

- (void)tapVideo:(UITapGestureRecognizer *)tap {
    if (self.backButton.alpha) {
        self.backButton.alpha = 0;
        self.controlPanel.alpha = 0;
    }
    else {
        self.backButton.alpha = 1;
        self.controlPanel.alpha = 1;
    }
}

- (void)sliderTouchDown {
    self.tapGesture.enabled = NO;
}

- (void)sliderTouchUp {
    self.tapGesture.enabled = YES;
}

- (void)dragSlider:(UISlider *)slider {
    NSTimeInterval totalTime = CMTimeGetSeconds(self.playerItem.duration);
    NSTimeInterval newTime = slider.value * totalTime;
    CMTime seekTime = CMTimeMake(newTime, 1);
    [self.player seekToTime:seekTime];
}

- (void)tapSlider:(UITapGestureRecognizer *)tap {
    [self.player pause];
    CGPoint touchPoint = [tap locationInView:self.progressSlider];
    CGFloat value = touchPoint.x / self.progressSlider.bounds.size.width;
    [self.progressSlider setValue:value];
    
    NSTimeInterval totalTime = CMTimeGetSeconds(self.playerItem.duration);
    NSTimeInterval newTime = totalTime * value;
    CMTime seekTime = CMTimeMake(newTime, 1);
    [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didClickBackButton:)]) {
        [_delegate mediaCell:self didClickBackButton:button];
    }
}

- (NSString *)formatTimeFromDuration:(NSTimeInterval)duration {
    NSInteger minute, second;
    minute = duration / 60;
    second = (NSInteger)duration % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
}

- (void)cleanSubviews {
    if (_playerLayer) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
        [self.player removeTimeObserver:self.timeObserverToken];
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

- (void)setModel:(id<IMessageModel>)model {
    _model = model;
    if (model.bodyType == EMMessageBodyTypeImage) {
        if (_videoView) {
            [_videoView removeFromSuperview];
            _videoView = nil;
        }
        
        if (((EMImageMessageBody *)model.message.body).downloadStatus == EMDownloadStatusSucceed) {
            self.imageView.image = model.image ? model.image : [UIImage imageWithContentsOfFile:model.fileLocalPath];
        }
        else {
            self.imageView.image = model.thumbnailImage;
            [self.activityIndicator startAnimating];
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error && [self.model.messageId isEqualToString:message.messageId]) {
                    NSString *localPath = [(EMImageMessageBody *)message.body localPath];
                    self.imageView.image = [UIImage imageWithContentsOfFile:localPath];
                }
                [self.activityIndicator stopAnimating];
            }];
        }
    }
    else if (model.bodyType == EMMessageBodyTypeVideo) {
        if (_imageView) {
            [_imageView removeFromSuperview];
            _imageView = nil;
        }
        
        self.videoView.image = [UIImage imageWithContentsOfFile:model.thumbnailFileLocalPath];
        void (^block)(NSString *) = ^(NSString *localPath) {
            [self setupPlayerWithURL:[NSURL fileURLWithPath:localPath]];
            [self.videoView.layer insertSublayer:self.playerLayer atIndex:0];
            
            __weak typeof(self) weakSelf = self;
            // 添加视频播放进度监听
            self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                NSTimeInterval currentTime = CMTimeGetSeconds(time);
                NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.playerItem.duration);
                weakSelf.progressSlider.value = currentTime / totalTime;
                weakSelf.currentTimeLabel.text = [weakSelf formatTimeFromDuration:currentTime];
                weakSelf.restTimeLabel.text = [weakSelf formatTimeFromDuration:totalTime - currentTime];
            }];
        };
        if (((EMVideoMessageBody *)model.message.body).downloadStatus == EMDownloadStatusSucceed) {
            self.videoView.image = nil;
            NSString *localPath = [(EMVideoMessageBody *)model.message.body localPath];
            block(localPath);
        }
        else {
            [self.activityIndicator startAnimating];
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                [self.activityIndicator stopAnimating];
                if (!error) {
                    if ([self.model.messageId isEqualToString:message.messageId]) {
                        NSString *localPath = [(EMVideoMessageBody *)message.body localPath];
                        block(localPath);
                    }
                }
                else {
                    hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = error.errorDescription;
                    [hud hideAnimated:YES afterDelay:2.0];
                }
            }];
        }
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
        NSLog(@"开始缓存");
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
    }
}

- (void)dealloc {
    [self removeNotificationFromPlayerItem];
    [self removeObserverFromPlayerItem];
    [self cleanSubviews];
}

@end
