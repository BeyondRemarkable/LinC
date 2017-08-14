//
//  BRCDDeviceManager+Microphone.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManagerBase.h"

@interface BRCDDeviceManager (Microphone)

// Check the availability for microphone
- (BOOL)emCheckMicrophoneAvailability;

// Get the audio volumn (0~1)
- (double)emPeekRecorderVoiceMeter;

@end
