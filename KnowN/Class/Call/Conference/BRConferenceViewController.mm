//
//  BRConferenceViewController.m
//
//  Copyright © 2016 zhe wu. All rights reserved.
//

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "BRConferenceViewController.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRAudioCallManager.h"
#import "BRConfManager.h"
#import "BRConfUserSelectionViewController.h"
#import "BRSDKHelper.h"
#import "BRCoreDataManager.h"
#import <MBProgressHUD.h>
#import "BRMessageViewController.h"
//3.3.9 new 自定义视频数据
//#import "VideoCustomCamera.h"

#define kMaxCol 4

@implementation BRConfUserView

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapUserViewWithStreamId:)]) {
            [_delegate tapUserViewWithStreamId:self.viewId];
        }
    }
}

- (void)setIsMuted:(BOOL)isMuted
{
    _isMuted = isMuted;
    if (isMuted) {
        self.statusImgView.image = [UIImage imageNamed:@"conf_mute"];
    } else {
        self.statusImgView.image = nil;
    }
}

- (void)setStatus:(EMAudioStatus)status
{
    if (self.isMuted) {
        return;
    }
    
    if (_status != status) {
        _status = status;
        switch (_status) {
            case EMAudioStatusNone:
                self.statusImgView.image = [UIImage imageNamed:@"conf_ring"];
                break;
            case EMAudioStatusConnected:
                self.statusImgView.image = nil;
                break;
            case EMAudioStatusTalking:
                self.statusImgView.image = [UIImage imageNamed:@"conf_talking"];
                break;
                
            default:
                break;
        }
    }
}

@end

@interface BRConferenceViewController ()<EMConferenceManagerDelegate, BRConfUserViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    MBProgressHUD *hud;
}

@property (nonatomic, strong) CTCallCenter *callCenter;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *displayView;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *enableCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) UIButton *minButton;
@property (strong, nonatomic) NSString *currentMaxStreamId;

@property (nonatomic) float itemBorder;
@property (nonatomic) CGSize itemSize;

@property (nonatomic) BOOL isCreater;
@property (strong, nonatomic) NSString *createrName;
@property (strong, nonatomic) NSString *pubStreamId;
@property (strong, nonatomic) NSString *conferenceId;
@property (strong, nonatomic) __block EMCallConference *conference;

@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *streamViews;
@property (strong, nonatomic) NSMutableDictionary *streamsDic;
@property (strong, nonatomic) NSMutableOrderedSet *streamIds;
@property (strong, nonatomic) NSMutableArray *talkingStreamIds;
@property (strong, nonatomic) NSMutableArray *friendInfoArray;
@property (strong, nonatomic) NSString *groupID;
//3.3.9 new 自定义视频数据
@property (weak, nonatomic) IBOutlet UIView *videoFormatView;
@property (weak, nonatomic) IBOutlet UIButton *videoMoreButton;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int timeLength;
@property (strong, nonatomic) NSTimer *timeTimer;

//@property (nonatomic) VideoInputModeType videoModel;
//@property (strong, nonatomic) VideoCustomCamera *videoCamera;

@end

@implementation BRConferenceViewController

- (instancetype)initWithCreateConference:(NSMutableArray *)friendInfoArray andGroupID:(NSString *)groupID
{
    self = [super init];
    if (self) {
        _isCreater = YES;
        _createrName = [EMClient sharedClient].currentUsername;
        _friendInfoArray = friendInfoArray;
        _hangupButton.hidden = YES;
        _groupID = groupID;
    }
    
    return self;
}

- (instancetype)initWithJoinConferenceId:(NSString *)aConfId
                                 creater:(NSString *)aCreater andGroupID: (NSString *)groupID
{
    self = [super init];
    if (self) {
        _conferenceId = aConfId;
        _isCreater = NO;
        _createrName = aCreater;
        _groupID = groupID;
    }
    return self;
}

//3.3.9 new 自定义视频数据
- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom
{
    self = [self init];
    //    if (self) {
    //        _videoModel = VIDEO_INPUT_MODE_NONE;
    //        if (aIsCustom) {
    //            _videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
    //        }
    //    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [[BRAudioCallManager sharedManager] setIsCalling:YES];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    self.streamViews = [[NSMutableDictionary alloc] init];
    self.streamsDic = [[NSMutableDictionary alloc] init];
    self.streamIds = [[NSMutableOrderedSet alloc] init];
    self.talkingStreamIds = [[NSMutableArray alloc] init];
    
    self.itemBorder = 10;
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    float width = (boundSize.width - self.itemBorder * (kMaxCol + 1)) / kMaxCol;
    self.itemSize = CGSizeMake(width, width);
    
    [self _setupSubviews];
    if (self.isCreater) {
        [self _createOrJoinConference];
    }
    
    __weak typeof(self) weakSelf = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if(call.callState == CTCallStateConnected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hangupAction:nil];
            });
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [self closeVideoCamera];
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:self.conference];
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

#pragma mark - getter

- (UIButton *)minButton
{
    if (_minButton == nil) {
        _minButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
        [_minButton setImage:[UIImage imageNamed:@"Button_Minimize"] forState:UIControlStateNormal];
        [_minButton addTarget:self action:@selector(minAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _minButton;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self.speakerOutButton setImage:[UIImage imageNamed:@"Button_Speaker_active"] forState:UIControlStateSelected];
    [self.muteButton setImage:[UIImage imageNamed:@"Button_Mute_active"] forState:UIControlStateSelected];
    
    if (self.isCreater) {
        self.hangupButton.hidden = NO;
        self.answerButton.hidden = YES;
        self.rejectButton.hidden = YES;
        self.statusLabel.text = NSLocalizedString(@"Calling...", nil);
    } else {
        self.hangupButton.hidden = YES;
        self.answerButton.hidden = NO;
        self.rejectButton.hidden = NO;
        self.statusLabel.text = NSLocalizedString(@"Incomimg call", nil);
    }
    self.statusLabel.hidden = NO;
    self.timeLabel.hidden = YES;
    self.videoMoreButton.hidden = YES;
    
    //3.3.9 new 自定义视频数据
    self.enableCameraButton.hidden = YES;
//    [self.enableCameraButton setImage:[UIImage imageNamed:@"conf_camera_on"] forState:UIControlStateSelected];
    //    if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
    //        self.videoMoreButton.hidden = NO;
    //        self.enableCameraButton.hidden = YES;
    //        self.switchCameraButton.hidden = NO;
    //    }
    [self _startCallTimer];
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    [self _setupUserViewWithUserName:loginUser streamId:loginUser];
    if (!self.isCreater && self.createrName) {
        [self _setupUserViewWithUserName:self.createrName streamId:self.createrName];
    }
}

- (BRConfUserView *)_setupUserViewWithUserName:(NSString *)aUserName
                                      streamId:(NSString *)aStreamId
{
    [self.streamIds addObject:aStreamId];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BRConfUserView" owner:self options:nil];
    BRConfUserView *userView = [nib objectAtIndex:0];
    userView.viewId = aStreamId;
    userView.delegate = self;
    BRUserInfo *loginUser = [[BRCoreDataManager sharedInstance] getUserInfo];
    
    if ([loginUser.username isEqualToString:aUserName]) {
        userView.nameLabel.text = loginUser.nickname? loginUser.nickname : loginUser.username;
        if (loginUser.avatar) {
            userView.avatarView.image = [UIImage imageWithData:loginUser.avatar];
            [userView.avatarView setContentMode:UIViewContentModeScaleAspectFill];
            userView.avatarView.clipsToBounds = YES;
        } else {
            userView.avatarView.image = [UIImage imageNamed:@"user_default"];
        }
    } else {
        BOOL isContain = NO;
        for (BRFriendsInfo *friendInfo in self.friendInfoArray) {
            if ([friendInfo.username isEqualToString:aUserName]) {
                isContain = YES;
                userView.nameLabel.text = friendInfo.nickname? friendInfo.nickname : friendInfo.username;
                if (friendInfo.avatar) {
                    userView.avatarView.image = [UIImage imageWithData:friendInfo.avatar];
                    [userView.avatarView setContentMode:UIViewContentModeScaleAspectFill];
                    userView.avatarView.clipsToBounds = YES;
                } else {
                    userView.avatarView.image = [UIImage imageNamed:@"user_default"];
                }
            }
        }
        if (!isContain) {
            NSArray *groupsMembersArray = [[BRCoreDataManager sharedInstance] fetchGroupMembersByGroupID:self.groupID andGroupMemberUserNameArray:[NSArray arrayWithObject:aUserName]];
            
            BRFriendsInfo *createInfo = [groupsMembersArray lastObject];
            
            if (createInfo) {
                userView.nameLabel.text = createInfo.nickname? createInfo.nickname : createInfo.username;
                if (createInfo.avatar) {
                    userView.avatarView.image = [UIImage imageWithData:createInfo.avatar];
                    [userView.avatarView setContentMode:UIViewContentModeScaleAspectFill];
                    userView.avatarView.clipsToBounds = YES;
                } else {
                    userView.avatarView.image = [UIImage imageNamed:@"user_default"];
                }
            } else {
                userView.nameLabel.text = aUserName;
                
                userView.avatarView.image = [UIImage imageNamed:@"user_default"];
            }
        }
    }
    
    NSInteger index = [self.streamViews count];
    NSInteger col = index % kMaxCol;
    NSInteger row = index / kMaxCol;
    userView.frame = CGRectMake(col * (self.itemSize.width + self.itemBorder) + self.itemBorder, row * (self.itemSize.height + self.itemBorder) + self.itemBorder, self.itemSize.width, self.itemSize.height);
    
    [self.displayView addSubview:userView];
    [self.streamViews setObject:userView forKey:aStreamId];
    
    float height = CGRectGetMaxY(userView.frame) + self.itemBorder;
    if (height > self.displayView.contentSize.height) {
        self.displayView.scrollEnabled = YES;
        self.displayView.contentSize = CGSizeMake(self.displayView.contentSize.width, height);
    }
    
    return userView;
}

#pragma mark - private EMConferenceManager

- (void)_createOrJoinConference
{
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = loginUser;
    pubConfig.enableVideo = NO;
    
    __weak typeof(self) weakSelf = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            weakSelf.conference = nil;
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController popViewControllerAnimated:NO];
            hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
            hud.label.text = NSLocalizedString(@"Creating audio conference failed.", nil);
            [hud hideAnimated:YES afterDelay:1.5];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        } else {
            weakSelf.conference = aCall;
            
            BRConfUserView *userView = [weakSelf.streamViews objectForKey:loginUser];
            
            self.localView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
            self.localView.tag = 100;
            self.localView.backgroundColor = [UIColor blackColor];
            self.localView.scaleMode = EMCallViewScaleModeAspectFill;
            pubConfig.localView = self.localView;
            pubConfig.enableVideo = NO;
            
            //3.3.9 new 自定义视频数据
            //            if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
            //                pubConfig.enableCustomizeVideoData = YES;
            //                pubConfig.enableVideo = YES;
            //                [userView.videoView addSubview:self.localView];
            //            }
            
            [[EMClient sharedClient].conferenceManager publishConference:weakSelf.conference streamParam:pubConfig completion:^(NSString *pubStreamId, EMError *aError) {
                if (aError) {
                    hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
                    hud.label.text = NSLocalizedString(@"Loading audio conference failed.", nil);
                    [hud hideAnimated:YES afterDelay:1.5];
                   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
                } else {
                    weakSelf.pubStreamId = pubStreamId;
                    
                    BRConfUserView *resetView = [weakSelf.streamViews objectForKey:loginUser];
                    resetView.viewId = pubStreamId;
                    [weakSelf.streamViews removeObjectForKey:loginUser];
                    [weakSelf.streamViews setObject:resetView forKey:pubStreamId];
                    
                    //3.3.9 new 自定义视频数据
                    //                    if (weakSelf.videoModel != VIDEO_INPUT_MODE_NONE) {
                    //                        [weakSelf openVideoCamera];
                    //                    }
                    
                    [[EMClient sharedClient].conferenceManager startMonitorSpeaker:weakSelf.conference timeInterval:300 completion:^(EMError *aError) {
                        if (aError) {
                            hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
                            hud.label.text = NSLocalizedString(@"Audio conference error111.", nil);
                            [hud hideAnimated:YES afterDelay:1.5];
                            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
                            [self dismissVC];
                        }
                    }];
                }
            }];
        }
    };
    
    if (self.isCreater) {
        
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithPassword:@"" completion:^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
            if (!aError) {
                self.conference = aCall;
                
                for (BRFriendsInfo *friendInof in self.friendInfoArray) {
                    [self _inviteUser:friendInof.username];
                }
                block(aCall, @"", aError);
            } else {
                hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
                hud.label.text = aError.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
                [self dismissVC];
            }
        }];
    } else {
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:_conferenceId password:@"" completion:^(EMCallConference *aCall, EMError *aError) {
            if (!aError) {
                block(aCall, @"", aError);
            } else {
                hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
                hud.label.text = aError.errorDescription;
                [hud hideAnimated:YES afterDelay:1.5];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
                [self dismissVC];
            }
        }];
    }
}

- (void)_inviteUser:(NSString *)aUserName
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
    [ext setObject:[EMClient sharedClient].currentUsername forKey:@"creater"];
    [ext setObject:self.groupID forKey:@"groupID"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    EMError *error = nil;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager inviteUserToJoinConference:self.conference userName:aUserName password:nil ext:jsonString error:&error];
    if (error) {
        hud.label.text = NSLocalizedString(@"Invite failed.", nil);
        [hud hideAnimated:YES afterDelay:1.5];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];

    } else {
        NSString *externString = [[[[[[KBRAudioConferenceInviteExtKey stringByAppendingString:@":"] stringByAppendingString:weakSelf.conference.confId] stringByAppendingString:@":"] stringByAppendingString:self.groupID] stringByAppendingString:@":"] stringByAppendingString:[EMClient sharedClient].currentUsername];
        EMTextMessageBody *cmdChat = [[EMTextMessageBody alloc] initWithText:@"Invite audio conference"];
        
        EMMessage *message = [BRSDKHelper getTextMessage:cmdChat.text to:aUserName messageType:EMChatTypeChat messageExt:@{@"em_apns_ext":@{@"extern":externString}}];
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    }
}

- (void)_subStream:(EMCallStream *)aStream
{
    
    if ([self.streamIds containsObject:aStream.userName]) {
        [self.streamIds removeObject:aStream.userName];
        [self.streamIds addObject:aStream.streamId];
        return;
    }
    [self.streamIds addObject:aStream.streamId];
    BRConfUserView *userView = [self _setupUserViewWithUserName:aStream.userName streamId:aStream.streamId];
    userView.isMuted = !aStream.enableVoice;
    
    EMCallRemoteView *remoteView = nil;
    if (aStream.enableVideo) {
        remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
        remoteView.tag = 100;
        remoteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        remoteView.scaleMode = EMCallViewScaleModeAspectFill;
        [userView.videoView addSubview:remoteView];
    }
    
//    __weak typeof(self) weakSelf = self;
//    [[EMClient sharedClient].conferenceManager subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
//        if (aError) {
//            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), weakSelf.createrName];
            //            [weakSelf showHint:message];
//        }
//    }];
}

- (void)_removeStream:(EMCallStream *)aStream
{
    NSInteger index = -1;
    BRConfUserView *userView = nil;
    if ([self.streamIds containsObject:aStream.streamId]) {
        index = [self.streamIds indexOfObject:aStream.streamId];
        userView = [self.streamViews objectForKey:aStream.streamId];
        [self.streamViews removeObjectForKey:aStream.streamId];
        [self.streamIds removeObject:aStream.streamId];
    } else if ([self.streamIds containsObject:self.createrName]) {
        index = [self.streamIds indexOfObject:self.createrName];
        userView = [self.streamViews objectForKey:self.createrName];
        [self.streamViews removeObjectForKey:aStream.streamId];
        [self.streamIds removeObject:aStream.userName];
    }

    CGRect frame = userView.frame;
    [userView removeFromSuperview];

    for (; index < [self.streamIds count]; index++) {
        NSString *sId = [self.streamIds objectAtIndex:index];
        UIView *view = [self.streamViews objectForKey:sId];
        CGRect tmpFrame = view.frame;
        view.frame = frame;
        frame = tmpFrame;
    }
}

- (void)_userViewDidConnectedWithStreamId:(NSString *)aStreamId
{
    BRConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    if (userView) {
        userView.status = EMAudioStatusConnected;
    }
}

#pragma mark - EMConferenceManagerDelegate


- (void)userDidJoin:(EMCallConference *)aConference
               user:(NSString *)aUserName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *joinMess = NSLocalizedString(@" has joined to the conference.", nil);
        hud.label.text = [aUserName stringByAppendingString:joinMess];
        [hud hideAnimated:YES afterDelay:1.5];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    }
}

- (void)userDidLeave:(EMCallConference *)aConference
                user:(NSString *)aUserName
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
        if (self.streamIds.count == 1) {
            hud.label.text = NSLocalizedString(@"Conference call ended.", nil);
            [hud hideAnimated:YES afterDelay:1.5];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
            [self hangupAction:nil];
        } else {
            NSString *joinMess = NSLocalizedString(@" left the conference.", nil);
            hud.label.text = [aUserName stringByAppendingString:joinMess];
            [hud hideAnimated:YES afterDelay:1.5];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        }
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self.streamsDic setObject:aStream forKey:aStream.streamId];
        [self _subStream:aStream];
        if (!self.timeTimer) {
            [self _startTimeTimer];
        }
        [self _stopCallTimer];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self.streamsDic removeObjectForKey:aStream.streamId];
        [self _removeStream:aStream];
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [[BRAudioCallManager sharedManager] setIsCalling:NO];
        self.conference = nil;
        hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
        hud.label.text = NSLocalizedString(@"Conference call ended.", nil);
        [hud hideAnimated:YES afterDelay:1.5];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        [self dismissVC];
        
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId] && aStream != nil) {
        EMCallStream *oldStream = [self.streamsDic objectForKey:aStream.streamId];
        if (oldStream) {
            if (oldStream.enableVideo != aStream.enableVideo) {
                BRConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
                EMCallRemoteView *displayView = [userView.videoView viewWithTag:100];
                if (displayView == nil && aStream.enableVideo) {
                    displayView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
                    displayView.tag = 100;
                    displayView.scaleMode = EMCallViewScaleModeAspectFill;
                    [userView.videoView addSubview:displayView];
                    
                    [[EMClient sharedClient].conferenceManager updateConference:self.conference streamId:aStream.streamId remoteVideoView:displayView completion:nil];
                }
                displayView.hidden = !aStream.enableVideo;
            } else if (oldStream.enableVoice != aStream.enableVoice) {
                BRConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
                if (!userView) {
                    userView = [self.streamViews objectForKey:aStream.userName];
                }
                userView.isMuted = !aStream.enableVoice;
                if (aStream.enableVoice) {
                    userView.status = EMAudioStatusConnected;
                }
            }
            
            [self.streamsDic setObject:aStream forKey:aStream.streamId];
        }
    }
}

- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if ([aStreamId isEqualToString:self.pubStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
        } else if ([self.streamViews objectForKey:aStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
        }
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            str = NSLocalizedString(@"Network normal", nil);
            break;
        case EMCallNetworkStatusUnstable:
            str = NSLocalizedString(@"Network unstable", nil);
            break;
        case EMCallNetworkStatusNoData:
            str = NSLocalizedString(@"Network Disconnected", nil);
            break;
            
        default:
            break;
    }
    if ([str length] > 0) {
        hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
        hud.label.text = str;
        [hud hideAnimated:YES afterDelay:1.5];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    }
}

- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
    
    for (NSString *streamId in aStreamIds) {
        BRConfUserView *userView = [self.streamViews objectForKey:streamId];
        userView.status = EMAudioStatusTalking;
        
        [self.talkingStreamIds removeObject:streamId];
    }
    
    for (NSString *streamId in self.talkingStreamIds) {
        BRConfUserView *userView = [self.streamViews objectForKey:streamId];
        userView.status = EMAudioStatusConnected;
    }
    
    [self.talkingStreamIds removeAllObjects];
    [self.talkingStreamIds addObjectsFromArray:aStreamIds];
}

#pragma mark - BRConfUserViewDelegate

- (void)tapUserViewWithStreamId:(NSString *)aStreamId
{
    self.currentMaxStreamId = aStreamId;
    BRConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    UIView *displayView = [userView.videoView viewWithTag:100];
    if (displayView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        displayView.frame = CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height);
        [displayView addSubview:self.minButton];
        [displayView removeFromSuperview];
        [window addSubview:displayView];
    }
}

#pragma mark - action

- (IBAction)inviteMemberAction:(id)sender
{
    NSMutableArray *groupMembersArray = [[[BRCoreDataManager sharedInstance] fetchGroupMembersByGroupID:self.groupID andGroupMemberUserNameArray:nil] mutableCopy];
    NSArray *streams = [self.streamsDic allValues];
    for (EMCallStream *stream in streams) {
        for (BRFriendsInfo *groupMember in groupMembersArray) {
            if ([groupMember.username isEqualToString:stream.userName]) {
                [groupMembersArray removeObject:groupMember];
                break;
            }
        }
    }
    
    __weak typeof(self) weakself = self;
    BRConfUserSelectionViewController *confVC = [[BRConfUserSelectionViewController alloc] initWithInviteMoreMembers: groupMembersArray selectedUsers:nil andCreateCon:NO andGroupID:self.groupID];
    [confVC setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        for (NSString *userName in selectedUsers) {
            [weakself _inviteUser:userName];
        }
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:confVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)muteButtonAction:(id)sender
{
    self.muteButton.selected = !self.muteButton.selected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference isMute:self.muteButton.selected];
}

- (IBAction)speakerOutAction:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.speakerOutButton.selected = !self.speakerOutButton.selected;
}

- (IBAction)enableCameraAction:(id)sender
{
    self.enableCameraButton.selected = !self.enableCameraButton.selected;
    self.switchCameraButton.hidden = !self.enableCameraButton.selected;
    
    [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:self.enableCameraButton.selected];
    
    if (self.enableCameraButton.selected) {
        NSString *key = self.pubStreamId;
        if ([key length] == 0) {
            key = [EMClient sharedClient].currentUsername;
        }
        BRConfUserView *userView = [self.streamViews objectForKey:key];
        [userView.videoView addSubview:self.localView];
        [userView.videoView sendSubviewToBack:self.localView];
    } else {
        [self.localView removeFromSuperview];
    }
}

- (IBAction)switchCameraAction:(id)sender
{
    //3.3.9 new 自定义视频数据
    self.switchCameraButton.selected = !self.switchCameraButton.selected;
    //    if (self.videoModel == VIDEO_INPUT_MODE_NONE) {
    //        [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
    //    } else {
    //        [self.videoCamera swapCameraWithPosition:(self.switchCameraButton.selected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront)];
    //    }
}

- (void)minAction
{
    BRConfUserView *userView = [self.streamViews objectForKey:self.currentMaxStreamId];
    self.currentMaxStreamId = nil;
    
    UIView *displayView = self.minButton.superview;
    [self.minButton removeFromSuperview];
    displayView.frame = CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height);
    displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [displayView removeFromSuperview];
    [userView.videoView addSubview:displayView];
}

- (IBAction)hangupAction:(id)sender
{
    
    //3.3.9 new 自定义视频数据
    [self closeVideoCamera];
    [self _stopTimeTimer];
    [self _stopCallTimer];
    //    [[BRAudioCallManager sharedManager] setIsCalling:NO];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    if (self.conference == nil) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
        [self dismissVC];
    }
    
    //    if (_isCreater) {
    //        NSString *localName = [EMClient sharedClient].currentUsername;
    //        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 结束了多人会议", localName]];
    //        EMMessage *message = [[EMMessage alloc] initWithConversationID:_conversationId from:localName to:_conversationId body:body ext:nil];
    //        message.chatType = EMChatTypeGroupChat;
    //        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    //    }
    
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:self.conference];
    [[EMClient sharedClient].conferenceManager leaveConference:self.conference completion:nil];
    
    self.conference = nil;
    //    self.navigationController.navigationBarHidden = NO;
    //    [self.navigationController popViewControllerAnimated:NO];
    [self dismissVC];
}

- (IBAction)rejectAction {
    [self _stopTimeTimer];
    [self _stopCallTimer];
    [self dismissVC];
}

- (IBAction)answerAction {
    self.rejectButton.hidden = YES;
    self.answerButton.hidden = YES;
    self.hangupButton.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"Waiting for a connection", nil);
    [self _stopCallTimer];
//    if (self.conferenceId) {
//        [self _createOrJoinConference];
//    } else {
    
        NSDictionary *request = [[NSUserDefaults standardUserDefaults] objectForKey:KBRAudioConferenceInviteExtKey];
        if (request) {
            NSString *key = [request objectForKey: @"e"];
            if (key) {
                NSString *confID = [key componentsSeparatedByString:@":"][1];
                if (confID) {
                    self.conferenceId = confID;
                    [self _createOrJoinConference];
                }
            }
        }
//    }
}

- (void)dismissVC {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KBRAudioConferenceInviteExtKey];
    if (self.isCreater) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoMessageViewController" object:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 3.3.9 new 自定义视频数据

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    //    if(!self.conference || [self.pubStreamId length] == 0 || self.videoModel == VIDEO_INPUT_MODE_NONE){
    //        return;
    //    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer == NULL) {
        return ;
    }
    
    CVOptionFlags lockFlags = kCVPixelBufferLock_ReadOnly;
    CVReturn ret = CVPixelBufferLockBaseAddress(imageBuffer, lockFlags);
    if (ret != kCVReturnSuccess) {
        return ;
    }
    
    static size_t const kYPlaneIndex = 0;
    static size_t const kUVPlaneIndex = 1;
    uint8_t* yPlaneAddress = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kYPlaneIndex);
    size_t uvPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kUVPlaneIndex);
    size_t uvPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kUVPlaneIndex);
    size_t frameSize = yPlaneBytesPerRow * yPlaneHeight + uvPlaneBytesPerRow * uvPlaneHeight;
    
    // set uv for gray color
    uint8_t * uvPlaneAddress = yPlaneAddress + yPlaneBytesPerRow * yPlaneHeight;
    memset(uvPlaneAddress, 0x7F, uvPlaneBytesPerRow * uvPlaneHeight);
    //    if(self.videoModel == VIDEO_INPUT_MODE_DATA){
    //        [[EMClient sharedClient].conferenceManager inputVideoData:[NSData dataWithBytes:yPlaneAddress length:frameSize] conference:self.conference publishedStreamId:self.pubStreamId widthInPixels:yPlaneWidth heightInPixels:yPlaneHeight format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    //    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, lockFlags);
    
    //    if(self.videoModel == VIDEO_INPUT_MODE_SAMPLE_BUFFER) {
    //        [[EMClient sharedClient].conferenceManager inputVideoSampleBuffer:sampleBuffer conference:self.conference publishedStreamId:self.pubStreamId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    //    } else if(self.videoModel == VIDEO_INPUT_MODE_PIXEL_BUFFER) {
    //        [[EMClient sharedClient].conferenceManager inputVideoPixelBuffer:imageBuffer conference:self.conference publishedStreamId:self.pubStreamId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    //    }
}

- (IBAction)moreAction:(id)sender
{
    self.videoFormatView.hidden = NO;
}

- (IBAction)videoModelValueChanged:(UISegmentedControl *)sender
{
    //    NSInteger index = sender.selectedSegmentIndex;
    //    switch (index) {
    //        case 0:
    //            self.videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
    //            break;
    //        case 1:
    //            self.videoModel = VIDEO_INPUT_MODE_PIXEL_BUFFER;
    //            break;
    //        case 2:
    //            self.videoModel = VIDEO_INPUT_MODE_DATA;
    //            break;
    //
    //        default:
    //            break;
    //    }
}

- (IBAction)closeVideoFormatViewAction:(id)sender
{
    self.videoFormatView.hidden = YES;
}

- (void)openVideoCamera
{
    //    if(self.videoCamera){
    //        return ;
    //    }
    //
    //    self.videoCamera = [[VideoCustomCamera alloc] initWithQueue:dispatch_get_main_queue()];
    //    [self.videoCamera syncSetDataDelegate:self onDone:nil];
    //    BOOL ok = [self.videoCamera syncOpenWithWidth:640 height:480 onDone:nil];
    //    if(!ok){
    //        [self.videoCamera syncClose:nil];
    //        self.videoCamera = nil;
    //    }
}

- (void)closeVideoCamera
{
    //if(self.videoCamera){
    //        [self.videoCamera syncClose:^(id obj, NSError *error) {}];
    //        self.videoCamera = nil;
    //    }
}

#pragma mark - private timer

- (void)timeTimerAction:(id)sender
{
    self.timeLength += 1;
    int hour = self.timeLength / 3600;
    int m = (self.timeLength - hour * 3600) / 60;
    int s = self.timeLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, m, s];
    } else{
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
}

- (void)_startTimeTimer
{
    self.statusLabel.hidden = YES;
    self.timeLabel.hidden = NO;
    self.timeLength = 0;
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)_stopTimeTimer
{
    if (self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

#pragma mark - private call timer

- (void)_timeoutBeforeCallAnswered
{
    
    hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
    if (self.isCreater) {
        hud.label.text = NSLocalizedString(@"Group members are not available.", nil);
        
        [hud hideAnimated:YES afterDelay:1.5];
    } else {
        hud.label.text = NSLocalizedString(@"Conference call ended.", nil);
        [hud hideAnimated:YES afterDelay:1.5];
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    [self dismissVC];
}

- (void)_startCallTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

- (void)_stopCallTimer
{
    if (self.timer == nil) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}


@end
