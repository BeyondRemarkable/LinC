//
//  BRConversationListViewController.h
//  KnowN
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRRefreshTableViewController.h"
#import <Hyphenate/Hyphenate.h>

typedef enum : NSUInteger {
    BRConversationListDeleteConversationOnly,
    BRConversationListDeleteConversationWithMessages,
} BRConversationListDeleteType;

@interface BRConversationListViewController : BRRefreshTableViewController <EMChatManagerDelegate, EMGroupManagerDelegate>
/*!
 @method
 @brief 下拉加载更多
 */
- (void)tableViewDidTriggerHeaderRefresh;

/*!
 @method
 @brief 删除指定cell
 @discussion
 @result
*/
- (void)deleteCellAction:(NSIndexPath *)indexPath;

@end
