//
//  ContactListModel.h
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUserModel.h"


@interface BRContactListModel : NSObject <IUserModel>

/** 好友环信id(用户环信id) */
@property (nonatomic, retain) NSString *username;

/** @brief 好友环信id(用户环信id) */
@property (strong, nonatomic, readonly) NSString *buddy;
/** @brief 用户昵称 */
@property (strong, nonatomic) NSString *nickname;
/** @brief 用户头像url */
@property (strong, nonatomic) NSString *avatarURLPath;
/** @brief 用户头像 */
@property (strong, nonatomic) UIImage *avatarImage;



- (void)loadWithDictionary:(NSDictionary *)dict;


@end
