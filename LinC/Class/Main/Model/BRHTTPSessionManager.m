//
//  BRHTTPSessionManager.m
//  Table
//
//  Created by Yingwei Fan on 8/30/17.
//  Copyright © 2017 Yingwei Fan. All rights reserved.
//

#import "BRHTTPSessionManager.h"

@implementation BRHTTPSessionManager

+ (instancetype)manager {
    BRHTTPSessionManager *manager = [super manager];
    
    NSMutableSet *newSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [newSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = newSet;
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    return manager;
}

@end
