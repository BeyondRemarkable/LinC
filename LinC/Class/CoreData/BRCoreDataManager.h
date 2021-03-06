//
//  BRCoreDataManager.h
//  LinC
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BRClientManager.h"
#import "BRUserInfo+CoreDataClass.h"

@class BRConversationModel;
@interface BRCoreDataManager : NSObject

+ (BRCoreDataManager *)sharedInstance;
- (NSManagedObjectContext *)managedObjectContext;
- (__kindof NSManagedObject *)createNewDBObjectEntityname:(NSString *)entityName;
/** 保存登录用户数据 */
- (void)insertUserInfoToCoreData:(BRContactListModel *)userModel;
/** 获取登录用户模型 */
- (BRUserInfo *)fetchUserInfoBy:(NSString *)userName;
/** 更新登录用户模型 */
- (void)updateUserInfoWithKeys:(NSArray *)keyArray andValue: (NSArray *)valueArray;
/** 保存好友数据到Core data */
- (void)saveFriendsInfoToCoreData:(NSMutableArray*)dataArray;
/** 获取好友模型数据 */
- (BRFriendsInfo *)fetchFriendInfoBy:(NSString *)friendID;
/** 更新好友数据 */
- (void)updateFriendsInfoCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel;
/** 删除好友模型数据 */
- (void)deleteFriendByID:(NSArray *)userNameArray;
/** 插入会话模型数据 */
- (void)insertConversationToCoreData:(EMMessage *)message;
/** 删除会话模型数据 */
- (void)deleteConversationByID:(NSArray *)conversationID;
/** 获取会话模型数据 */
- (NSMutableArray *)fetchConversations;

/** 保存到core data */
- (BOOL)saveData;
@end
