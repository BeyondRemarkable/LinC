//
//  BRCDDeviceManager+Microphone.m
//  KnowN
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManager+Microphone.h"
#import "BRAudioRecorderUtil.h"

@implementation BRCDDeviceManager (Microphone)

// Check the availability for microphone
- (BOOL)emCheckMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    
    return ret;
}

// Get the audio volumn (0~1)
- (double)emPeekRecorderVoiceMeter{
    double ret = 0.0;
    if ([BRAudioRecorderUtil recorder].isRecording) {
        [[BRAudioRecorderUtil recorder] updateMeters];
        //Average volumn  [recorder averagePowerForChannel:0];
        //Maximum volumn  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [[BRAudioRecorderUtil recorder] peakPowerForChannel:0]));
        ret = lowPassResults;
    }
    
    return ret;
}

@end
