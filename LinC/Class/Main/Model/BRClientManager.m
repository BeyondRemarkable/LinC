//
//  BRClientManager.m
//  LinC
//
//  Created by Yingwei Fan on 9/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRClientManager.h"
#import "BRHTTPSessionManager.h"
#import <SAMKeychain.h>

@implementation BRClientManager

+ (instancetype)sharedManager {
    static BRClientManager *_clientManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _clientManager = [[[self class] alloc] init];
    });
    
    return _clientManager;
}

//// 正式登录
//- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
//    // 用我们服务器做登录
//    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
//    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/login"];
//    NSDictionary *parameters;
//    if ([username containsString:@"@"] && [username containsString:@"."]) {
//        parameters = @{@"email":username, @"password":password};
//    }
//    else {
//        parameters = @{@"username":username, @"password":password};
//    }
//    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        // 登录服务器成功
//        if ([dict[@"status"] isEqualToString:@"success"]) {
//            NSString *encryptedPassword = password;
//            // 登录环信
//            [[EMClient sharedClient].options setIsAutoLogin:YES];
//            [[EMClient sharedClient] loginWithUsername:username password:encryptedPassword completion:^(NSString *aUsername, EMError *aError) {
//                // 登录环信成功
//                if (aError == nil) {
//                    // 设置自动登录
//                    [[EMClient sharedClient].options setIsAutoLogin:YES];
//                    // 存储用户名密码
//                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                    [userDefaults setObject:username forKey:kLoginUserNameKey];
//                    [userDefaults synchronize];
//                    
//                    [SAMKeychain setPassword:password forService:kLoginPasswordKey account:username];
//                    [SAMKeychain setPassword:dict[@"data"][@"token"] forService:kLoginTokenKey account:username];
//                    successBlock(username);
//                }
//                // 登录环信失败
//                else {
//                    failureBlock(aError);
//                }
//            }];
//            
//        }
//        // 登录服务器失败
//        else {
//            EMError *error = [EMError errorWithDescription:@"Unknown server error" code:EMErrorServerUnknownError];
//            failureBlock(error);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        NSLog(@"%@", error.localizedDescription);
//    }];
//}

// 测试登录
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    // 用我们服务器做登录
//    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
//    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/login"];
//    NSDictionary *parameters;
//    if ([username containsString:@"@"] && [username containsString:@"."]) {
//        parameters = @{@"email":username, @"password":password};
//    }
//    else {
//        parameters = @{@"username":username, @"password":password};
//    }
//    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        // 登录服务器成功
//        if ([dict[@"status"] isEqualToString:@"success"]) {
//            // 登录环信
//            [[EMClient sharedClient].options setIsAutoLogin:YES];
    
    NSString *encryptedPassword = password;
            [[EMClient sharedClient] loginWithUsername:username password:encryptedPassword completion:^(NSString *aUsername, EMError *aError) {
                // 登录环信成功
                if (aError == nil) {
                    // 设置自动登录
                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                    // 存储用户名密码
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:username forKey:kLoginUserNameKey];
                    [userDefaults synchronize];
                    
                    [SAMKeychain setPassword:password forService:kLoginPasswordKey account:username];
//                    
//                    [SAMKeychain setPassword:password forService:kLoginTokenKey account:username];
                    successBlock(username);
                }
                // 登录环信失败
                else {
                    failureBlock(aError);
                }
            }];
//
//        }
//        // 登录服务器失败
//        else {
//            EMError *error = [EMError errorWithDescription:@"Unknown server error" code:EMErrorServerUnknownError];
//            failureBlock(error);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        NSLog(@"%@", error.localizedDescription);
//    }];
    
}


- (void)registerWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password code:(NSString *)code success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/confirm"];
    NSDictionary *parameters = @{
                                 @"username":username,
                                 @"password":password,
                                 @"email":email,
                                 @"code":code
                                 };
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            successBlock(username);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorUserAlreadyExist];
            failureBlock(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

@end
