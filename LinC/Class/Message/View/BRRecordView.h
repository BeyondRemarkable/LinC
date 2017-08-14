//
//  BRRecordView.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    BRRecordViewTypeTouchDown,
    BRRecordViewTypeTouchUpInside,
    BRRecordViewTypeTouchUpOutside,
    BRRecordViewTypeDragInside,
    BRRecordViewTypeDragOutside,
}BRRecordViewType;

@interface BRRecordView : UIView

@property (nonatomic) NSArray *voiceMessageAnimationImages UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSString *upCancelText UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSString *loosenCancelText UI_APPEARANCE_SELECTOR;

/*
 @method
 @brief 录音按钮按下
 @discussion
 @param
 @result
 */
-(void)recordButtonTouchDown;

/*
 @method
 @brief 手指在录音按钮内部时离开
 @discussion
 @param
 @result
 */
-(void)recordButtonTouchUpInside;

/*
 @method
 @brief 手指在录音按钮外部时离开
 @discussion
 @param
 @result
 */
-(void)recordButtonTouchUpOutside;

/*
 @method
 @brief 手指移动到录音按钮内部
 @discussion
 @param
 @result
 */
-(void)recordButtonDragInside;

/*
 @method
 @brief 手指移动到录音按钮外部
 @discussion
 @param
 @result
 */
-(void)recordButtonDragOutside;

@end
