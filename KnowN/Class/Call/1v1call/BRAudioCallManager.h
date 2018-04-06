//
//  BRAudioCallManager.h
//  KnowN
//
//  Created by zhe wu on 3/14/18.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Hyphenate/Hyphenate.h>
#import "EMCallOptions+NSCoding.h"

@class MainViewController;
@interface BRAudioCallManager : NSObject

@property (nonatomic) BOOL isCalling;


+ (instancetype)sharedManager;
- (void)saveCallOptions;
- (void)makeCallWithUsername:(NSString *)aUsername
                        type:(EMCallType)aType
           isCustomVideoData:(BOOL)aIsCustomVideo;
- (void)answerCall:(NSString *)aCallId;
- (void)hangupCallWithReason:(EMCallEndReason)aReason;

@end
