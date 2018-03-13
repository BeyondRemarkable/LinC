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
{
    MBProgressHUD *hud;
}

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BRVideoPlayerView *videoView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

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
        _videoView.delegate = self;
        [self.contentView addSubview:_videoView];
        
        // 添加菊花
        self.activityIndicator.center = _videoView.center;
        [_videoView addSubview:self.activityIndicator];
        
    }
    return _videoView;
}

#pragma mark - touch methods

- (void)tapImage:(UITapGestureRecognizer *)tap {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didTapImage:)]) {
        [_delegate mediaCell:self didTapImage:self.image];
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
        
        self.videoView.image = model.thumbnailImage;
        EMDownloadStatus downloadStatus = ((EMVideoMessageBody *)model.message.body).downloadStatus;
        if (downloadStatus == EMDownloadStatusSucceed) {
            self.videoView.image = nil;
            self.videoView.videoLocalPath = [(EMVideoMessageBody *)model.message.body localPath];
        }
        else {
            [self.activityIndicator startAnimating];
            if (downloadStatus == EMDownloadStatusDownloading) {
                
            }
            else if (downloadStatus == EMDownloadStatusPending || downloadStatus == EMDownloadStatusFailed) {
                [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:^(int progress) {
                    
                } completion:^(EMMessage *message, EMError *error) {
                    [self.activityIndicator stopAnimating];
                    self.videoView.image = nil;
                    if (!error) {
                        if ([self.model.messageId isEqualToString:message.messageId]) {
                            self.videoView.videoLocalPath = [(EMVideoMessageBody *)message.body localPath];
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
}

#pragma mark - BRVideoPlayerViewDelegate
- (void)videoPlayerView:(BRVideoPlayerView *)view didClickBackButton:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(mediaCell:didClickBackButton:)]) {
        [_delegate mediaCell:self didClickBackButton:button];
    }
}

@end
