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
#import "BRConversation+CoreDataClass.h"
#import "BRCoreDataManager.h"
@implementation BRConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _title = _conversation.conversationId;
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        BRUserInfo *userInfo = [[BRCoreDataManager sharedInstance] fetchUserInfoBy:username];
        
        for (BRConversation *brconversation in userInfo.conversation) {
            if ([brconversation.conversationId isEqualToString:conversation.conversationId]) {
                self.from = brconversation.from;
            }
        }
        
        if (_conversation.type == EMConversationTypeChat) {
            _avatarImage = [UIImage imageNamed:@"user_default"];
        }
        else{
            _avatarImage = [UIImage imageNamed:@"group_default"];
        }
    }
    
    return self;
}

@end
