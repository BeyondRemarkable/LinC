//
//  BRFileWithNewFriendsRequestData.h
//  LinC
//
//  Created by zhe wu on 9/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRFileWithNewRequestData : NSObject

+ (void)savedToFileName:(NSString *)fileName withData:(NSDictionary *)dictData;
+ (NSString *)countForNewRequestFromFile:(NSString *)filePath;
+ (NSMutableArray *)getAllNewRequestDataFromFile:(NSString *)fileName;
+ (BOOL)deleteRequestFromFile:(NSString *)filePath byID:(NSString *)deleteID;
@end
