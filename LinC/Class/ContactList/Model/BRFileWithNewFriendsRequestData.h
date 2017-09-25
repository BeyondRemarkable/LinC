//
//  BRFileWithNewFriendsRequestData.h
//  LinC
//
//  Created by zhe wu on 9/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRFileWithNewFriendsRequestData : NSObject

+ (void)savedToPlistWithData:(NSDictionary *)dictData;
+ (NSString *)countForNewFriendRequest;
+ (NSMutableArray *)getAllNewFriendRequestData;
+ (BOOL)deleteNewFriendRequest:(NSString *)userID;
@end
