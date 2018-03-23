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
#import "BRLoginViewController.h"
#import "BRGroupModel.h"
#import "BRGroupIconGenerator.h"
#import "BRLectureVideoModel.h"

@interface BRClientManager ()

@property (nonatomic, strong) NSMutableDictionary *groupUpdateTimeDict;

@end

@implementation BRClientManager

+ (instancetype)sharedManager {
    static BRClientManager *_clientManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _clientManager = [[[self class] alloc] init];
    });
    
    return _clientManager;
}

- (NSMutableDictionary *)groupUpdateTimeDict {
    if (_groupUpdateTimeDict == nil) {
        _groupUpdateTimeDict = [NSMutableDictionary dictionary];
    }
    return _groupUpdateTimeDict;
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
        parameters = @{@"username":[username lowercaseString], @"password":password};
    }
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        // 登录服务器成功
        if ([dict[@"status"] isEqualToString:@"success"]) {
            NSString *usernameHX = dict[@"data"][@"user"][@"username"];
            NSString *encryptedPassword = dict[@"data"][@"user"][@"password"];

            // 登录环信
            [[EMClient sharedClient] loginWithUsername:usernameHX password:encryptedPassword completion:^(NSString *aUsername, EMError *aError) {
                // 登录环信成功
                if (aError == nil) {
                    // 设置自动登录
                    [[EMClient sharedClient].options setIsAutoLogin:YES];
                    // 存储用户名密码
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:usernameHX forKey:kLoginUserNameKey];
                    [SAMKeychain setPassword:password forService:kLoginPasswordKey account:usernameHX];
                    [SAMKeychain setPassword:dict[@"data"][@"token"] forService:kLoginTokenKey account:usernameHX];
                     [userDefaults synchronize];
                    //保存登录用户信息到core data
                    __block BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:dict[@"data"][@"user"][@"username"]];
                    model.nickname = dict[@"data"][@"user"][@"nickname"];
                    model.avatarURLPath = [kBaseURL stringByAppendingPathComponent:dict[@"data"][@"user"][@"avatar"]];
                    model.gender = dict[@"data"][@"user"][@"gender"];
                    model.location = dict[@"data"][@"user"][@"location"];
                    model.whatsUp = dict[@"data"][@"user"][@"signature"];
                    model.updated = dict[@"data"][@"user"][@"updated_at"];
                    BOOL isImage = ([model.avatarURLPath.lowercaseString hasSuffix:@".jpg"] || [model.avatarURLPath.lowercaseString hasSuffix:@".png"]);
                    if (!isImage) {
                        model.avatarImage = nil;
                        [[BRCoreDataManager sharedInstance] insertUserInfoToCoreData: model];
                        successBlock(dict[@"data"][@"user"]);
                    } else {
                        //子线程下载图片
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.avatarURLPath]]];
                            //主线程刷新
                            dispatch_async(dispatch_get_main_queue(), ^{
                                model.avatarImage = image;
                                
                                [[BRCoreDataManager sharedInstance] insertUserInfoToCoreData: model];
                                successBlock(dict[@"data"][@"user"]);
                            });
                        });
                    }
                }
                // 登录环信失败
                else {
                    EMError *error = [EMError errorWithDescription:@"Login fail." code:EMErrorGeneral];
                    failureBlock(error);
                }
            }];
        }
        // 登录服务器失败
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorServerUnknownError];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *anError = [EMError errorWithDescription:error.localizedDescription code:EMErrorGeneral];
        NSLog(@"error.localizedDescription--%@", error.localizedDescription);
        failureBlock(anError);
    }];
}

- (void)getCodeWithEmail:(NSString *)email success:(void (^)(void))successBlock failure:(void (^)(EMError *))failureBlock {
    NSDictionary *parameters = @{@"email": email};
    [self getCodeWithParameters:parameters success:successBlock failure:failureBlock];
}

- (void)getcodeWithPhoneNumber:(NSString *)phoneNumber success:(void (^)(void))successBlock failure:(void (^)(EMError *))failureBlock {
    NSDictionary *parameters = @{@"phone": phoneNumber};
    [self getCodeWithParameters:parameters success:successBlock failure:failureBlock];
}

- (void)getCodeWithParameters:(NSDictionary *)parameters success:(void (^)(void))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url =  [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/verify/"];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            successBlock();
        }
        else if ([dict[@"status"] isEqualToString:@"error"]) {
            EMError *aError = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(aError);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedFailureReason code:EMErrorGeneral];
        failureBlock(aError);
    }];
}

- (void)registerWithEmail:(NSString *)email phoneNumber:(NSString *)phoneNumber username:(NSString *)username password:(NSString *)password code:(NSString *)code success:(void (^)(NSString *, NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/auth/register/confirm"];
    NSDictionary *parameters;
    if (email) {
        parameters = @{
                       @"username":[username lowercaseString],
                       @"password":password,
                       @"email":email,
                       @"code":code
                       };
    }
    else {
        parameters = @{
                       @"username":[username lowercaseString],
                       @"password":password,
                       @"phone":phoneNumber,
                       @"code":code
                       };
    }
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
        EMError *anError = [EMError errorWithDescription:error.localizedDescription code:EMErrorGeneral];
        failureBlock(anError);
    }];
}

- (void)logoutIfSuccess:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/logout"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    if (token) {
         [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    }
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            [BRCoreDataManager sharedInstance].userInfoDic = nil;
            successBlock(dict[@"message"]);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *anError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(anError);
    }];
}


/**
 从服务器获取好友信息
 @param usernameList 用户ID的数组
 @param successBlock successBlock userModelArray
 @param failureBlock failureBlock error
 */
- (void)getUserInfoWithUsernames:(NSArray *)usernameList andSaveFlag:(BOOL) saveFlag success:(void (^)(NSMutableArray *))successBlock failure:(void (^)(EMError *))failureBlock {
    // 如果传入数组为空
    if (usernameList.count == 0) {
        successBlock(nil);
        return;
    }
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/users/find"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];

    if (!token) {
        EMError *error = [EMError errorWithDescription:@"tokenInvalid(401)" code:EMErrorInvalidToken];
        failureBlock(error);
        return;
    }
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:usernameList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{@"key":@"username",@"value":jsonStr};
    
    NSMutableArray *userModelArray = [NSMutableArray array];
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        if ([dict[@"status"] isEqualToString:@"success"]) {
            dispatch_group_t group = dispatch_group_create();
            int friendConut = (int)[dict[@"data"][@"users"] count];
            for (int i = 0; i < friendConut; i++) {
                //给模型赋值
                __block BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:dict[@"data"][@"users"][i][@"username"]];
                model.username = dict[@"data"][@"users"][i][@"username"];
                model.nickname = dict[@"data"][@"users"][i][@"nickname"];
                model.updated = dict[@"data"][@"users"][i][@"updated_at"];
                model.location = dict[@"data"][@"users"][i][@"location"];
                model.gender = dict[@"data"][@"users"][i][@"gender"];
                model.whatsUp = dict[@"data"][@"users"][i][@"signature"];
                model.avatarURLPath = [kBaseURL stringByAppendingPathComponent:dict[@"data"][@"users"][i][@"avatar"]];

                BOOL isImage = ([model.avatarURLPath.lowercaseString hasSuffix:@".jpg"] || [model.avatarURLPath.lowercaseString hasSuffix:@".png"]);
                if (!isImage) {
                    model.avatarImage = nil;
                } else {
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        model.avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.avatarURLPath]]];
                    });
                }
                
                [userModelArray addObject:model];
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if (saveFlag) {
                    [[BRCoreDataManager sharedInstance] saveFriendsInfoToCoreData:userModelArray];
                }
                successBlock(userModelArray);
            });
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

/**
 从服务器获取登录用户信息

 @param successBlock successBlock 用户模型数据
 @param failureBlock failureBlock error信息
 */
- (void)getSelfInfoWithSuccess:(void (^)(BRContactListModel *))successBlock failure:(void (^)(EMError *))failureBlock {
  
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/profile/show"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    
    if (!token) {
        EMError *error = [EMError errorWithDescription:@"tokenInvalid(401)" code:EMErrorInvalidToken];
        failureBlock(error);
        return;
    }
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        __block BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:dict[@"data"][@"user"][@"username"]];
        model.nickname = dict[@"data"][@"user"][@"nickname"];
        model.avatarURLPath = [kBaseURL stringByAppendingPathComponent:dict[@"data"][@"user"][@"avatar"]];
        model.gender = dict[@"data"][@"user"][@"gender"];
        model.location = dict[@"data"][@"user"][@"location"];
        model.whatsUp = dict[@"data"][@"user"][@"signature"];
        model.updated = dict[@"data"][@"user"][@"updated_at"];
        BOOL isImage = ([model.avatarURLPath.lowercaseString hasSuffix:@".jpg"] || [model.avatarURLPath.lowercaseString hasSuffix:@".png"]);
        if (!isImage) {
            model.avatarImage = nil;
            [[BRCoreDataManager sharedInstance] insertUserInfoToCoreData: model];
            successBlock(model);
        } else {
            //子线程下载图片
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.avatarURLPath]]];
                //主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.avatarImage = image;
                    [[BRCoreDataManager sharedInstance] insertUserInfoToCoreData: model];
                    successBlock(model);
                });
                
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:(EMErrorCode)error.code];
        failureBlock(aError);
    }];
}

- (void)updateSelfInfoWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    if (keyArray.count == 0) {
        return;
    }
    
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/account/profile/save"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    if (!token) {
        EMError *error = [EMError errorWithDescription:@"tokenInvalid(401)" code:EMErrorInvalidToken];
        failureBlock(error);
        return;
    }
    if (![keyArray containsObject:@"avatar"]) {
        BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjects:valueArray forKeys:keyArray];
        [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
        [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            successBlock(dict[@"message"]);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
            failureBlock(aError);
        }];
    } else {
        NSData *imageData = [valueArray firstObject];
        BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
        [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
        NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        } error:nil];
        NSURLSessionDataTask *uploadTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error == nil) {
                NSDictionary *dict = (NSDictionary *)responseObject;
                if ([dict[@"status"] isEqualToString:@"success"]) {
                    successBlock(dict[@"message"]);
                }
                else {
                    EMError *aError = [EMError errorWithDescription:dict[@"message"] code:EMErrorServerUnknownError];
                    failureBlock(aError);
                }
            }
            else {
                EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
                failureBlock(aError);
            }
        }];
       
        [uploadTask resume];
    }
    // 更新登录用户信息到 core data
    [[BRCoreDataManager sharedInstance] updateUserInfoWithKeys:(NSArray *)keyArray andValue: (NSArray *)valueArray];
}

- (void)updatePasswordWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/password/update"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    if (!token) {
        EMError *error = [EMError errorWithDescription:@"tokenInvalid(401)" code:EMErrorInvalidToken];
        failureBlock(error);
        return;
    }
    NSDictionary *parameters = @{
                                 @"token":token,
                                 @"password":newPassword,
                                 @"old_password":currentPassword
                                 };
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            successBlock(dict[@"message"]);
        }
        else {
            EMError *aError = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(aError);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerUnknownError];
        failureBlock(aError);
    }];
}

/**
    从服务器获取群模型数据，并生成群头像，保存到数据中
 
 @param successBlock  群模型数组
 @param failureBlock  error信息
 */
- (void)getGroupInfoWithSuccess:(void (^)(NSMutableArray *groupInfoArray))successBlock failure:(void (^)(EMError *))failureBlock {
    __block NSMutableArray *groupListArray = [NSMutableArray array];
    __block NSMutableArray *groupListInfoArray = [NSMutableArray array];
    dispatch_group_t dispathGroup = dispatch_group_create();
    dispatch_group_enter(dispathGroup);
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:-1 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            groupListArray = [aList mutableCopy];
            dispatch_group_leave(dispathGroup);
        } else {
            dispatch_group_leave(dispathGroup);
            failureBlock(aError);
        }
    }];
    dispatch_group_notify(dispathGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t dispathGroupInfo = dispatch_group_create();
        for (EMGroup *group in groupListArray) {
            dispatch_group_enter(dispathGroupInfo);
            [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:group.groupId cursor:nil pageSize:-1 completion:^(EMCursorResult *aResult, EMError *aError) {
                if (!aError) {
                    __block BRGroupModel *groupModel = [[BRGroupModel alloc] init];
                    groupModel.groupOwner = group.owner;
                    groupModel.groupID = group.groupId;
                    groupModel.groupDescription = group.description;
                    groupModel.groupName = group.subject;
                    groupModel.groupStyle = group.setting.style;
                    NSMutableArray *groupMembers = [NSMutableArray arrayWithObject:group.owner];
                    [groupMembers addObjectsFromArray:aResult.list];
                    groupModel.groupMembers = groupMembers;
                    [groupListInfoArray addObject:groupModel];
                    dispatch_group_leave(dispathGroupInfo);
                } else {
                    dispatch_group_leave(dispathGroupInfo);
                    failureBlock(aError);
                }
            }];
        }
        dispatch_group_notify(dispathGroupInfo, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            dispatch_group_t dispathGroupMemberInfo = dispatch_group_create();
            for (BRGroupModel *groupModel in groupListInfoArray) {
                // 取出前9个群成员生成群头像
                NSMutableArray *groupMembersArray = [groupModel.groupMembers mutableCopy];
                if (groupModel.groupMembers.count > 9) {
                    groupMembersArray = [[groupMembersArray subarrayWithRange:NSMakeRange(0, 9)] copy];
                }
                dispatch_group_async(dispathGroupMemberInfo, dispatch_get_global_queue(0, 0), ^{
                   dispatch_group_enter(dispathGroupMemberInfo);
                    [self getUserInfoWithUsernames:groupMembersArray andSaveFlag:NO success:^(NSMutableArray *groupMembers) {
                        
                        NSMutableArray *membersIconArray = [NSMutableArray array];
                        for (NSInteger i = 0; i < groupMembers.count; i++) {
                            BRContactListModel *groupMember = groupMembers[i];
                            if (groupMember.avatarImage) {
                                [membersIconArray addObject:groupMember.avatarImage];
                            } else {
                                [membersIconArray addObject:[UIImage imageNamed:@"nickname"]];
                            }
                        }
                        if (membersIconArray.count > 0) {
                            groupModel.groupIcon = [BRGroupIconGenerator groupIconGenerator:membersIconArray];
                        } else {
                            groupModel.groupIcon = [UIImage imageNamed:@"group_default"];
                        }
                        dispatch_group_leave(dispathGroupMemberInfo);
                       
                    } failure:^(EMError *error) {
                        dispatch_group_leave(dispathGroupMemberInfo);
                        failureBlock(error);
                    }];
                });
            }
            dispatch_group_notify(dispathGroupMemberInfo, dispatch_get_main_queue(), ^{
                [[BRCoreDataManager sharedInstance] saveGroupToCoreData:groupListInfoArray];
                successBlock(groupListInfoArray);
            });
        });
    });
}

/**
 根据群ID更新群信息
 */
- (void)updateGroupInformationWithIDs:(NSSet *)idSet {
    NSBlockOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRDataUpdateNotification object:nil];
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSEnumerator *enumerator = [idSet objectEnumerator];
    NSString *valueID;
    while (valueID = [enumerator nextObject]) {
        // 计算时间差判断是否需要更新
        NSDate *lastUpdateTime = nil;
        NSDate *currentTime = [NSDate dateWithTimeIntervalSinceNow:0];
        if ((lastUpdateTime = self.groupUpdateTimeDict[valueID])) {
            NSTimeInterval interval = [currentTime timeIntervalSinceDate:lastUpdateTime];
            // 时间间隔五分钟
            if ((int)interval/60%60 < 5) {
                continue;
            }
        }
        self.groupUpdateTimeDict[valueID] = currentTime;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:valueID error:nil];
            if (group && group.subject && group.subject.length != 0) {
                BRGroupModel *groupModel = [[BRGroupModel alloc] init];
                groupModel.groupID = group.groupId;
                groupModel.groupDescription = group.description;
                groupModel.groupName = group.subject;
                groupModel.groupOwner = group.owner;
                groupModel.groupMembers = [NSMutableArray arrayWithArray:group.memberList];
                groupModel.groupStyle = group.setting.style;
                
                [[BRCoreDataManager sharedInstance] saveGroupToCoreData:@[groupModel]];
            }
        }];
        [updateOperation addDependency:operation];
        [queue addOperation:operation];
    }
    [[NSOperationQueue mainQueue] addOperation:updateOperation];
}

- (void)getVideoListWithNumberOfPages:(NSUInteger)numberOfPages numberOfVideosPerPage:(NSUInteger)numberPerPage after:(NSDate *)date success:(void (^)(NSArray *))successBlock failure:(void (^)(EMError *))failureBlock {
    NSString *pageString = numberOfPages?[NSString stringWithFormat:@"%lu", (unsigned long)numberOfPages]:nil;
    NSString *perPageString = numberPerPage?[NSString stringWithFormat:@"%lu", numberPerPage]:nil;
    NSMutableString *timeStamp;
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        timeStamp = [NSMutableString stringWithString:[formatter stringFromDate:date]];
        [timeStamp appendString:@"Z"];
        [timeStamp replaceCharactersInRange:NSMakeRange(10, 1) withString:@"T"];
    }
    
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/videos/"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"page"] = pageString;
    parameters[@"perPage"] = perPageString;
    parameters[@"timestamp"] = timeStamp;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    NSString *token = [SAMKeychain passwordForService:kLoginTokenKey account:username];
    [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token]  forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            NSArray *videoInfoArray = dict[@"data"];
            NSMutableArray *videoModelArray = [NSMutableArray array];
            for (NSDictionary *infoDict in videoInfoArray) {
                BRLectureVideoModel *model = [[BRLectureVideoModel alloc] init];
                model.identifier = infoDict[@"_id"];
                model.title = infoDict[@"title"];
                model.instructor = infoDict[@"instructor_name"];
                model.thumbnailURL = [kBaseURL stringByAppendingPathComponent:infoDict[@"cover"]];
                model.detail = infoDict[@"description"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                NSMutableString *dateString = [NSMutableString stringWithString:infoDict[@"created_at"]];
                [dateString deleteCharactersInRange:NSMakeRange(dateString.length - 1, 1)];
                [dateString replaceCharactersInRange:NSMakeRange(10, 1) withString:@" "];
                model.createTime = [formatter dateFromString:dateString];
                dateString = [NSMutableString stringWithString:infoDict[@"updated_at"]];
                [dateString deleteCharactersInRange:NSMakeRange(dateString.length - 1, 1)];
                [dateString replaceCharactersInRange:NSMakeRange(10, 1) withString:@" "];
                model.updateTime = [formatter dateFromString:dateString];
                
                [videoModelArray addObject:model];
            }
            successBlock(videoModelArray);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorServerTimeout];
        failureBlock(aError);
    }];
}

- (void)getVideoURLWithID:(NSString *)videoID success:(void (^)(NSString *))successBlock failure:(void (^)(EMError *))failureBlock {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:[NSString stringWithFormat:@"/api/v1/videos/%@/watch", videoID]];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"status"] isEqualToString:@"success"]) {
            successBlock(dict[@"data"][@"url"]);
        }
        else {
            EMError *error = [EMError errorWithDescription:dict[@"message"] code:EMErrorGeneral];
            failureBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EMError *aError = [EMError errorWithDescription:error.localizedDescription code:EMErrorGeneral];
        failureBlock(aError);
    }];
}

@end
