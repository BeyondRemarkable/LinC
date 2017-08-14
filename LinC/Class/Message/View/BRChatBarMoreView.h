//
//  BRChatBarMoreView.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
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
 
 */
- (instancetype)initWithFrame:(CGRect)frame type:(BRChatToolbarType)type;

/*!
 @method
 @brief 新增一个新的功能按钮
 @param image 按钮图片
 @param highLightedImage 高亮图片
 @param title 按钮标题
 */
- (void)insertItemWithImage:(UIImage*)image
           highlightedImage:(UIImage*)highLightedImage
                      title:(NSString*)title;

/*!
 @method
 @brief 修改功能按钮图片
 @param image 按钮图片
 @param highLightedImage 高亮图片
 @param title 按钮标题
 @param index 按钮索引
 */
- (void)updateItemWithImage:(UIImage*)image
           highlightedImage:(UIImage*)highLightedImage
                      title:(NSString*)title
                    atIndex:(NSInteger)index;

/*!
 @method
 @brief 根据索引删除功能按钮
 @param index 按钮索引
 */
- (void)removeItematIndex:(NSInteger)index;

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

/*!
 @method
 @brief 自定义功能
 @param moreView    功能view
 @param index       按钮索引
 */
- (void)moreView:(BRChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index;

@end
