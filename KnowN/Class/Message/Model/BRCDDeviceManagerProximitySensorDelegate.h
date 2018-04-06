//
//  BRCDDeviceManagerProximitySensorDelegate.h
//  KnowN
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#ifndef BRCDDeviceManagerProximitySensorDelegate_h
#define BRCDDeviceManagerProximitySensorDelegate_h

#import <Foundation/Foundation.h>

@protocol BRCDDeviceManagerProximitySensorDelegate <NSObject>

/*!
 @method
 @brief Posted when the state of the proximity sensor changes.
 @param isCloseToUser indicates whether the proximity sensor is close to the user (YES) or not (NO).
 */
- (void)proximitySensorChanged:(BOOL)isCloseToUser;

@end

#endif /* BRCDDeviceManagerProximitySensorDelegate_h */
