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
#import "BRGroup+CoreDataClass.h"
#import "BRGroupModel.h"

static BRCoreDataStack *gCoreDataStack = nil;
BRUserInfo *userInfoDic = nil;

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

- (BRUserInfo *)getUserInfo {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    
    if (self.userInfoDic && self.userInfoDic.username == username) {
        return self.userInfoDic;
    } else {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
        self.userInfoDic = [self fetchUserInfoBy:username];
        return self.userInfoDic;
    }
}

/**
     保存登录用户信息
 
 @param userModel  登录用户信息模型
 */
- (void)insertUserInfoToCoreData:(BRContactListModel *)userModel {
    NSManagedObjectContext *context = [self managedObjectContext];

    if ([userModel isKindOfClass:[BRContactListModel class]]) {
        if (![self fetchUserInfoBy:userModel.username]) {
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
            self.userInfoDic = userInfo;
        } else {
            BRUserInfo *userInfo = [self getUserInfo];
            if (![userModel.updated isEqualToString:userInfo.updated]) {
                BRUserInfo *userInfo = [self getUserInfo];
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

    BRUserInfo *userInfo = [self getUserInfo];
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
 
 @param dataArray dataArray 登录用户的好友模型数据(BRContactListModel)
 */
- (void)saveFriendsInfoToCoreData:(NSMutableArray*)dataArray
{

    BRUserInfo *userInfo = [self getUserInfo];
    NSMutableArray *friendsUsernameArray = [NSMutableArray array];
    // 判断好友是否已经已经保存在数据库
    for (BRContactListModel *contactModel in dataArray) {
        [friendsUsernameArray addObject:contactModel.username];
        BRFriendsInfo *friendsInfo = nil;
        for (BRFriendsInfo *friendsInfoModel in userInfo.friendsInfo) {
            if ([contactModel.username isEqualToString:friendsInfoModel.username]) {
                friendsInfo = friendsInfoModel;
                break;
            }
        }
        if (!friendsInfo) {
            // 好友信息不存在， 保存到数据库
            [self insertFriendsInfoToCoreData:contactModel toUserInfo:userInfo];
        } else {
            // 判断是用户信息否需要更新（根据updated属性）
            if (contactModel.updated && friendsInfo.updated && ![contactModel.updated isEqualToString:friendsInfo.updated]) {
                [self updateFriendsInfoCoreDataBy:friendsInfo.username withModel:contactModel];
            }
        }
    }

    // 判断是否有好友解除关系
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (BRFriendsInfo *friendInfo in userInfo.friendsInfo ) {
        if (![friendsUsernameArray containsObject:friendInfo.username]) {
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
        if (friendInfoSet.count) {
            [userInfo removeFriendsInfo:friendInfoSet];
        }
    }
    [self saveData];
}

/**
     更新登录用户的好友信息
 
 @param userName userName 环信ID
 @param contactModel 环信模型数据
 */
- (void)updateFriendsInfoCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel {
    NSManagedObjectContext *context = [gCoreDataStack managedObjectContext];
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

    BRUserInfo *userInfo = [self getUserInfo];
    
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

    BRUserInfo *userInfo = [self getUserInfo];
    
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
    
    BRUserInfo *userInfo = [self getUserInfo];
    NSMutableSet *conversationSet = [NSMutableSet set];
    for (BRConversation *conversation in userInfo.conversation) {
        
        if ([conversationIDArray containsObject:conversation.conversationId]) {
            [conversationSet addObject:conversation];
        }
        if (!conversationSet) {
            [userInfo removeFriendsInfo:conversationSet];
            [self saveData];
        }
    }
}

/**
 获取所有会话模型数据

 @return 会话模型数组
 */
- (NSMutableArray *)fetchConversations {

    BRUserInfo *userInfo = [self getUserInfo];
    NSMutableArray *conversationArray = [NSMutableArray array];
    
    for (BRConversation *conversation in userInfo.conversation) {
        [conversationArray addObject:conversation];
    }
    return conversationArray;
    
}

/**
 保存群模型数据

 @param groupModelArray 群模型数组
 */
- (void)saveGroupToCoreData:(NSArray *)groupModelArray {
    for (BRGroupModel *groupModel in groupModelArray) {
        BRGroup *group = [[self fetchGroupsWithGroupID:groupModel.groupID] lastObject];
        if (!group) {
            [self insertGroupToCoreData:groupModel];
        } else {
            [self updateGroupInfo:groupModel];
        }
    }
}

/**
 保存群模型数据到数据库

 @param groupModel 环信群模型数据
 */
- (void)insertGroupToCoreData:(BRGroupModel *)groupModel{
    BRUserInfo *userInfo = [self getUserInfo];
    NSManagedObjectContext *context = [self managedObjectContext];
    BRGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"BRGroup" inManagedObjectContext:context];
    group.groupOwner = groupModel.groupOwner;
    group.groupName = groupModel.groupName;
    group.groupID = groupModel.groupID;
    group.groupDescription = groupModel.groupDescription;
    group.groupStyle = groupModel.groupStyle;
    if (!groupModel.groupIcon) {
        group.groupIcon = UIImagePNGRepresentation(groupModel.groupIcon);
    }
    [userInfo addGroupObject:group];
    [self saveData];
}

/**
 更新群模型数据到数据库
 
 @param groupModel 群模型数据
 */
- (void)updateGroupInfo:(BRGroupModel *)groupModel {
    BRGroup *oldGroup = [[self fetchGroupsWithGroupID:groupModel.groupID] lastObject];
    oldGroup.groupName = groupModel.groupName;
    oldGroup.groupOwner = groupModel.groupOwner;
    oldGroup.groupDescription = groupModel.groupDescription;
    oldGroup.groupStyle = groupModel.groupStyle;
    if (groupModel.groupIcon) {
        oldGroup.groupIcon = UIImagePNGRepresentation(groupModel.groupIcon);
    }
    [self saveData];
}

/**
 根据groupID获取群模型数据, groupID为nil时，获取所有群模型数据
 
 @return return 群模型数组
 */
- (NSArray *)fetchGroupsWithGroupID:(NSString *)groupID {
    BRUserInfo *userInfo = [self getUserInfo];
    NSArray *groupsArray = nil;
    
    if (groupID) {
        NSPredicate *fetchGroupFilter = [NSPredicate predicateWithFormat:@"groupID = %@", groupID];
        NSSet *groups = [userInfo.group filteredSetUsingPredicate:fetchGroupFilter];
        groupsArray = [groups allObjects];
    } else {
        groupsArray = [userInfo.group allObjects];
    }
    return groupsArray;
}

/**
 删除指定群模型数据
 
 @param groupID 群ID
 */
- (void)deleteGroupByGoupID:(NSString *)groupID {
    BRUserInfo *userInfo = [self getUserInfo];
    NSPredicate *fetchGroupFilter = [NSPredicate predicateWithFormat:@"groupID = %@", groupID];
    NSSet *groups = [userInfo.group filteredSetUsingPredicate:fetchGroupFilter];
    BRGroup *deleteGroup = [[groups allObjects] lastObject];
    if (deleteGroup) {
        [userInfo removeGroupObject:deleteGroup];
        [self saveData];
    }
}

/**
 保存群成员模型数据
 
 @param groupMembers 群成员模型数据
 @param groupID 群ID
 */
- (void)saveGroupMembersToCoreData:(NSArray *)groupMembers toGroup:(NSString *)groupID {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    BRGroup *group = [[self fetchGroupsWithGroupID:groupID] lastObject];
    
    for (BRContactListModel *model in groupMembers) {
       
        BRFriendsInfo *groupMember = [[self fetchGroupMembersByGroupID:groupID andGroupMemberUserName:model.username] lastObject];
        if (!groupMember) {
            // 群成员不存在，保存到数据库
            BRFriendsInfo *friendsInfo = [NSEntityDescription insertNewObjectForEntityForName:@"BRFriendsInfo" inManagedObjectContext:context];
            friendsInfo.username = model.username;
            friendsInfo.nickname = model.nickname;
            friendsInfo.gender = model.gender;
            friendsInfo.email = model.email;
            friendsInfo.whatsUp = model.whatsUp;
            friendsInfo.updated = model.updated;
            friendsInfo.avatar = UIImagePNGRepresentation(model.avatarImage);
            friendsInfo.location = model.location;
            [group addFriendsInfoObject:friendsInfo];
            [self saveData];
        } else {
            // 更新群成员信息
            [self updateGroupMemberInfo:model fromGroupID:groupID];
        }
    }
    
}

/**
 获取指定群内成员模型数据，当groupMemberUserName为nil时，获取全部群成员模型数据
 
 @param groupID 群ID
 @param groupMemberUserName 需要获取的群成员ID
 */
- (NSArray *)fetchGroupMembersByGroupID:(NSString *)groupID andGroupMemberUserName:(NSString *)groupMemberUserName{
    BRGroup *group = [[self fetchGroupsWithGroupID:groupID] lastObject];
    if (!groupMemberUserName) {
        return [group.friendsInfo allObjects];
    } else {
        NSPredicate *fetchGroupMemberFilter = [NSPredicate predicateWithFormat:@"username = %@", groupMemberUserName];
        NSSet *groupMember = [group.friendsInfo filteredSetUsingPredicate:fetchGroupMemberFilter];
        return [groupMember allObjects];
    }
}

/**
 更新指定群内成员模型数据
 
 @param groupMember 群成员数据
 @param groupID 群ID
 */
- (void)updateGroupMemberInfo:(BRContactListModel *)groupMember fromGroupID:(NSString *)groupID {
    BRFriendsInfo *groupMemberInfo = [[self fetchGroupMembersByGroupID:groupID andGroupMemberUserName:groupMember.username] lastObject];
    if (![groupMemberInfo.updated isEqualToString:groupMember.updated]) {
        groupMemberInfo.nickname = groupMember.nickname;
        groupMemberInfo.gender = groupMember.gender;
        groupMemberInfo.location = groupMember.location;
        groupMemberInfo.email = groupMember.email;
        groupMemberInfo.whatsUp = groupMember.whatsUp;
        groupMemberInfo.updated = groupMember.updated;
        groupMemberInfo.avatar = UIImagePNGRepresentation(groupMember.avatarImage);
        [self saveData];
    }
}

/**
 删除指定群内成员模型数据
 
 @param groupID 群ID
 @param groupMemberID 群成员ID
 */
- (void)deleteGroupMemberFromGoup:(NSString *)groupID andGroupMemberID:(NSString *)groupMemberID {
    BRGroup *group = [[self fetchGroupsWithGroupID:groupID] lastObject];
    BRFriendsInfo *groupMemberInfo = [[self fetchGroupMembersByGroupID:groupID andGroupMemberUserName:groupMemberID] lastObject];
    if (!groupMemberInfo) {
        [group removeFriendsInfoObject:groupMemberInfo];
        [self saveData];
    }
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
