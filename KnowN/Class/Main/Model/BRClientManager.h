//
//  BRClientManager.h
//  KnowN
//
//  Created by Yingwei Fan on 9/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>
#import "BRContactListModel.h"

@interface BRClientManager : NSObject

/**
 单例方法
 */
+ (instancetype)sharedManager;

/**
 登录方法
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *message))successBlock failure:(void (^)(EMError *error))failureBlock;

/**
 获取验证码方法
 */
- (void)getCodeWithEmail:(NSString *)email success:(void (^)(void))successBlock failure:(void (^)(EMError *error))failureBlock;

- (void)getcodeWithPhoneNumber:(NSString *)phoneNumber success:(void(^)(void))successBlock failure:(void(^)(EMError *error))failureBlock;

/**
 注册方法
 */
- (void)registerWithEmail:(NSString *)email phoneNumber:(NSString *)phoneNumber username:(NSString *)username password:(NSString *)password code:(NSString *)code success:(void (^)(NSString *username, NSString *password))successBlock failure:(void (^)(EMError *error))failureBlock;

/**
 登出方法
 */
- (void)logoutIfSuccess:(void (^)(NSString *message))successBlock failure:(void (^)(EMError *error))failureBlock;

/**
 查询用户详情
 */
- (void)getFriendInfoWithUsernames:(NSArray *)usernameList andSaveFlag:(BOOL)saveFlag success:(void (^)(NSMutableArray *modelArray))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 异步查询当前用户信息 */
- (void)getSelfInfoWithSuccess:(void (^)(BRContactListModel *model))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 更新当前用户信息 */
- (void)updateSelfInfoWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray success:(void (^)(NSString *message))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 更新当前用户的密码 */
- (void)updatePasswordWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword success:(void (^)(NSString *message))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 从服务器获取所有群信息 */
- (void)getGroupInfoWithSuccess:(void (^)(NSMutableArray *groupInfoArray))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 根据传入的群ID获取群详情 */
- (void)updateGroupInformationWithIDs:(NSSet *)idSet;

/** 从服务器获取视频列表 */
- (void)getVideoListWithNumberOfPages:(NSUInteger)numberOfPages numberOfVideosPerPage:(NSUInteger)numberPerPage after:(NSDate *)date success:(void (^)(NSArray *videoModelArray))successBlock failure:(void (^)(EMError *error))failureBlock;

/** 获取视频的播放地址 */
- (void)getVideoURLWithID:(NSString *)videoID success:(void (^)(NSString *urlString))successBlock failure:(void (^)(EMError *error))failureBlock;

@end
