//
//  BRVideoControlPanel.m
//  LinC
//
//  Created by Yingwei Fan on 3/27/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRVideoControlPanel.h"

@interface BRVideoControlPanel ()

@property (nonatomic, strong) NSLayoutConstraint *playButtonLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *restTimeLabelTrailingConstraint;

@end

@implementation BRVideoControlPanel

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    // 添加播放按钮
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    _playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_playButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:controlPanelPadding].active = YES;
    _playButtonLeadingConstraint = [_playButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _playButtonLeadingConstraint.active = YES;
    [_playButton.widthAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    [_playButton.heightAnchor constraintEqualToAnchor:_playButton.widthAnchor].active = YES;
    
    // 添加已经播放的时间
    CGFloat timeLabelW = 35;
    _currentTimeLabel = [[UILabel alloc] init];
    [_currentTimeLabel setTextColor:[UIColor whiteColor]];
    [_currentTimeLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_currentTimeLabel setText:@"00:00"];
    [self addSubview:_currentTimeLabel];
    _currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_currentTimeLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:controlPanelPadding].active = YES;
    [_currentTimeLabel.leadingAnchor constraintEqualToAnchor:_playButton.trailingAnchor].active = YES;
    [_currentTimeLabel.widthAnchor constraintEqualToConstant:timeLabelW].active = YES;
    [_currentTimeLabel.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    
    // 添加播放的剩余时间
    _restTimeLabel = [[UILabel alloc] init];
    [_restTimeLabel setTextColor:[UIColor whiteColor]];
    [_restTimeLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_restTimeLabel setText:@"00:00"];
    [self addSubview:_restTimeLabel];
    _restTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_restTimeLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:controlPanelPadding].active = YES;
    _restTimeLabelTrailingConstraint = [_restTimeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-controlPanelPadding];
    _restTimeLabelTrailingConstraint.active = YES;
    [_restTimeLabel.widthAnchor constraintEqualToConstant:timeLabelW].active = YES;
    [_restTimeLabel.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    
    // 添加缓冲条
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_progressView setProgressTintColor:[UIColor grayColor]];
    [_progressView setTrackTintColor:[UIColor blackColor]];
    [self addSubview:_progressView];
    _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressView.leadingAnchor constraintEqualToAnchor:_currentTimeLabel.trailingAnchor constant:controlPanelPadding].active = YES;
    [_progressView.trailingAnchor constraintEqualToAnchor:_restTimeLabel.leadingAnchor constant:-controlPanelPadding].active = YES;
    [_progressView.heightAnchor constraintEqualToConstant:2].active = YES;
    [_progressView.centerYAnchor constraintEqualToAnchor:_currentTimeLabel.centerYAnchor].active = YES;
    
    // 添加进度条
    _progressSlider = [[UISlider alloc] init];
    [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [_progressSlider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [_progressSlider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_progressSlider];
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressSlider.leadingAnchor constraintEqualToAnchor:_progressView.leadingAnchor].active = YES;
    [_progressSlider.trailingAnchor constraintEqualToAnchor:_progressView.trailingAnchor].active = YES;
    [_progressSlider.heightAnchor constraintEqualToConstant:controlPanelHeight].active = YES;
    [_progressSlider.centerYAnchor constraintEqualToAnchor:_progressView.centerYAnchor constant:-1].active = YES;
    // 添加点击手势覆盖superview的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Action

- (void)playAction:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(controlPanelDidClickPlay:)]) {
        [_delegate controlPanelDidClickPlay:self];
    }
}

- (void)dragSlider:(UISlider *)slider {
    if (_delegate && [_delegate respondsToSelector:@selector(controlPanel:didDragSliderTo:)]) {
        [_delegate controlPanel:self didDragSliderTo:slider.value];
    }
}

- (void)sliderTouchDown {
    if (_delegate && [_delegate respondsToSelector:@selector(controlPanelSliderDidTouchDown:)]) {
        [_delegate controlPanelSliderDidTouchDown:self];
    }
}

- (void)sliderTouchUp {
    if (_delegate && [_delegate respondsToSelector:@selector(controlPanelSliderDidTouchUp:)]) {
        [_delegate controlPanelSliderDidTouchUp:self];
    }
}

#pragma mark - public

- (void)compressControlSize {
    self.playButtonLeadingConstraint.constant = controlPanelPadding;
    self.restTimeLabelTrailingConstraint.constant = - 2*controlPanelPadding;
}

- (void)extendControlSize {
    self.playButtonLeadingConstraint.constant = 0;
    self.restTimeLabelTrailingConstraint.constant = - controlPanelPadding;
}

@end
