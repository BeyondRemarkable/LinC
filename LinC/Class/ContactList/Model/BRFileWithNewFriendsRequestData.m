//
//  BRFileWithNewFriendsRequestData.m
//  LinC
//
//  Created by zhe wu on 9/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFileWithNewFriendsRequestData.h"

@implementation BRFileWithNewFriendsRequestData



/**
    获取到ios document 文件目录
 
 @return document path
 */
+ (NSString *)getPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"newfirendRequestData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create new file if not exist
    if (![fileManager fileExistsAtPath: path]) {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"newfirendRequestData.plist"]];
    }
    NSLog(@"path=%@", path);
    return path;
}


/**
    保存新的好友请求数据到plist文件

 @param dictData dictData
 */
+ (void)savedToPlistWithData:(NSDictionary *)dictData
{
    NSString *path = [self getPath];
    NSLog(@"path=%@", path);
    // Write data to file
    NSMutableArray *newfriendData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    if (newfriendData.count == 0) {
        newfriendData = [NSMutableArray array];
        [newfriendData addObject:dictData];
        [newfriendData writeToFile:path atomically:YES];
        
    } else {
        
        for (NSDictionary *dict in newfriendData) {
            if (![[dict allValues] containsObject:dictData[@"userID"]]) {
                [newfriendData addObject:dictData];
                [newfriendData writeToFile:path atomically:YES];
            }
        }
    }
    
}

/**
 读取文件，返回等待添加的好友数量
 
 @return NSString newfriendData.count
 */
+ (NSString *)countForNewFriendRequest {
    NSString *path = [self getPath];
    NSMutableArray *newfriendData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    
//    if (newfriendData.count) {
        return [NSString stringWithFormat:@"%lu", (unsigned long)newfriendData.count];
//    } else {
//        return @"1";
//    }
}


/**
    获取到所有好友请求的数据

 @return NSMutableArray newfriendData
 */
+ (NSMutableArray *)getAllNewFriendRequestData {
    NSString *path = [self getPath];
    NSMutableArray *newfriendData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    
    if (!newfriendData) {
        newfriendData = [NSMutableArray array];
    }
    return newfriendData;
}


/**
    当点击接受或者拒绝按钮时，从好友请求数据中删除当前请求

 @param userID userID
 @return ture 删除成功， false 删除失败
 */
+ (BOOL)deleteNewFriendRequest:(NSString *)userID {
    NSString *path = [self getPath];
    NSMutableArray *newfriendData = [[NSMutableArray alloc] initWithContentsOfFile: path];
    
    if (newfriendData) {
        for (int i = 0; i < newfriendData.count; i++) {
            NSDictionary *dict = [newfriendData objectAtIndex:i];
            if ([[dict allValues] containsObject:userID]) {
                [newfriendData removeObjectAtIndex:i];
                [newfriendData writeToFile:path atomically:YES];
                return true;
            }
        }
    }
    return false;
}

@end
