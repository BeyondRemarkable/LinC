//
//  BRCDDeviceManager+Remind.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCDDeviceManagerBase.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BRCDDeviceManager (Remind)

// The system sound for a new message
- (SystemSoundID)playNewMessageSound;

- (void)playVibration;

@end
