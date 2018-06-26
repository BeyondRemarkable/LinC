//
//  BRConferenceViewController.h
//  Copyright © 2018 zhe wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EMAudioStatus) {
    EMAudioStatusNone = 0,
    EMAudioStatusConnected,
    EMAudioStatusTalking,
};

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

- (instancetype)initWithCreateConference:(NSMutableArray *)friendInfoArray andGroupID:(NSString *)groupID;
- (instancetype)initWithJoinConferenceId:(NSString *)aConfId
                                 creater:(NSString *)aCreater andGroupID: (NSString *)groupID;

- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom;

@end
