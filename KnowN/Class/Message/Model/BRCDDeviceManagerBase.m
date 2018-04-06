//
//  BRCDDeviceManagerBase.m
//  KnowN
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManagerBase.h"
#import <UIKit/UIKit.h>
#import "BRCDDeviceManager+ProximitySensor.h"

static BRCDDeviceManager *emCDDeviceManager;

@implementation BRCDDeviceManager

+(BRCDDeviceManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emCDDeviceManager = [[BRCDDeviceManager alloc] init];
    });
    
    return emCDDeviceManager;
}

-(instancetype)init{
    if (self = [super init]) {
        [self _setupProximitySensor];
        [self registerNotifications];
    }
    return self;
}

- (void)registerNotifications
{
    [self unregisterNotifications];
    if (_isSupportProximitySensor) {
        static NSString *notif = @"UIDeviceProximityStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChanged:)
                                                     name:notif
                                                   object:nil];
    }
}

- (void)unregisterNotifications {
    if (_isSupportProximitySensor) {
        static NSString *notif = @"UIDeviceProximityStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:notif
                                                      object:nil];
    }
}

- (void)_setupProximitySensor
{
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:YES];
    _isSupportProximitySensor = device.proximityMonitoringEnabled;
    if (_isSupportProximitySensor) {
        [device setProximityMonitoringEnabled:NO];
    } else {
        
    }
}

@end
