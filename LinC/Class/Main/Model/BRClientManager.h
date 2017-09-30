//
//  BRClientManager.h
//  LinC
//
//  Created by Yingwei Fan on 9/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

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
 注册方法
 */
- (void)registerWithEmail: (NSString *)email username:(NSString *)username password:(NSString *)password code:(NSString *)code success:(void (^)(NSString *username, NSString *password))successBlock failure:(void (^)(EMError *error))failureBlock;

/**
 登出方法
 */
- (void)logoutIfSuccess:(void (^)(NSString *message))successBlock failure:(void (^)(EMError *error))failureBlock;

/**
 查询用户详情
 */
- (void)getUserInfoWithUsernames:(NSArray *)usernameList success:(void (^)(NSMutableArray *aList))successBlock failure:(void (^)(EMError *aError))failureBlock;

@end
