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
/** 获取登录用户模型 */
- (BRUserInfo *)fetchUserInfoBy:(NSString *)userName;
/** 保存好友数据到Core data */
- (void)saveFriendsInfoToCoreData:(NSMutableArray*)dataArray;
/** 插入新好友数据 */
- (void)insertUserInfoToCoreData:(NSDictionary *)dataDict;
/** 更新好友数据 */
- (void)updateFriendsInfoCoreDataBy:(NSString *)userName withModel:(BRContactListModel *)contactModel;
/** 删除好友模型数据 */
- (void)deleteFriendByID:(NSArray *)userNameArray;
/** 插入会话模型数据 */
- (void)insertUserConversationToCoreData:(EMMessage *)message;
/** 删除会话模型数据 */
- (void)deleteConversationByID:(NSArray *)conversationID;
/** 获取会话模型数据 */
- (NSMutableArray *)fetchConversations;


- (void)updateConversationTitle:(NSString *)title byUsername:(NSString *)username;

- (BOOL)saveData;
@end
