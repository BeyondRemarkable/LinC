//
//  BRVideoControlPanel.h
//  KnowN
//
//  Created by Yingwei Fan on 3/27/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

@class BRVideoControlPanel;
#import <UIKit/UIKit.h>

#define controlPanelPadding 10
#define controlPanelHeight 34

@protocol BRVideoControlPanelDelegate <NSObject>

@optional
- (void)controlPanelDidClickPlay:(BRVideoControlPanel *)controlPanel;

- (void)controlPanel:(BRVideoControlPanel *)controlPanel didDragSliderTo:(float)value;

- (void)controlPanelSliderDidTouchDown:(BRVideoControlPanel *)controlPanel;

- (void)controlPanelSliderDidTouchUp:(BRVideoControlPanel *)controlPanel;

@end

@interface BRVideoControlPanel : UIView

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *restTimeLabel;

- (void)compressControlSize;

- (void)extendControlSize;

@property (nonatomic, weak) id<BRVideoControlPanelDelegate> delegate;

@end
