//
//  BRCallViewController.h
//  LinC
//
//  Created by zhe wu on 2/8/18.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BRAudioCallManager.h"

@interface BRCallViewController : UIViewController



@property (strong, nonatomic, readonly) EMCallSession *callSession;

@property (nonatomic) BOOL isDismissing;

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession;

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
                       isCustomData:(BOOL)aIsCustom;

- (void)stateToConnected;

- (void)stateToAnswered;

- (void)setNetwork:(EMCallNetworkStatus)aStatus;

- (void)setStreamType:(EMCallStreamingStatus)aType;

- (void)clearData;


@end
