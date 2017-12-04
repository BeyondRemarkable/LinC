//
//  BRCoreDataManager.m
//  LinC
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCoreDataManager.h"
#import "BRCoreDataStack.h"
#import "BRContactListModel.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRConversation+CoreDataClass.h"
#import "BRConversationModel.h"

static BRCoreDataStack *gCoreDataStack = nil;

@implementation BRCoreDataManager

+ (BRCoreDataManager *)sharedInstance
{
    static BRCoreDataManager *sharedMGRInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMGRInstance = [[BRCoreDataManager alloc] init];
    });
    return  sharedMGRInstance;
}


- (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *moc = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *dbURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"BRCoreData.sqlite"];
        NSLog(@"%@", dbURL);
        gCoreDataStack = [[BRCoreDataStack alloc] initWithURL:dbURL modelName:@"BRCoreData"];
        moc = [gCoreDataStack managedObjectContext];
    });
    return moc;
}

- (__kindof NSManagedObject *)createNewDBObjectEntityname:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext: [gCoreDataStack managedObjectContext]];
}

- (BRUserInfo *)userInfoDic {
    static BRUserInfo *userInfoDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        userInfoDic = [self fetchUserInfoBy: username];
    });
    return userInfoDic;
}


/**
     保存登录用户信息
 
 @param userModel  登录用户信息模型
 */
- (void)insertUserInfoToCoreData:(BRContactListModel *)userModel {
    NSManagedObjectContext *context = [self managedObjectContext];

    if ([userModel isKindOfClass:[BRContactListModel class]]) {
        if (!self.userInfoDic) {
            // 登录用户不存在， 保存新用户
            BRUserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"BRUserInfo" inManagedObjectContext:context];
            userInfo.username = userModel.username;
            userInfo.nickname = userModel.nickname;
            userInfo.gender = userModel.gender;
            userInfo.location = userModel.location;
            userInfo.avatar = UIImagePNGRepresentation(userModel.avatarImage);
            userInfo.whatsUp = userModel.whatsUp;
            userInfo.updated = userModel.updated;
            if (![self saveData]) {
                NSAssert(YES, @"数据库保存失败！！！");
            }
        } else {
            if (![userModel.updated isEqualToString:self.userInfoDic.updated]) {
                BRUserInfo *userInfo = self.userInfoDic;
                userInfo.username = userModel.username;
                userInfo.nickname = userModel.nickname;
                userInfo.gender = userModel.gender;
                userInfo.location = userModel.location;
                userInfo.avatar = UIImagePNGRepresentation(userModel.avatarImage);
                userInfo.whatsUp = userModel.whatsUp;
                userInfo.updated = userModel.updated;
                self.userInfoDic = userInfo;
                if (![self saveData]) {
                    NSAssert(YES, @"数据库保存失败！！！");
                }
            }
        }
    }
}

/**
 更新登录用户信息

 @param keyArray keyArray 需要更新信息的key
 @param valueArray valueArray 需要更新的value
 */
- (void)updateUserInfoWithKeys:(NSArray *)keyArray andValue: (NSArray *)valueArray {

    BRUserInfo *userInfo = self.userInfoDic;
    NSString *key = [keyArray lastObject];

    if ([key isEqualToString:@"avatar"]) {
        userInfo.avatar = [NSData dataWithData: [valueArray lastObject]];
    } else {
        NSString *value = [valueArray firstObject];
        if ([key isEqualToString: @"username"]) {
            userInfo.username = value;
        } else if ([key isEqualToString: @"nickname"]) {
            userInfo.nickname = value;
        } else if ([key isEqualToString: @"gender"]) {
            userInfo.gender = value;
        } else if ([key isEqualToString: @"location"]) {
            userInfo.location = value;
        } else if ([key isEqualToString: @"signature"]) {
            userInfo.whatsUp = value;
        }
    }
    if ([key isEqualToString: @"updated"]) {
        userInfo.updated = [valueArray firstObject];
    }
    [self saveData];
}

/**
 获取登录用户模型
 
 @param userName userName 用户环信ID
 @return return BRUserInfo 返回登录用户模型
 */
- (BRUserInfo *)fetchUserInfoBy:(NSString *)userName {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"BRUserInfo" inManagedObjectContext:context];
    NSPredicate *fetchPredicate= [NSPredicate predicateWithFormat:@"username = %@", userName];
    
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    if (entity) {
        NSArray *fetchedObjects = [context executeFetchRequest: fetchRequest error:&error];
        
        if (fetchedObjects.count != 0) {
            return [fetchedObjects lastObject];
        }
    }
    return nil;
}

/**
 检查好友列表 如何数据不存在，插入数据，并保存
 如果数据存在，检查是否需要更新
 
 @param dataArray dataArray 登录用户的好友模型数据
 */
- (void)saveFriendsInfoToCoreData:(NSMutableArray*)dataArray
{

    BRUserInfo *userInfo = self.userInfoDic;
    NSMutableArray *friendsArray = [NSMutableArray array];
    // 判断好友是否已经已经保存在数据库
    for (BRContactListModel *contactModel in dataArray) {
        [friendsArray addObject:contactModel.username];
        BOOL isContains = NO;
        BRFriendsInfo *friendsInfo = nil;
        for (BRFriendsInfo *friendsInfoModel in userInfo.friendsInfo) {
            if ([contactModel.username isEqualToString:friendsInfoModel.username]) {
                isContains = YES;
                friendsInfo = friendsInfoModel;
            }
        }
        if (!isContains) {
            // 好友信息不存在， 保存到数据库
            [self insertFriendsInfoToCoreData:contactModel toUserInfo:userInfo];
        } else {
            // 判断是用户信息否需要更新（根据updated属性）
            if (contactModel.updated && friendsInfo.updated && ![contactModel.updated isEqualToString:friendsInfo.updated]) {
                [self updateFriendsInfoCoreDataBy:userInfo.username withModel:contactModel];
            }
        }
    }

    // 判断是否有好友解除关系
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (BRFriendsInfo *friendInfo in userInfo.friendsInfo ) {
        if (![friendsArray containsObject:friendInfo.username]) {
            [deleteArray addObject:friendInfo.username];
        }
    }
    if (deleteArray.count != 0) {
        // 删除已经解除好友关系的好友数据
        [self deleteFriendByID:deleteArray];
    }
    
}

/**
 保存好友模型数据到数据库

 @param contactModel 好友模型数据
 @param userInfo 登录用户信息
 */
- (void)insertFriendsInfoToCoreData:(BRContactListModel *)contactModel toUserInfo:(BRUserInfo *)userInfo {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    BRFriendsInfo *friendsInfo = [NSEntityDescription insertNewObjectForEntityForName:@"BRFriendsInfo" inManagedObjectContext:context];
    friendsInfo.username = contactModel.username;
    friendsInfo.nickname = contactModel.nickname;
    friendsInfo.gender = contactModel.gender;
    friendsInfo.location = contactModel.location;
    friendsInfo.avatar = UIImagePNGRepresentation(contactModel.avatarImage);
    friendsInfo.whatsUp = contactModel.whatsUp;
    friendsInfo.updated = contactModel.updated;
    [userInfo addFriendsInfoObject:friendsInfo];
    [self saveData];
}

/**
 删除好友模型数据, 如果传入nil，则删除全部好友
 
 @param userNameArray userName 需要删掉的好友ID数组
 */
- (void)deleteFriendByID:(NSArray *)userNameArray {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    BRUserInfo *userInfo = [self fetchUserInfoBy:username];
    
    if (userNameArray.count == 0) {
        NSMutableSet *deleteSet = [NSMutableSet set];
        for (BRFriendsInfo *friendInfo in userInfo.friendsInfo) {
            [deleteSet addObject:friendInfo];
        }
        [userInfo removeFriendsInfo:deleteSet];
    } else {
        NSMutableSet *friendInfoSet = [NSMutableSet set];
        for (BRFriendsInfo *friendInfo in userInfo.friendsInfo) {
            
            if ([userNameArray containsObject:friendInfo.username]) {
                [friendInfoSet addObject:friendInfo];
                [self deleteConversationByID:userNameArray];
            }
        }
        [userInfo removeFriendsInfo:friendInfoSet];
    }
    [self saveData];
}

/**
     更新登录用户的好友信息
 
 @param userName userName 环信ID
 @param contactModel 环信模型数据
 */
- (void)updateFriendsInfoCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"username = %@", userName];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"BRUserInfo" inManagedObjectContext:context]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    for (BRUserInfo *resultModel in result) {
        resultModel.username = contactModel.username;
        resultModel.nickname = contactModel.nickname;
        resultModel.gender = contactModel.gender;
        resultModel.location = contactModel.location;
        resultModel.avatar = UIImagePNGRepresentation(contactModel.avatarImage);
        resultModel.whatsUp = contactModel.whatsUp;
        resultModel.updated = contactModel.updated;
    }
    [self saveData];
}


/**
 获取好友模型数据

 @param friendID 好友ID
 @return return value 好友模型数据
 */
- (BRFriendsInfo *)fetchFriendInfoBy:(NSString *)friendID {

    BRUserInfo *userInfo = self.userInfoDic;
    
    for (BRFriendsInfo *friendInfo in userInfo.friendsInfo) {
        if ([friendInfo.username isEqualToString:friendID]) {
            return friendInfo;
        }
    }
    return nil;
}


/**
     插入新会话列表

 @param message message 会话的消息数据
 */
- (void)insertConversationToCoreData:(EMMessage *)message {
    NSManagedObjectContext *context = [self managedObjectContext];

    BRUserInfo *userInfo = self.userInfoDic;
    
    BOOL isContains = NO;
    for (BRConversation *conversation in userInfo.conversation) {
        
        if (conversation.conversationId && [conversation.conversationId containsString: message.conversationId]) {
            isContains = YES;
        }
    }
        //数据库中没有会话模型数据， 直接保存
        if (!isContains) {
            BRConversation *conversation =  [NSEntityDescription insertNewObjectForEntityForName:@"BRConversation" inManagedObjectContext:context];
            conversation.conversationId = message.conversationId;
//            conversation.chatType = message.chatType;
//            conversation.latestMessageTitle = [NSString stringWithFormat:@"%@", message.body];
//            conversation.latestMessageTime = message.timestamp;
//            conversation.from = message.from;
//            conversation.to = message.to;
//            conversation.direction = message.direction;
//            conversation.status = message.status;
            
            [userInfo addConversationObject:conversation];
            [self saveData];
        } else {
            //已经保存会话模型，更新数据
            for (BRConversation *conversation in userInfo.conversation) {
                if ([conversation.conversationId isEqualToString:message.conversationId]) {
                    conversation.conversationId = message.conversationId;
//                    conversation.chatType = message.chatType;
//                    conversation.latestMessageTitle = [NSString stringWithFormat:@"%@", message.body];
//                    conversation.latestMessageTime = message.timestamp;
//                    conversation.from = message.from;
//                    conversation.to = message.to;
//                    conversation.direction = message.direction;
//                    conversation.status = message.status;
                    [self saveData];
                }
            }
        }
    
}

/**
     删除会话模型

 @param conversationIDArray 需要删除的会话ID数组
 */
- (void)deleteConversationByID:(NSArray *)conversationIDArray {
    
    BRUserInfo *userInfo = self.userInfoDic;
    NSMutableSet *conversationSet = [NSMutableSet set];
    for (BRConversation *conversation in userInfo.conversation) {
        
        if ([conversationIDArray containsObject:conversation.conversationId]) {
            [conversationSet addObject:conversation];
        }
        [userInfo removeFriendsInfo:conversationSet];
        [self saveData];
    }
  
}

/**
 获取所有会话模型数据

 @return return value 会话模型数组
 */
- (NSMutableArray *)fetchConversations {

    BRUserInfo *userInfo = self.userInfoDic;
    NSMutableArray *conversationArray = [NSMutableArray array];
    
    for (BRConversation *conversation in userInfo.conversation) {
        [conversationArray addObject:conversation];
    }
    return conversationArray;
    
}
/**
 存储数据
 
 @return return true 保存成功
 */
- (BOOL)saveData{
    BOOL res = YES;
    if ([[gCoreDataStack managedObjectContext] hasChanges]) {
        NSError *error = nil;
        res = [[gCoreDataStack managedObjectContext] save: &error];
        if (!res) {
            NSLog(@"error--数据库保存失败--%@", error.localizedDescription);
        }
    }
    return res;
}

@end
