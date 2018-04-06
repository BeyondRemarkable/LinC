//
//  IModelChatCell.h
//  KnowN
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IModelCell.h"

/** @brief 消息cell的协议，实现了IModelCell协议 */

@protocol IModelChatCell <NSObject,IModelCell>

@required

/** @brief 消息对象model */
@property (strong, nonatomic) id model;

@optional

/*!
 @method
 @brief 判断是否需要自定义气泡
 @param model              消息对象model
 @return 是否需要自定义气泡
 */
- (BOOL)isCustomBubbleView:(id)model;

/*!
 @method
 @brief 根据消息model变更气泡样式
 @param model              消息对象
 */
- (void)setCustomBubbleView:(id)model;

/*!
 @method
 @brief 设置自定义cell的消息对象
 @param model              消息对象
 */
- (void)setCustomModel:(id)model;

/*!
 @method
 @brief 更新自定义气泡的边距
 @param bubbleMargin       待更新的边距
 @param model              消息对象
 */
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id)model;

@optional

/*!
 @method
 @brief 初始化消息cell
 @param style              cell的样式
 @param reuseIdentifier    cell的重用标识符
 @param model              消息对象
 @return UITableViewCell
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id)model;

@end
