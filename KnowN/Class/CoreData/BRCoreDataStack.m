//
//  BRCoreDataStack.m
//  KnowN
//
//  Created by zhe wu on 10/6/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCoreDataStack.h"

@interface BRCoreDataStack()
@property (nonatomic, strong) NSDictionary *persistentStoreOption;
@end

@implementation BRCoreDataStack


- (id)initWithURL:(NSURL *)url modelName:(NSString *)modelName
{
    self = [super init];
    if (self) {
        _databaseURL = [url retain];
        _modelName = [modelName copy];
        _persistentStoreOption = [@{ NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES) } copy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url modelName:(NSString *)modelName persistentStoreOption:(NSDictionary *)persistentStoreOption
{
    self = [super init];
    if (self) {
        _databaseURL = [url retain];
        _modelName = [modelName copy];
        _persistentStoreOption = [persistentStoreOption retain];
    }
    return self;
}

- (NSManagedObjectModel *)dataModel
{
    if (_mom == nil) {
        NSString *momdPath = [[NSBundle mainBundle] pathForResource:self.modelName ofType:@"momd"];
        NSURL *momdURL = [NSURL fileURLWithPath:momdPath];
        
        _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
    }
    
    return _mom;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_psc == nil) {
        NSAssert(self.databaseURL != nil, @"This class should have been init'd with a URL, or with enough info to construct a valid URL");
        NSError *error = nil;
        _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self dataModel]];
        _defPS = [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.databaseURL options:self.persistentStoreOption error:&error];
        if (!_defPS) {
            NSAssert(NO, @"Not able to add persistent store for DB url:%@. error:%@", self.databaseURL, error.debugDescription);
        }
    }
    
    return _psc;
}

- (NSPersistentStore *)defPersistentStore
{
    if (_defPS == nil) {
        NSError *error = nil;
        _defPS = [[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.databaseURL options:self.persistentStoreOption error:&error];
        if (!_defPS) {
            NSAssert(NO, @"Not able to add persistent store for DB url:%@. error:%@", self.databaseURL, error.debugDescription);
        }
    }
    
    return _defPS;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_moc) {
        NSAssert([NSThread isMainThread], @"What?! Not main thread?!");
        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_moc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
        // https://developer.apple.com/LIBRARY/IOS/documentation/Cocoa/Conceptual/CoreData/Articles/cdPerformance.html#//apple_ref/doc/uid/TP40003468-SW4fd093838a7482d8886c897a55938965e4ae5ace0
        [_moc setUndoManager:nil];
        [_moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    
    return _moc;
}

- (NSManagedObjectContext *)createNewPSCSharedManagedObjectContext
{
    NSManagedObjectContext *newMoc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
    [newMoc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    [newMoc setUndoManager:nil];
    return newMoc;
}

- (NSManagedObjectContext *)getPSCSharedManagedObjectContextIsCreated:(BOOL *)isCreated
{
    if ([NSThread isMainThread]) {
        if (isCreated != NULL)
            *isCreated = NO;
        return [self managedObjectContext];
    }
    else {
        if (isCreated != NULL)
            *isCreated = YES;
        return [self createNewPSCSharedManagedObjectContext];
    }
}

- (NSManagedObjectContext *)getChildManagedObjectContext
{
    NSManagedObjectContext *newMoc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
    [newMoc setParentContext:[self managedObjectContext]];
    [newMoc setUndoManager:nil];
    return newMoc;
}

+ (NSManagedObjectContext *)getChildManagedObjectContextFromMoc:(NSManagedObjectContext *)parentMoc
{
    NSManagedObjectContext *newMoc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
    [newMoc setParentContext:parentMoc];
    [newMoc setUndoManager:nil];
    return newMoc;
}

- (void)wipeAllData
{
    for (NSPersistentStore *store in[self.persistentStoreCoordinator persistentStores]) {
        NSError *error;
        NSURL *storeURL = store.URL;
        [self.persistentStoreCoordinator removePersistentStore:store error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
        
        // side effect: all NSFetchedResultsController's will now explode because Apple didn't code them very well
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDestroyAllNSFetchedResultsControllers object:self];
    }
}

@end
