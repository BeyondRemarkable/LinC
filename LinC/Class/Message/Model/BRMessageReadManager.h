//
//  BRMessageReadManager.h
//  LinC
//
//  Created by Yingwei Fan on 8/12/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRMessageModel.h"

typedef void (^FinishBlock)(BOOL success);
typedef void (^PlayBlock)(BOOL playing, BRMessageModel *messageModel);

@interface BRMessageReadManager : NSObject

@property (strong, nonatomic) FinishBlock finishBlock;

@property (strong, nonatomic) BRMessageModel *audioMessageModel;

+ (id)defaultManager;

/*!
 @method
 @brief 显示图片消息原图
 @param modelArray   模型数组，需要传入BRMessageModel对象
 */
- (void)showBrowserWithModels:(NSArray *)modelArray animated:(BOOL)animated;

/*!
 @method
 @brief 语音消息是否可以播放
 @discussion 若传入的语音消息正在播放，停止播放并重置isMediaPlaying，返回NO；否则当前语音消息isMediaPlaying设为yes，记录的上一条语音消息isMediaPlaying重置，更新消息ext，返回yes
 @param messageModel   选中的语音消息model
 @param updateCompletion  语音消息model更新后的回调
 @return BOOL
 */
- (BOOL)prepareMessageAudioModel:(BRMessageModel *)messageModel
            updateViewCompletion:(void (^)(BRMessageModel *prevAudioModel, BRMessageModel *currentAudioModel))updateCompletion;

/*!
 @method
 @brief 重置正在播放状态为NO，返回对应的语音消息model
 @discussion 重置正在播放状态为NO，返回对应的语音消息model，若当前记录的消息不为语音消息，返回nil
 @return  返回修改后的语音消息model
 */
- (BRMessageModel *)stopMessageAudioModel;

@end
