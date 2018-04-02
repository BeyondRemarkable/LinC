//
//  BRVideoPlayerViewController.m
//  LinC
//
//  Created by Yingwei Fan on 3/20/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "BRVideoPlayerViewController.h"
#import "BRVideoPlayerView.h"
#import "BRClientManager.h"

@interface BRVideoPlayerViewController () <BRVideoPlayerViewDelegate>

@property (nonatomic, strong) BRVideoPlayerView *videoView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *instructorLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *purchaseButton;
@property (nonatomic, strong) MBProgressHUD *buttonHUD;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, strong) NSLayoutConstraint *videoTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoHeightConstraint;

@end

@implementation BRVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BRColor(248, 248, 248);
    _statusBarHidden = NO;
    [self setupSubviews];
    
    [self updateUIFromModel];
}

- (void)setupSubviews {
    CGFloat padding = 10;
    
    UILayoutGuide *margin = self.view.layoutMarginsGuide;
    
    CGFloat labelH = 30;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:_titleLabel];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleLabel.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:padding].active = YES;
    [_titleLabel.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor].active = YES;
    [_titleLabel.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    [_titleLabel.heightAnchor constraintEqualToConstant:labelH].active = YES;
    
    _instructorLabel = [[UILabel alloc] init];
    _instructorLabel.font = [UIFont systemFontOfSize:17.0];
    [self.view addSubview:_instructorLabel];
    _instructorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_instructorLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor].active = YES;
    [_instructorLabel.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor].active = YES;
    [_instructorLabel.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    [_instructorLabel.heightAnchor constraintEqualToConstant:labelH].active = YES;
    
    _videoView = [[BRVideoPlayerView alloc] init];
    _videoView.fullScreenEnabled = YES;
    _videoView.delegate = self;
    [self.view addSubview:_videoView];
    _videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupVideoViewConstraint];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = [UIColor grayColor];
    _detailLabel.textAlignment = NSTextAlignmentJustified;
    [self.view addSubview:_detailLabel];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_detailLabel.topAnchor constraintEqualToAnchor:_instructorLabel.bottomAnchor constant:SCREEN_WIDTH].active = YES;
    [_detailLabel.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor].active = YES;
    [_detailLabel.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    [_detailLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomLayoutGuide.topAnchor constant:-padding].active = YES;
}

- (void)setupVideoViewConstraint {
    UILayoutGuide *margin = self.view.layoutMarginsGuide;
    CGFloat padding = 10;
    
    _videoTopConstraint = [_videoView.topAnchor constraintEqualToAnchor:_instructorLabel.bottomAnchor constant:padding];
    _videoLeadingConstraint = [_videoView.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor];
    _videoTrailingConstraint = [_videoView.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor];
    _videoHeightConstraint = [_videoView.heightAnchor constraintEqualToAnchor:_videoView.widthAnchor];
    _videoTopConstraint.active = YES;
    _videoLeadingConstraint.active = YES;
    _videoTrailingConstraint.active = YES;
    _videoHeightConstraint.active = YES;
}

- (void)updateUIFromModel {
    self.titleLabel.text = self.model.title;
    self.instructorLabel.text = self.model.instructor;
    if (self.model.thumbnailImage) {
        self.videoView.image = self.model.thumbnailImage;
    }
    else {
        [self.videoView sd_setImageWithURL:[NSURL URLWithString:self.model.thumbnailURL]];
    }
    
    if (self.videoView) {
        self.buttonHUD = [MBProgressHUD showHUDAddedTo:self.videoView animated:NO];
        self.buttonHUD.mode = MBProgressHUDModeText;
        if (self.model.price != 0) {
            [self.buttonHUD.button setTitle:NSLocalizedString(@"Purchase", nil) forState:UIControlStateNormal];
            [self.buttonHUD.button addTarget:self action:@selector(purchaseAction) forControlEvents:UIControlEventTouchUpInside];
            self.buttonHUD.label.text = [NSString stringWithFormat:@"￥%.1f", self.model.price];
        }
        else {
            [self.buttonHUD.button setTitle:NSLocalizedString(@"Watch Now", nil) forState:UIControlStateNormal];
            [self.buttonHUD.button addTarget:self action:@selector(watchAction) forControlEvents:UIControlEventTouchUpInside];
            self.buttonHUD.label.text = NSLocalizedString(@"Free", nil);
        }
    }
    self.detailLabel.text = [NSString stringWithFormat:@"Description:\n%@", self.model.detail];
}

#pragma mark - getter

- (UIButton *)purchaseButton {
    if (_purchaseButton == nil) {
        _purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        [_purchaseButton setBackgroundImage:[UIImage imageNamed:@"background_blue"] forState:UIControlStateNormal];
        [_purchaseButton setBackgroundImage:[UIImage imageNamed:@"background_blue_highlighted"] forState:UIControlStateHighlighted];
        _purchaseButton.titleLabel.text = NSLocalizedString(@"Purchase", nil);
    }
    return _purchaseButton;
}

#pragma mark - setter

- (void)setModel:(BRLectureVideoModel *)model {
    _model = model;
    
    [self updateUIFromModel];
}

#pragma mark - Action

- (void)purchaseAction {
    
}

- (void)watchAction {
    self.buttonHUD.mode = MBProgressHUDModeIndeterminate;
    self.buttonHUD.label.text = nil;
    [self.buttonHUD.button removeTarget:self action:@selector(watchAction) forControlEvents:UIControlEventTouchUpInside];
    [[BRClientManager sharedManager] getVideoURLWithID:self.model.identifier success:^(NSString *urlString) {
        [self.buttonHUD hideAnimated:YES];
        NSString *url = [kVideoBaseURL stringByAppendingPathComponent:urlString];
        self.videoView.videoRemotePath = url;
    } failure:^(EMError *error) {
        self.buttonHUD.mode = MBProgressHUDModeText;
        self.buttonHUD.label.text = error.errorDescription;
        [self.buttonHUD.button setTitle:NSLocalizedString(@"Try Again", nil) forState:UIControlStateNormal];
        [self.buttonHUD.button addTarget:self action:@selector(watchAction) forControlEvents:UIControlEventTouchUpInside];
    }];
}

#pragma mark - BRVideoPlayerViewDelegate

- (void)videoPlayerView:(BRVideoPlayerView *)view didChangeToOrientation:(BRVideoPlayerViewOrientation)orientation {
    if (orientation == BRVideoPlayerViewOrientationNormal) {
        self.statusBarHidden = NO;
        [self setupVideoViewConstraint];
    }
    else if (orientation == BRVideoPlayerViewOrientationFullScreen) {
        self.statusBarHidden = YES;
        [view removeConstraints:@[self.videoTopConstraint, self.videoLeadingConstraint, self.videoTrailingConstraint, self.videoHeightConstraint]];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)dealloc {
    [self.videoView destroyPlayer];
}

@end
