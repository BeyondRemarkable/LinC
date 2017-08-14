//
//  BRFacialView.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BREmotion;
@protocol BRFacialViewDelegate

@optional

/*!
 @method
 @brief 选中默认表情
 @param str 选中的默认表情
 */
-(void)selectedFacialView:(NSString*)str;

/*!
 @method
 @brief 删除默认表情
 */
-(void)deleteSelected:(NSString *)str;

/*!
 @method
 @brief 点击表情键盘的发送回调
 */
-(void)sendFace;

/*!
 @method
 @brief 选择自定义表情，直接发送
 @param emotion    被选中的自定义表情
 */
-(void)sendFace:(BREmotion *)emotion;

@end

@class BREmotionManager;
@interface BRFacialView : UIView

{
    NSMutableArray *_faces;
}

@property(nonatomic, weak) id<BRFacialViewDelegate> delegate;

@property(strong, nonatomic, readonly) NSArray *faces;

-(void)loadFacialView:(NSArray*)emotionManagers size:(CGSize)size;

-(void)loadFacialViewWithPage:(NSInteger)page;

@end
