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
            _avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
        }
        else{
            _avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
        }
    }
    
    return self;
}

@end
