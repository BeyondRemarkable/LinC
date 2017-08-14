//
//  BRCDDeviceManager+ProximitySensor.m
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManager+ProximitySensor.h"
#import <UIKit/UIKit.h>

@implementation BRCDDeviceManager (ProximitySensor)

@dynamic isSupportProximitySensor;
@dynamic isCloseToUser;


#pragma mark - proximity sensor
- (BOOL)isProximitySensorEnabled {
    BOOL ret = NO;
    ret = self.isSupportProximitySensor && [UIDevice currentDevice].proximityMonitoringEnabled;
    
    return ret;
}

- (BOOL)enableProximitySensor {
    BOOL ret = NO;
    if (_isSupportProximitySensor) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        ret = YES;
    }
    
    return ret;
}

- (BOOL)disableProximitySensor {
    BOOL ret = NO;
    if (_isSupportProximitySensor) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        _isCloseToUser = NO;
        ret = YES;
    }
    
    return ret;
}

- (void)sensorStateChanged:(NSNotification *)notification {
    BOOL ret = NO;
    if ([[UIDevice currentDevice] proximityState] == YES) {
        ret = YES;
    }
    _isCloseToUser = ret;
    if([self.delegate respondsToSelector:@selector(proximitySensorChanged:)]){
        [self.delegate proximitySensorChanged:_isCloseToUser];
    }
}

#pragma mark - getter
- (BOOL)isCloseToUser {
    return _isCloseToUser;
}

- (BOOL)isSupportProximitySensor {
    return _isSupportProximitySensor;
}

@end