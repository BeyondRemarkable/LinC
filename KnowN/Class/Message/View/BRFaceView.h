//
//  BRFaceView.h
//  KnowN
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFacialView.h"

@protocol BRFaceDelegate

@required
/*!
 @method
 @brief 输入表情键盘的默认表情，或者点击删除按钮
 @param str       被选择的表情编码
 @param isDelete  是否为删除操作
 */
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;

/*!
 @method
 @brief 点击表情键盘的发送回调
 */
- (void)sendFace;

/*!
 @method
 @brief 点击表情键盘的自定义表情，直接发送
 @param emotion 自定义表情对象
 */
- (void)sendFaceWithEmotion:(BREmotion *)emotion;

@end

@interface BRFaceView : UIView <BRFacialViewDelegate>

@property (nonatomic, assign) id<BRFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

/*!
 @method
 @brief 通过数据源获取表情分组数
 @param emotionManagers 表情分组列表
 */
- (void)setEmotionManagers:(NSArray*)emotionManagers;

@end
