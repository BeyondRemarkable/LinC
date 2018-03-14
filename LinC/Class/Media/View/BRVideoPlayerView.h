//
//  BRVideoPlayerView.h
//  LinC
//
//  Created by Yingwei Fan on 3/13/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BRVideoPlayerView;

@protocol BRVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerView:(BRVideoPlayerView *)view didClickBackButton:(UIButton *)button;

@end

@interface BRVideoPlayerView : UIImageView

@property (nonatomic, assign) BOOL isShowDownloadProcess;

@property (nonatomic, assign) BOOL showDownloadProcess;

@property (nonatomic, assign) double downloadProgress;


@property (nonatomic, copy) NSString *videoLocalPath;

@property (nonatomic, weak) id<BRVideoPlayerViewDelegate> delegate;

@end
