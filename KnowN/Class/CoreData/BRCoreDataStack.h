//
//  BRCoreDataStack.h
//  KnowN
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kNotificationDestroyAllNSFetchedResultsControllers @"DestroyAllNSFetchedResultsControllers"

@interface BRCoreDataStack : NSObject
{
@private
    NSManagedObjectModel* _mom;
    NSManagedObjectContext* _moc;
    NSPersistentStoreCoordinator* _psc;
    NSPersistentStore *_defPS;
}

/*!
 The actual database URL that's in use.
 */
@property(nonatomic, retain, readonly) NSURL *databaseURL;

/*!
 Name of the model file in Xcode, without extension. E.g. for "Model.xcdatamodeld", result is "Model".
 */
@property(nonatomic, copy, readonly) NSString *modelName;

/**
 Initialize a core data stack with the model name and the url where the .sqlite file will be saved.
 @param url The sqlite URL, it should also include the "yourDB.sqlite" part.
 @param modelName The data model name without extention
 */
- (id)initWithURL:(NSURL *)url modelName:(NSString *)modelName;
- (id)initWithURL:(NSURL *)url modelName:(NSString *)modelName persistentStoreOption:(NSDictionary *)persistentStoreOption;

/**
 Get/read the data model, just note that this methods reads model file from framework bundle instead of
 project main bundle.
 */
- (NSManagedObjectModel *)dataModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSPersistentStore *)defPersistentStore;

/*!
 A shared moc that associates with main thread.
 @note **You should init CoreDataStack and call this method for the very first time from main thread.**
 */
- (NSManagedObjectContext *)managedObjectContext;

/**
 Create a new NSManagedObjectContext object but using the same model and store coordinator.
 You should use this method for getting MOC on threads other than main thread, you also MUST call this method
 on the thread(queue) that MOC will be bind to.
 */
- (NSManagedObjectContext *)createNewPSCSharedManagedObjectContext;

/**
 Get or create a NSManagedObjectContext object depending on which thread is calling this method, main thread
 will get the shared instance, a new PersistentStoreCoordinator shared MOC instance will be created for any
 other thread.
 @param isCreated If not NULL, this value will be set to YES if the result MOC was newly created, otherwise NO
 @return A autoreleased NSManagedObjectContext type instance
 */
- (NSManagedObjectContext *)getPSCSharedManagedObjectContextIsCreated:(BOOL *)isCreated;

- (NSManagedObjectContext *)getChildManagedObjectContext;
+ (NSManagedObjectContext *)getChildManagedObjectContextFromMoc:(NSManagedObjectContext *)parentMoc;

- (void)wipeAllData;

@end
