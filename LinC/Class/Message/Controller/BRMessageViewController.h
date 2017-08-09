//
//  BRMessageViewController.h
//  LinC
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRRefreshTableViewController.h"
#import <Hyphenate/EMConversation.h>

@interface BRMessageViewController : BRRefreshTableViewController

/*!
 @method
 @brief 初始化聊天页面
 @param conversationChatter 会话对方的用户名. 如果是群聊, 则是群组的id
 @param conversationType 会话类型
 */
- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType;

@end
