//
//  ConferenceViewController.h
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EMAudioStatusNone = 0,
    EMAudioStatusConnected,
    EMAudioStatusTalking,
} EMAudioStatus;

@protocol BRConfUserViewDelegate <NSObject>

@optional
- (void)tapUserViewWithStreamId:(NSString *)aStreamId;

@end

@interface BRConfUserView : UIView

@property (weak, nonatomic) id<BRConfUserViewDelegate> delegate;
@property (strong, nonatomic) NSString *viewId;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mixLabel;

@property (nonatomic) BOOL isMuted;
@property (nonatomic) EMAudioStatus status;

@end

@interface BRConferenceViewController : UIViewController

- (instancetype)initWithCreateConference:(NSMutableArray *)friendInfoArray;
- (instancetype)initWithConferenceId:(NSString *)aConfId
                             creater:(NSString *)aCreater;

- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom;

@end
