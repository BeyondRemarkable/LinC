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


/**
 检查登录用户环信ID是否已经存在，不存在保存登录用户信息到数据库中
 
 @param dataDict dataDict 登录用户环信模型
 */
- (void)insertUserInfoToCoreData:(NSDictionary *)dataDict {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        if (![self fetchUserInfoBy:username]) {
            // 登录用户不存在， 保存新用户
            BRUserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"BRUserInfo" inManagedObjectContext:context];
            userInfo.username = dataDict[@"username"];
            userInfo.nickname = dataDict[@"nickname"];
            userInfo.gender = dataDict[@"gender"];
            userInfo.location = dataDict[@"location"];
            //            userInfo.avatar = dataDict[@"nickname"];
            userInfo.updated = dataDict[@"updated_at"];
            [self saveData];
        }
    }
}


/**
 检查需要插入的数据如果不存在，插入数据，并保存
 如果数据存在，检查是否需要更新
 
 @param dataArray dataArray 登录用户的好友模型数据
 */
- (void)saveFriendsInfoToCoreData:(NSMutableArray*)dataArray
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    BRUserInfo *userInfo = [self fetchUserInfoBy:username];
    
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
    //            friendsInfo.avatar = (NSData *)contactModel.avatar;
    friendsInfo.whatsUp = contactModel.whatsUp;
    friendsInfo.updated = contactModel.updated;
    [userInfo addFriendsInfoObject:friendsInfo];
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
//    NSSortDescriptor *sortUserNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
//    NSArray *sortDescriptors = @[sortUserNameDescriptor];
//
//    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    if (entity) {
        NSArray *fetchedObjects = [context executeFetchRequest: fetchRequest error:&error];
        NSLog(@"%lu", (unsigned long)fetchedObjects.count);
        
        BRUserInfo *userInfo = (BRUserInfo *)[fetchedObjects lastObject];
        for (BRFriendsInfo *fr in userInfo.friendsInfo) {
            NSLog(@"%@", fr.username);
        }
        
        
        if (fetchedObjects.count != 0) {
            return [fetchedObjects lastObject];
        } else {
            return nil;
        }
    }
    return nil;
}

/**
     更新登录用户的好友信息数据库
 
 @param userName userName 环信ID
 @param contactModel 环信模型数据
 */
- (void)updateFriendsInfoCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"username == %@", userName];
    
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
        //        resultModel.avatar = (NSData *)contactModel.avatarImage;
        resultModel.whatsUp = contactModel.whatsUp;
        resultModel.updated = contactModel.updated;

    }
    [self saveData];
}

- (void)insertUserConversationToCoreData:(EMMessage *)message {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    BRUserInfo *userInfo = [self fetchUserInfoBy:username];
    
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
            conversation.chatType = message.chatType;
            conversation.latestMessageTitle = [NSString stringWithFormat:@"%@", message.body];
            conversation.latestMessageTime = message.timestamp;
            conversation.from = message.from;
            conversation.to = message.to;
            conversation.direction = message.direction;
            conversation.isRead = message.isRead;
            conversation.status = message.status;
            
            [userInfo addConversationObject:conversation];
            [self saveData];
        } else {
            //已经保存会话模型，更新数据
            for (BRConversation *conversation in userInfo.conversation) {
                if ([conversation.conversationId isEqualToString:message.conversationId]) {
                    conversation.conversationId = message.conversationId;
                    conversation.chatType = message.chatType;
                    conversation.latestMessageTitle = [NSString stringWithFormat:@"%@", message.body];
                    conversation.latestMessageTime = message.timestamp;
                    conversation.from = message.from;
                    conversation.to = message.to;
                    conversation.direction = message.direction;
                    conversation.isRead = message.isRead;
                    conversation.status = message.status;
                    [self saveData];
                }
            }
        }
    
}

// 创建聊天时， 保存聊天对话框的title
- (void)updateConversationTitle:(NSString *)title byUsername:(NSString *)userID {
//    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
//    NSArray *result = [self fetchDataBy:username fromEntity:@"BRUserInfo"];
//    BRUserInfo *userInfo = (BRUserInfo *)[result lastObject];
//    for (BRConversation *conversation in userInfo.conversation) {
//        for (BRFriendsInfo *friendInfo in conversation.userInfo.friendsInfo) {
//            if ([friendInfo.username isEqualToString:userID]) {
//                conversation.title = title;
//            }
//        }
//    }
//    [self saveData];
}

/**
     删除会话模型

 @param conversationIDArray 需要删除的会话ID数组
 */
- (void)deleteConversationByID:(NSArray *)conversationIDArray {

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    BRUserInfo *userInfo = [self fetchUserInfoBy:username];
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
     删除好友

 @param userNameArray userName 需要删掉的好友ID数组
 */
- (void)deleteFriendByID:(NSArray *)userNameArray {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    BRUserInfo *userInfo = [self fetchUserInfoBy:username];
    NSMutableSet *friendInfoSet = [NSMutableSet set];
    for (BRFriendsInfo *friendInfo in userInfo.friendsInfo) {
        
        if ([userNameArray containsObject:friendInfo.username]) {
            [friendInfoSet addObject:friendInfo];
            [self deleteConversationByID:userNameArray];
        }
    }
    [userInfo removeFriendsInfo:friendInfoSet];
    [self saveData];
}


- (NSMutableArray *)fetchConversations {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"BRUserInfo" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"username == %@", username];
    
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    BRUserInfo *userInfo = [result lastObject];
    NSMutableArray *conversationArray = [NSMutableArray array];
   
    for (BRConversation *conversation in userInfo.conversation) {
        if ([conversation.from isEqualToString:username] || [conversation.to isEqualToString:username]) {
            [conversationArray addObject:conversation];
        }
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
        res = [[gCoreDataStack managedObjectContext] save:nil];
    }
    return res;
}

@end
