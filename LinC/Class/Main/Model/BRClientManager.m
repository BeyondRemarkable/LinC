//
//  BRClientManager.m
//  LinC
//
//  Created by Yingwei Fan on 9/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRClientManager.h"
#import "BRHTTPSessionManager.h"
#import "BRContactListModel.h"
#import <SAMKeychain.h>
#import <CoreData/CoreData.h>
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"

@implementation BRClientManager

+ (instancetype)sharedManager {
    static BRClientManager *_clientManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _clientManager = [[[self class] alloc] init];
    });
    
    return _clientManager;
}

// 正式登录
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    // 用我们服务器做登录
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/login"];
    NSDictionary *parameters;
    if ([username containsString:@"@"] && [username containsString:@"."]) {
        parameters = @{@"email":username, @"password":password};
    }
    else {
        parameters = @{@"username":username, @"password":password};
    }
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        // 登录服务器成功
        if ([dict[@"status"] isEqualToString:@"success"]) {
            NSString *usernameHX = dict[@"data"][@"user"][@"username"];
            NSString *encryptedPassword = dict[@"data"][@"user"][@"password"];
            
            //保存用户信息到数据库
            BRCoreDataManager *manager = [BRCoreDataManager sharedInstance];
            [manager insertUserInfoToCoreData:dict[@"data"][@"user"]];
            // 登录环信
            [[EMClient sharedClient] loginWithUsername:usernameHX password:encryptedPassword completion:^(NSString *aUsername, EMError *aError) {
                // 登录环信成功
                if (aError == nil) {
                    // 设置自动登录
                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                    // 存储用户名密码
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:username forKey:kLoginUserNameKey];
                    [userDefaults synchronize];
                    
                    [SAMKeychain setPassword:password forService:kLoginPasswordKey account:username];
                    [SAMKeychain setPassword:dict[@"data"][@"token"] forService:kLoginTokenKey account:username];
                    successBlock(dict[@"message"]);
                }
                // 登录环信失败
                else {
                    failureBlock(aError);
                }
            }];
            
        }
        // 登录服务器失败
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorServerUnknownError];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error.localizedDescription);
    }];
}


- (void)registerWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password code:(NSString *)code success:(void (^)(NSString *, NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
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
            successBlock(username, password);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorUserAlreadyExist];
            failureBlock(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)logoutIfSuccess:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/logout"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            successBlock(dict[@"message"]);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *emError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(emError);
    }];
}


/**
     从服务器获取用户信息

 @param usernameList 用户ID的数组
 @param successBlock successBlock userModelArray
 @param failureBlock failureBlock error
 */
- (void)getUserInfoWithUsernames:(NSArray *)usernameList success:(void (^)(NSMutableArray *))successBlock failure:(void (^)(EMError *))failureBlock {
    // 如果传入数组为空
    if (usernameList.count == 0) {
        return;
    }
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/users/find"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:usernameList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{@"key":@"username",@"value":jsonStr};

    NSMutableArray *userModelArray = [NSMutableArray array];
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        if ([dict[@"status"] isEqualToString:@"success"]) {
            for (int i = 0; i < usernameList.count; i++) {
                //给模型赋值
                BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:dict[@"data"][@"users"][i][@"username"]];
                model.username = dict[@"data"][@"users"][i][@"username"];
                model.nickname = dict[@"data"][@"users"][i][@"nickname"];
                model.updated = dict[@"data"][@"users"][i][@"updated_at"];
                model.gender = dict[@"data"][@"users"][i][@"gender"];
                model.location = dict[@"data"][@"users"][i][@"location"];
                model.whatsUp = dict[@"data"][@"users"][i][@"signature"];
                model.avatarImage = dict[@"data"][@"users"][i][@"avatar"];
                if (model.nickname.length == 0) {
                    model.nickname = model.username;
                }
                [userModelArray addObject:model];
            }
            
            BRCoreDataManager *manager = [BRCoreDataManager sharedInstance];
            [manager insertFriendsInfoToCoreData:userModelArray];

            successBlock(userModelArray);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(aError);
    }];
}

- (void)getSelfInfoWithSuccess:(void (^)(BRContactListModel *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/profile/show"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:dict[@"data"][@"user"][@"username"]];
        model.nickname = dict[@"data"][@"user"][@"nickname"];
        model.avatarURLPath = dict[@"data"][@"user"][@""];
        model.gender = dict[@"data"][@"user"][@"gender"];
        model.location = dict[@"data"][@"user"][@"location"];
        model.whatsUp = dict[@"data"][@"user"][@"signature"];
        successBlock(model);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(aError);
    }];
}

- (void)updateSelfInfoWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    if (keyArray.count == 0) {
        return;
    }
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/profile/save"];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjects:valueArray forKeys:keyArray];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        successBlock(dict[@"message"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(aError);
    }];
    
    
}

@end
