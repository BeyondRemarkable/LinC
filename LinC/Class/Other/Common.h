//
//  Common.h
//  LinC
//
//  Created by Yingwei Fan on 4/13/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#ifndef Common_h
#define Common_h
#import "NSString+Helper.h"
#define BRRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

#define BRColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT   ([[UIScreen mainScreen] bounds].size.height)
#define iPhoneX_BOTTOM_HEIGHT  ([UIScreen mainScreen].bounds.size.height==812?34:0)

#define newFirendRequestFile @"newfirendRequestData.plist"
#define newGroupRequestFile @"newGroupRequestData.plist"
#define GroupIDLength 14

#define BRDataUpdateNotification @"DataUpdateNotification"

extern NSString *const GroupNameChangeNotificationName;
// 定义系统偏好的键值
extern NSString *const kLoginUserNameKey;
extern NSString *const kLoginPasswordKey;
extern NSString *const kLoginTokenKey;
extern NSString *const kLoginStatusKey;
extern NSString *const kServiceName;
extern NSString *const kServiceToken;

extern NSString *const kBaseURL;

#endif /* Common_h */
