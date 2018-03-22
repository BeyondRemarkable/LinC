//
//  BRChatBarMoreView.h
//  LinC
//
//  Created by Yingwei Fan on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    BRChatToolbarTypeChat,
    BRChatToolbarTypeGroup,
}BRChatToolbarType;

@protocol BRChatBarMoreViewDelegate;
@interface BRChatBarMoreView : UIView

@property (nonatomic,assign) id<BRChatBarMoreViewDelegate> delegate;

@property (nonatomic) UIColor *moreViewBackgroundColor UI_APPEARANCE_SELECTOR;  //moreview背景颜色,default whiteColor

/*
 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame type:(BRChatToolbarType)type;

@end

@protocol BRChatBarMoreViewDelegate <NSObject>

@optional

/*!
 @method
 @brief 拍照
 @param moreView 功能view
 */
- (void)moreViewTakePicAction:(BRChatBarMoreView *)moreView;

/*!
 @method
 @brief 相册
 @param moreView 功能view
 */
- (void)moreViewPhotoAction:(BRChatBarMoreView *)moreView;

/*!
 @method
 @brief 发送位置
 @param moreView 功能view
 */
- (void)moreViewLocationAction:(BRChatBarMoreView *)moreView;

/*!
 @method
 @brief 拨打实时语音
 @param moreView 功能view
 */
- (void)moreViewAudioCallAction:(BRChatBarMoreView *)moreView;

/*!
 @method
 @brief 拨打实时通话
 @param moreView 功能view
 */
- (void)moreViewVideoCallAction:(BRChatBarMoreView *)moreView;

@end
