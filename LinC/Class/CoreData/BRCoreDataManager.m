//
//  BRCoreDataManager.m
//  LinC
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCoreDataManager.h"
#import "BRCoreDataStack.h"
#import "BRUserInfo+CoreDataClass.h"
#import "BRContactListModel.h"
#import "BRFriendsInfo+CoreDataClass.h"

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
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        NSArray *result = [self fetchDataBy: [dataDict objectForKey:@"username"] fromEntity:@"BRUserInfo"];
        
        if (result.count == 0) {
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
- (void)insertFriendsInfoToCoreData:(NSMutableArray*)dataArray
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserNameKey];
    NSArray *result = [self fetchDataBy:username fromEntity:@"BRUserInfo"];
    
    // 从数据库中，获取好友模型数据
    BRUserInfo *userInfo = (BRUserInfo *)[result lastObject];
    
    // 判断好友是否已经已经保存在数据库
    for (BRContactListModel *contactModel in dataArray) {
        BOOL isContains = NO;
        BRFriendsInfo *friendsInfo = nil;
        for (BRFriendsInfo *friendsInfoModel in userInfo.friendsInfo) {
            NSLog(@"%@", friendsInfoModel.username);
            if (contactModel.username == friendsInfoModel.username) {
                isContains = YES;
                friendsInfo = friendsInfoModel;
                NSLog(@"%@", friendsInfo.updated);
            }
        }
        
        if (!isContains) {
            // 好友信息不存在， 保存到数据库
            friendsInfo = [NSEntityDescription insertNewObjectForEntityForName:@"BRFriendsInfo" inManagedObjectContext:context];
            friendsInfo.username = contactModel.username;
            friendsInfo.nickname = contactModel.nickname;
            friendsInfo.gender = contactModel.gender;
            friendsInfo.location = contactModel.location;
            //            friendsInfo.avatar = (NSData *)contactModel.avatar;
            friendsInfo.whatsUp = contactModel.whatsUp;
            friendsInfo.updated = contactModel.updated;
            [userInfo addFriendsInfoObject:friendsInfo];
            [self saveData];
        } else {
            // 判断是用户信息否需要更新（根据updated属性）
            if (contactModel.updated && friendsInfo.updated && ![contactModel.updated isEqualToString:friendsInfo.updated]) {
                
                [self updataCoreDataBy:userInfo.username withModel:contactModel];
            }
        }
    }
}

/**
 获取数据
 
 @param userName userName 用户环信ID
 @return return resultArray 返回用户环信模型数组
 */
- (NSArray *)fetchDataBy:(NSString *)userName fromEntity:(NSString *)entityName{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSPredicate *fetchPredicate= [NSPredicate predicateWithFormat:@"username == %@", userName];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest: fetchRequest error:&error];
    
    return fetchedObjects;
}

/**
 更新数据库
 
 @param userName userName 环信ID
 @param contactModel 环信模型数据
 */
- (void)updataCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel {
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
        resultModel.username = contactModel.username;
        resultModel.gender = contactModel.gender;
        resultModel.location = contactModel.location;
        //        resultModel.avatar = (NSData *)contactModel.avatarImage;
        resultModel.whatsUp = contactModel.whatsUp;
        resultModel.updated = contactModel.updated;
    }
    [self saveData];
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
