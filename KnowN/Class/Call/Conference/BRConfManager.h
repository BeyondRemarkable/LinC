//
//  BRConfManager.h
//
//  Copyright © 2016 zhe wu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KNOTIFICATION_CONFERENCE @"conference"


@interface BRConfManager : NSObject


+ (instancetype)sharedManager;

- (void)createConferenceWithFriendsList:(NSMutableArray *)friendArray fromGroupID:(NSString *)groupID;

- (void)pushCustomVideoConferenceController;

@end
