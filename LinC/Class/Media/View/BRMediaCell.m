//
//  BRMediaCell.m
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMediaCell.h"
#import "BRMessageModel.h"
#import "BRVideoPlayerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface BRMediaCell () <UIScrollViewDelegate, BRVideoPlayerViewDelegate>

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BRVideoPlayerView *videoView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) id<NSObject> videoObserver;
@property (nonatomic, strong) MBProgressHUD *hud;

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

- (BRVideoPlayerView *)videoView {
    if (_videoView == nil) {
        _videoView = [[BRVideoPlayerView alloc] initWithFrame:self.bounds];
        _videoView.autoPlayWhenReady = YES;
        _videoView.delegate = self;
        [self.contentView addSubview:_videoView];
        
        // 添加菊花
        self.activityIndicator.center = _videoView.center;
        [_videoView addSubview:self.activityIndicator];
        // 添加关闭按钮
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoView addSubview:self.closeButton];
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.closeButton.topAnchor constraintEqualToAnchor:_videoView.topAnchor constant:30].active = YES;
        [self.closeButton.leadingAnchor constraintEqualToAnchor:_videoView.leadingAnchor constant:30].active = YES;
        [self.closeButton.widthAnchor constraintEqualToConstant:30].active = YES;
        [self.closeButton.heightAnchor constraintEqualToAnchor:self.closeButton.widthAnchor].active = YES;
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"close_highlighted"] forState:UIControlStateHighlighted];
        [self.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoView;
}

#pragma mark - touch methods

- (void)tapImage:(UITapGestureRecognizer *)tap {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didTapImage:)]) {
        [_delegate mediaCell:self didTapImage:self.image];
    }
}

- (void)closeAction:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didClickBackButton:)]) {
        [_delegate mediaCell:self didClickBackButton:button];
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - setter

- (void)setModel:(id<IMessageModel>)model {
    _model = model;
    if (model.bodyType == EMMessageBodyTypeImage) {
        if (_videoView) {
            [_videoView removeFromSuperview];
            _videoView = nil;
        }
        
        EMDownloadStatus downloadStatus = ((EMImageMessageBody *)model.message.body).downloadStatus;
        if (downloadStatus == EMDownloadStatusSucceed) {
            self.imageView.image = model.image ? model.image : [UIImage imageWithContentsOfFile:model.fileLocalPath];
        }
        else {
            self.imageView.image = model.thumbnailImage;
            [self.activityIndicator startAnimating];
            __weak NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            __weak typeof(self) weakSelf = self;
            // 图片正在下载
            if (downloadStatus == EMDownloadStatusDownloading) {
                id __block observer = [center addObserverForName:BRImageMessageDownloadResultNotification object:model.message queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                    [weakSelf.activityIndicator stopAnimating];
                    EMError *error = note.userInfo[@"error"];
                    if (error) {
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.contentView animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeText;
                        weakSelf.hud.label.text = [NSString stringWithFormat:@"ERROR\n%@", error.errorDescription];
                        [weakSelf.hud hideAnimated:YES afterDelay:2.0];
                    }
                    else {
                        NSString *localPath = note.userInfo[@"path"];
                        weakSelf.imageView.image = [UIImage imageWithContentsOfFile:localPath];
                    }
                    [center removeObserver:observer];
                }];
            }
            // 图片准备下载或者下载失败
            else {
                [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:^(int progress) {
                    
                } completion:^(EMMessage *message, EMError *error) {
                    if (!error) {
                        NSString *localPath = [(EMImageMessageBody *)message.body localPath];
                        [center postNotificationName:BRImageMessageDownloadResultNotification object:message userInfo:@{@"path":localPath}];
                        if ([weakSelf.model.messageId isEqualToString:message.messageId]) {
                            weakSelf.imageView.image = [UIImage imageWithContentsOfFile:localPath];
                        }
                    }
                    else {
                        [center postNotificationName:BRImageMessageDownloadResultNotification object:message userInfo:@{@"error":error}];
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.contentView animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeText;
                        weakSelf.hud.label.text = [NSString stringWithFormat:@"ERROR\n%@", error.errorDescription];
                        [weakSelf.hud hideAnimated:YES afterDelay:2.0];
                    }
                    [weakSelf.activityIndicator stopAnimating];
                }];
            }
        }
    }
    else if (model.bodyType == EMMessageBodyTypeVideo) {
        if (_imageView) {
            [_imageView removeFromSuperview];
            _imageView = nil;
        }
        
        self.videoView.image = model.thumbnailImage;
        EMDownloadStatus downloadStatus = ((EMVideoMessageBody *)model.message.body).downloadStatus;
        // 视频已经下载成功
        if (downloadStatus == EMDownloadStatusSucceed) {
            self.videoView.image = nil;
            self.videoView.videoLocalPath = [(EMVideoMessageBody *)model.message.body localPath];
        }
        else {
            __weak NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            __weak typeof(self) weakSelf = self;
            // 视频正在下载
            if (downloadStatus == EMDownloadStatusDownloading) {
                self.videoView.showDownloadProcess = YES;
                self.videoObserver = [center addObserverForName:BRVideoMessageDownloadResultNotification object:model.message queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                    EMError *error = note.userInfo[@"error"];
                    if (error) {
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.contentView animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeText;
                        weakSelf.hud.label.text = [NSString stringWithFormat:@"ERROR\n%@", error.errorDescription];
                        [weakSelf.hud hideAnimated:YES afterDelay:2.0];
                    }
                    else {
                        NSNumber *progressNumber = note.userInfo[@"progress"];
                        if (progressNumber) {
                            weakSelf.videoView.downloadProgress = [progressNumber doubleValue];
                        }
                        else {
                            weakSelf.videoView.image = nil;
                            weakSelf.videoView.showDownloadProcess = NO;
                            NSString *localPath = note.userInfo[@"path"];
                            weakSelf.videoView.videoLocalPath = localPath;
                        }
                    }
                }];
            }
            // 视频准备下载或者下载失败
            else if (downloadStatus == EMDownloadStatusPending || downloadStatus == EMDownloadStatusFailed) {
                self.videoView.showDownloadProcess = YES;
                [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:^(int progress) {
                    weakSelf.videoView.downloadProgress = progress/100.0;
                    [center postNotificationName:BRVideoMessageDownloadResultNotification object:model.message userInfo:@{@"progress":@(progress/100.0)}];
                } completion:^(EMMessage *message, EMError *error) {
                    weakSelf.videoView.image = nil;
                    weakSelf.videoView.showDownloadProcess = NO;
                    if (!error) {
                        NSString *localPath = [(EMVideoMessageBody *)message.body localPath];
                        [center postNotificationName:BRVideoMessageDownloadResultNotification object:message userInfo:@{@"path":localPath}];
                        if ([weakSelf.model.messageId isEqualToString:message.messageId]) {
                            weakSelf.videoView.videoLocalPath = localPath;
                        }
                    }
                    else {
                        [center postNotificationName:BRVideoMessageDownloadResultNotification object:message userInfo:@{@"error":error}];
                        weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.contentView animated:YES];
                        weakSelf.hud.mode = MBProgressHUDModeText;
                        weakSelf.hud.label.text = [NSString stringWithFormat:@"ERROR\n%@", error.errorDescription];
                        [weakSelf.hud hideAnimated:YES afterDelay:2.0];
                    }
                }];
            }
        }
    }
}

#pragma mark - BRVideoPlayerViewDelegate

- (void)videoPlayerViewIsTapped:(BRVideoPlayerView *)view {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.closeButton.alpha) {
            self.closeButton.alpha = 0;
        }
        else {
            self.closeButton.alpha = 1;
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.videoObserver];
}

@end
