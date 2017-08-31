//
//  BRConversationModel.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRConversationModel.h"
#import <Hyphenate/EMConversation.h>

@implementation BRConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _title = _conversation.conversationId;
        if (conversation.type == EMConversationTypeChat) {
            _avatarImage = [UIImage imageNamed:@"user_default"];
        }
        else{
            _avatarImage = [UIImage imageNamed:@"group_default"];
        }
    }
    
    return self;
}

@end
