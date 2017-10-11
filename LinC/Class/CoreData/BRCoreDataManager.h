//
//  BRCoreDataManager.h
//  LinC
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BRCoreDataManager : NSObject

+ (BRCoreDataManager *)sharedInstance;
- (NSManagedObjectContext *)managedObjectContext;
- (__kindof NSManagedObject *)createNewDBObjectEntityname:(NSString *)entityName;
- (void)insertUserInfoToCoreData:(NSDictionary *)dataDict;
- (void)insertFriendsInfoToCoreData:(NSMutableArray*)dataArray;
- (NSArray *)fetchDataBy:(NSString *)userName fromEntity:(NSString *)entityName;
- (BOOL)saveData;
@end
