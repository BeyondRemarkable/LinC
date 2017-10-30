//
//  BRConversationModel.h
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IConversationModel.h"
#import "BRConversation+CoreDataClass.h"
@class EMConversation;

/** 会话对象模型 */
@interface BRConversationModel : NSObject <IConversationModel>

/** @brief 会话对象 */
@property (strong, nonatomic, readonly) EMConversation *conversation;
/** @brief 会话的标题(主要用户UI显示) */
@property (strong, nonatomic) NSString *title;
/** @brief conversationId的头像url */
@property (strong, nonatomic) NSString *avatarURLPath;
/** @brief conversationId的头像 */
@property (strong, nonatomic) UIImage *avatarImage;

@property (strong, nonatomic) NSString *conversationID;

@property (assign, nonatomic) int16_t chatType;

/*!
 @method
 @brief 初始化会话对象模型
 @param conversation    会话对象
 @return 会话对象模型
 */
- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
