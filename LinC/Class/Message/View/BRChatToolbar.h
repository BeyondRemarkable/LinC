//
//  BRChatToolbar.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BRFaceView.h"
#import "BRTextView.h"
#import "BRRecordView.h"
#import "BRChatBarMoreView.h"
#import "BRChatToolbarItem.h"

#define kTouchToRecord NSLocalizedString(@"message.toolBar.record.touch", @"hold down to talk")
#define kTouchToFinish NSLocalizedString(@"message.toolBar.record.send", @"loosen to send")

@protocol BRChatToolbarDelegate;
@interface BRChatToolbar : UIView

@property (weak, nonatomic) id<BRChatToolbarDelegate> delegate;

@property (nonatomic) UIImage *backgroundImage;

@property (nonatomic, readonly) BRChatToolbarType chatBarType;

@property (nonatomic, readonly) CGFloat inputViewMaxHeight;

@property (nonatomic, readonly) CGFloat inputViewMinHeight;

@property (nonatomic, readonly) CGFloat horizontalPadding;

@property (nonatomic, readonly) CGFloat verticalPadding;

@property (strong, nonatomic) NSArray *inputViewLeftItems;

@property (strong, nonatomic) NSArray *inputViewRightItems;

@property (strong, nonatomic) BRTextView *inputTextView;

@property (strong, nonatomic) UIView *moreView;

@property (strong, nonatomic) UIView *faceView;

@property (strong, nonatomic) UIView *recordView;

- (instancetype)initWithFrame:(CGRect)frame
                         type:(BRChatToolbarType)type;

/**
 *  Initializa chat bar
 * @param horizontalPadding  default 8
 * @param verticalPadding    default 5
 * @param inputViewMinHeight default 36
 * @param inputViewMaxHeight default 150
 * @param type               default BRChatToolbarTypeGroup
 */
- (instancetype)initWithFrame:(CGRect)frame
            horizontalPadding:(CGFloat)horizontalPadding
              verticalPadding:(CGFloat)verticalPadding
           inputViewMinHeight:(CGFloat)inputViewMinHeight
           inputViewMaxHeight:(CGFloat)inputViewMaxHeight
                         type:(BRChatToolbarType)type;

/*!
 @method
 @brief 获取chatToolBar默认的高度
 @result  返回chatToolBar默认的高度
 */
+ (CGFloat)defaultHeight;


- (void)cancelTouchRecord;

/*!
 @method
 @brief 切换底部的菜单视图
 @param bottomView 待切换的菜单
 */
- (void)willShowBottomView:(UIView *)bottomView;

@end

@protocol BRChatToolbarDelegate <NSObject>

@optional

/*
 *  文字输入框开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(BRTextView *)inputTextView;

/*
 *  文字输入框将要开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(BRTextView *)inputTextView;

/*
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

/*
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 *  @param ext 扩展消息
 */
- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext;

/*
 *  在光标location位置处是否插入字符@
 *
 *  @param location 光标位置
 */
- (BOOL)didInputAtInLocation:(NSUInteger)location;

/*
 *  在光标location位置处是否删除字符@
 *
 *  @param location 光标位置
 */
- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location;

/*
 *  发送第三方表情，不会添加到文字输入框中
 *
 *  @param faceLocalPath 选中的表情的本地路径
 */
- (void)didSendFace:(NSString *)faceLocalPath;

/*
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView;

/*
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;

/*
 *  松开手指完成录音
 */
- (void)didFinishRecordingVoiceAction:(UIView *)recordView;

/*
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction:(UIView *)recordView;

/*
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction:(UIView *)recordView;

@required

/*
 *  高度变到toHeight
 */
- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight;

@end
