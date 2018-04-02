//
//  BRCDDeviceManagerBase.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRCDDeviceManagerDelegate.h"

@interface BRCDDeviceManager : NSObject
{
// recorder
NSDate              *_recorderStartDate;
NSDate              *_recorderEndDate;
NSString            *_currCategory;
BOOL                _currActive;

// proximitySensor
BOOL _isSupportProximitySensor;
BOOL _isCloseToUser;
}

@property (nonatomic, assign) id <BRCDDeviceManagerDelegate> delegate;

+(BRCDDeviceManager *)sharedInstance;
- (void)registerNotifications;
- (void)unregisterNotifications;
@end
