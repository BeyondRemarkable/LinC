//
//  BRConversationModel.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRConversationModel.h"
#import <Hyphenate/EMConversation.h>
#import "BRUserInfo+CoreDataClass.h"
#import "BRCoreDataManager.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRGroup+CoreDataClass.h"
@implementation BRConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        if (_conversation.type == EMConversationTypeChat) {
            [self setupConversationTypeChat:conversation];
        }
        else if(_conversation.type == EMConversationTypeGroupChat){
            [self setupConversationGroupChat:_conversation];
        }
    }
    return self;
}


/**
 从core data 给单聊会话模型赋值（头像和标题）

 @param conversation conversation 单聊会话模型
 */
- (void)setupConversationTypeChat: (EMConversation *)conversation {
    
    BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:conversation.conversationId];
    if (friendInfo.nickname) {
        _title = friendInfo.nickname;
    } else {
        _title = _conversation.conversationId;
    }
    
    if (!friendInfo.avatar) {
        _avatarImage = [UIImage imageNamed:@"user_default"];
    } else {
       _avatarImage = [UIImage imageWithData:friendInfo.avatar];
    }
}

/**
 从core data 给群聊会话模型赋值（头像和标题）
 
 @param conversation conversation 群聊会话模型
 */
- (void)setupConversationGroupChat:(EMConversation *)conversation {
    BRGroup *group = [[[BRCoreDataManager sharedInstance] fetchGroupsWithGroupID:conversation.conversationId] lastObject];
    _title = group.groupName;
    if (group.groupIcon) {
        _avatarImage = [UIImage imageWithData:group.groupIcon];
    } else {
        _avatarImage = [UIImage imageNamed:@"group_default"];
    }
    
//    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
//    for (EMGroup *group in groupArray) {
//        if ([group.groupId isEqualToString:conversation.conversationId]) {
//            _title = group.subject;
//
//        }
//    }
}

@end
