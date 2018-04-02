//
//  BRVideoPlayerView.h
//  LinC
//
//  Created by Yingwei Fan on 3/13/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BRVideoPlayerView;

typedef enum {
    BRVideoPlayerViewOrientationNormal,
    BRVideoPlayerViewOrientationFullScreen
} BRVideoPlayerViewOrientation;

@protocol BRVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerViewIsTapped:(BRVideoPlayerView *)view;

- (void)videoPlayerView:(BRVideoPlayerView *)view didChangeToOrientation:(BRVideoPlayerViewOrientation)orientation;

@end

@interface BRVideoPlayerView : UIImageView

@property (nonatomic, assign) BOOL isShowDownloadProcess;

@property (nonatomic, assign) BOOL showDownloadProcess;

@property (nonatomic, assign) double downloadProgress;

@property (nonatomic, assign) BOOL fullScreenEnabled;

@property (nonatomic, assign) BOOL rotateWithDevice;

@property (nonatomic, assign) BOOL autoPlayWhenReady;

@property (nonatomic, assign) NSTimeInterval controlPanelDisappearTime;


@property (nonatomic, copy) NSString *videoLocalPath;
@property (nonatomic, copy) NSString *videoRemotePath;

@property (nonatomic, assign) BRVideoPlayerViewOrientation orientation;


@property (nonatomic, weak) id<BRVideoPlayerViewDelegate> delegate;

- (void)destroyPlayer;

@end
