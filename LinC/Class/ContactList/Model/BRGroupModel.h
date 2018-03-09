//
//  BRGroupModel.h
//  LinC
//
//  Created by zhe wu on 2/2/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Hyphenate/EMGroupOptions.h>

@interface BRGroupModel : NSObject

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *groupDescription;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupOwner;
@property (nonatomic, strong) UIImage *groupIcon;
@property (nonatomic, strong) NSMutableArray *groupMembers;
@property (nonatomic, assign) EMGroupStyle groupStyle;
@end
