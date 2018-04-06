//
//  BRGroupIconGenerator.h
//  KnowN
//
//  Created by zhe wu on 1/31/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRGroupIconGenerator : NSObject
@property (nonatomic, strong) NSMutableArray *imageArray;
+ (UIImage *)groupIconGenerator:(NSMutableArray *)imageArray;
@end
