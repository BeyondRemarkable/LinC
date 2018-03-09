//
//  BRMessageViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSDate+Category.h"
#import "BRMessageViewController.h"
#import "BRCustomMessageCell.h"
#import "BRMessageTimeCell.h"
#import "BREmoji.h"
#import "BREmotionManager.h"
#import "BRCDDeviceManager.h"
#import "BRMessageReadManager.h"
#import <MBProgressHUD.h>
#import <SDWebImage/UIImage+GIF.h>
#import "BRCoreDataManager.h"
#import "BRUserInfo+CoreDataClass.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRConversation+CoreDataClass.h"
#import "BRGroupChatSettingTableViewController.h"
#import "UIView+NavigationBar.h"
#import <Photos/PHPhotoLibrary.h>

#define KHintAdjustY    50
#define KTransitionDuration 0.2
#define IOS_VERSION [[UIDevice currentDevice] systemVersion]>=9.0

typedef enum : NSUInteger {
    BRRequestRecord,
    BRCanRecord,
    BRCanNotRecord,
} BRRecordResponse;

@implementation BRAtTarget
- (instancetype)initWithUserId:(NSString*)userId andNickname:(NSString*)nickname
{
    if (self = [super init]) {
        _userId = [userId copy];
        _nickname = [nickname copy];
    }
    return self;
}
@end

@interface BRMessageViewController () <BRMessageCellDelegate>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    NSMutableArray *_atTargets;
    
    dispatch_queue_t _messageQueue;
    BOOL _isRecording;
    
    BOOL _isLoadingMessages;
   
    MBProgressHUD *hud;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, strong) NSMutableArray *atTargets;
@property (nonatomic, strong) BRUserInfo *userInfo;
@property (nonatomic, strong) BRFriendsInfo *friendsInfo;

@property (nonatomic, strong) UIImageView *transitionView;
@property (nonatomic) CGRect oldFrame;
@property (nonatomic, strong) NSMutableDictionary<NSString *, BRContactListModel *> *dict;

@end

@implementation BRMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        
        _messageCountOfPage = 20;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        
        [_conversation markAllMessagesAsRead:nil];
    }
    
    
    return self;
}

- (NSMutableDictionary<NSString *,BRContactListModel *> *)dict {
    if (_dict == nil) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImagePicker) name:@"hideImagePicker" object:nil];
    
    //Initialization
    CGFloat chatbarHeight = [BRChatToolbar defaultHeight];
    BRChatToolbarType barType = self.conversation.type == EMConversationTypeChat ? BRChatToolbarTypeChat : BRChatToolbarTypeGroup;
    self.chatToolbar = [[BRChatToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - chatbarHeight - iPhoneX_BOTTOM_HEIGHT, self.view.frame.size.width, chatbarHeight) type:barType];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //Initializa the gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.tableView addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    _messageQueue = dispatch_queue_create("BRSerialMessageQueue", NULL);
    
    //Register the delegate
    [BRCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[BRBaseMessageCell appearance] setSendBubbleBackgroundImage:[UIImage imageNamed:@"chat_sender_bubbleBg"]];
    [[BRBaseMessageCell appearance] setRecvBubbleBackgroundImage:[UIImage imageNamed:@"chat_receiver_bubbleBg"]];
    
    [[BRBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"], [UIImage imageNamed:@"chat_sender_audio_playing_0"], [UIImage imageNamed:@"chat_sender_audio_playing_1"], [UIImage imageNamed:@"chat_sender_audio_playing_2"], [UIImage imageNamed:@"chat_sender_audio_playing_3"]]];
    [[BRBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing_full"],[UIImage imageNamed:@"chat_receiver_audio_playing_0"], [UIImage imageNamed:@"chat_receiver_audio_playing_1"], [UIImage imageNamed:@"chat_receiver_audio_playing_2"], [UIImage imageNamed:@"chat_receiver_audio_playing_3"]]];
    
    [[BRBaseMessageCell appearance] setAvatarSize:40.f];
    //[[BRBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[BRChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self setupEmotion];
    [self setUpNavigationBarItem];
    
    // 版本更新后使用tableview的自定义高度时设置这些参数非常重要!!!!!!!!!!
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    // 从数据库获取自己的信息
    self.userInfo = [[BRCoreDataManager sharedInstance] getUserInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.transitionView != nil) {
        [UIView animateWithDuration:KTransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transitionView.frame = self.oldFrame;
            self.transitionView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self.transitionView removeFromSuperview];
            self.transitionView = nil;
            self.oldFrame = CGRectZero;
        }];
    }
}

// 群聊时的 navigation bar items
- (void)setUpNavigationBarItem {
    if (self.conversation.type == EMConversationTypeGroupChat) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 35, 35)];
        if (@available(iOS 11.0, *)) {
            [btn addNavigationBarConstraintsWithWidth:35 height:35];
        }
        [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}


/**
 群聊的群设置
 */
- (void)settingClick {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        // 群设置
        BRGroupChatSettingTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRGroupChatSettingTableViewController"];
        vc.groupID = self.conversation.conversationId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*!
 @method
 @brief 设置表情
 @discussion 加载默认表情，如果子类实现了dataSource的自定义表情回调，同时会加载自定义表情
 */
- (void)setupEmotion
{
    if ([self.dataSource respondsToSelector:@selector(emotionFormessageViewController:)]) {
        NSArray* emotionManagers = [self.dataSource emotionFormessageViewController:self];
        [self.faceView setEmotionManagers:emotionManagers];
    } else {
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSString *name in [BREmoji allEmoji]) {
            BREmotion *emotion = [[BREmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:BREmotionDefault];
            [emotions addObject:emotion];
        }
        BREmotion *emotion = [emotions objectAtIndex:0];
        BREmotionManager *manager= [[BREmotionManager alloc] initWithType:BREmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
        [self.faceView setEmotionManagers:@[manager]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[BRCDDeviceManager sharedInstance] stopPlaying];
    [BRCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewDidAppear = YES;
    [[BRSDKHelper shareHelper] setIsShowingimagePicker:NO];
    
    if (self.scrollToBottomWhenAppear) {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewDidAppear = NO;
    [[BRCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - chatroom

- (void)saveChatroom:(EMChatroom *)chatroom
{
    NSString *chatroomName = chatroom.subject ? chatroom.subject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId])
    {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

/*!
 @method
 @brief 加入聊天室
 */
- (void)joinChatroom:(NSString *)chatroomId
{
    __weak typeof(self) weakSelf = self;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"chatroom.joining",@"Joining the chatroom");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMChatroom *chatroom = [[EMClient sharedClient].roomManager joinChatroom:chatroomId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                BRMessageViewController *strongSelf = weakSelf;
                [hud hideAnimated:YES];
                if (error != nil) {
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.label.text = [NSString stringWithFormat:NSLocalizedString(@"chatroom.joinFailed",@"join chatroom \'%@\' failed"), chatroomId];
                } else {
                    strongSelf.isJoinedChatroom = YES;
                    [strongSelf saveChatroom:chatroom];
                }
            }  else {
                if (!error || (error.code == EMErrorChatroomAlreadyJoined)) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        EMError *leaveError;
                        [[EMClient sharedClient].roomManager leaveChatroom:chatroomId error:&leaveError];
                        [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:nil];
                    });
                }
            }
        });
    });
}

#pragma mark - EMChatManagerChatroomDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = [NSString stringWithFormat:NSLocalizedString(@"chatroom.join", @"\'%@\'join chatroom\'%@\'"), aUsername, aChatroom.chatroomId];
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = [NSString stringWithFormat:NSLocalizedString(@"chatroom.leave.hint", @"\'%@\'leave chatroom\'%@\'"), aUsername, aChatroom.chatroomId];
}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason
{
    if ([_conversation.conversationId isEqualToString:aChatroom.chatroomId])
    {
        _isKicked = YES;
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = [NSString stringWithFormat:NSLocalizedString(@"chatroom.remove", @"be removed from chatroom\'%@\'"), aChatroom.chatroomId];
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (NSMutableArray*)atTargets
{
    if (!_atTargets) {
        _atTargets = [NSMutableArray array];
    }
    return _atTargets;
}

#pragma mark - setter

- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:nil];
    }
}

- (void)setChatToolbar:(BRChatToolbar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height - iPhoneX_BOTTOM_HEIGHT;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[BRChatToolbar class]]) {
        [(BRChatToolbar *)self.chatToolbar setDelegate:self];
        self.chatBarMoreView = (BRChatBarMoreView*)[(BRChatToolbar *)self.chatToolbar moreView];
        self.faceView = (BRFaceView*)[(BRChatToolbar *)self.chatToolbar faceView];
        self.recordView = (BRRecordView*)[(BRChatToolbar *)self.chatToolbar recordView];
    }
}

- (void)setDataSource:(id<BRMessageViewControllerDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self setupEmotion];
}

- (void)setDelegate:(id<BRMessageViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - private helper

/*!
 @method
 @brief tableView滑动到底部
 */
- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

/*!
 @method
 @brief 当前设备是否可以录音
 @param aCompletion 判断结果
 */
- (void)_canRecordCompletion:(void(^)(BRRecordResponse))aCompletion
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {

        }];
        if (aCompletion) {
            aCompletion(BRRequestRecord);
        }
    }
    else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        aCompletion(BRCanNotRecord);
    }
    else{
        aCompletion(BRCanRecord);
    }
}

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (messageType == EMMessageBodyTypeText) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[BRCDDeviceManager sharedInstance] stopPlaying];
    [[BRCDDeviceManager sharedInstance] disableProximitySensor];
    [BRCDDeviceManager sharedInstance].delegate = nil;
    
    //    MessageModel *playingModel = [self.EaseMessageReadManager stopMessageAudioModel];
    //    NSIndexPath *indexPath = nil;
    //    if (playingModel) {
    //        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    //    }
    //
    //    if (indexPath) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.tableView beginUpdates];
    //            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //            [self.tableView endUpdates];
    //        });
    //    }
}

/*!
 @method
 @brief mov格式视频转换为MP4格式
 @param movUrl   mov视频路径
 @result  MP4格式视频路径
 */
- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [BRCDDeviceManager dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

/*!
 @method
 @brief 通过当前会话类型，返回消息聊天类型
 @result 聊天类型
 */
- (EMChatType)_messageTypeFromConversationType
{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_customDownloadMessageFile:(EMMessage *)aMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"message.autoTransfer", @"Please customize the  transfer attachment method") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

/*!
 @method
 @brief 下载消息附件
 @param message  待下载附件的消息
 */
- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!");
            [hud hideAnimated:YES afterDelay:1.5];
        }
    };
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[EMClient sharedClient].chatManager downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[EMClient sharedClient].chatManager downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message attachment
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
                        if (!error) {
                            [weakSelf _reloadTableViewDataWithMessage:message];
                        }
                        else {
                            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.label.text = NSLocalizedString(@"message.voiceFail", @"voice for failure!");
                        }
                    }];
                }
            }
        }
    }
}

/*!
 @method
 @brief 传入消息是否需要发动已读回执
 @param message  待判断的消息
 @param read     消息是否已读
 @result BOOL
 */
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    return NO;
//    if (message.chatType != EMChatTypeChat || message.isReadAcked || message.direction == EMMessageDirectionSend || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
//    {
//        return NO;
//    }
//
//    EMMessageBody *body = message.body;
//    if (((body.type == EMMessageBodyTypeVideo) ||
//         (body.type == EMMessageBodyTypeVoice) ||
//         (body.type == EMMessageBodyTypeImage)) &&
//        !read)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
}

/*!
 @method
 @brief 为传入的消息发送已读回执
 @param messages  待发送已读回执的消息数组
 @param isRead    是否已读
 */
- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        __block BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:isRead];
        }
        else{
            isSend = [self shouldSendHasReadAckForMessage:message read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

/*!
 @method
 @brief 位置消息被点击选择
 @param model 消息model
 */
- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    BRLocationViewController *locationController = [[BRLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

/*!
 @method
 @brief 视频消息被点击选择
 @param model 消息model
 */
- (void)_videoMessageCellSelected:(BRMessageCell *)messageCell
{
    _scrollToBottomWhenAppear = NO;
    BRMessageModel *model = messageCell.model;
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.message.body;
    
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"message.videoFail", @"video for failure!");
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [hud hideAnimated:YES];
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!");
            [hud hideAnimated:YES afterDelay:1.5];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"begin downloading thumbnail image, click later";
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:completion];
        }
        return;
    }
    
    // 将图片动画放大
    UIImage *image = [UIImage imageWithContentsOfFile:videoBody.thumbnailLocalPath];

    self.oldFrame = [messageCell.bubbleView convertRect:messageCell.bubbleView.videoImageView.frame toView:self.view];
    CGRect newFrame = CGRectMake(0, 5, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.transitionView = [[UIImageView alloc] initWithFrame:self.oldFrame];
    self.transitionView.image = image;
    self.transitionView.contentMode = UIViewContentModeScaleAspectFit;
    self.transitionView.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:self.transitionView];
    [UIView animateWithDuration:KTransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transitionView.frame = newFrame;
        self.transitionView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        // 弹出图片浏览器
        [[BRMessageReadManager defaultManager] showBrowserWithModels:@[model] animated:NO];
    }];
//    dispatch_block_t block = ^{
//        //send the acknowledgement
//        [self _sendHasReadResponseForMessages:@[model.message]
//                                       isRead:YES];
//
//        [[BRMessageReadManager defaultManager] showBrowserWithModels:@[model] animated:YES];
//    };
//
//    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
//    {
//        block();
//        return;
//    }
//
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.label.text = NSLocalizedString(@"message.downloadingVideo", @"downloading video...");
//    if (isCustomDownload) {
//        [self _customDownloadMessageFile:model.message];
//    } else {
//        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
//            if (!error) {
//                [hud hideAnimated:YES];
//                block();
//            }else{
//                hud.mode = MBProgressHUDModeText;
//                hud.label.text = NSLocalizedString(@"message.videoFail", @"video for failure!");
//                [hud hideAnimated:YES afterDelay:1.5];
//            }
//        }];
//    }
}

/*!
 @method
 @brief 图片消息被点击选择
 @param model 消息model
 */
- (void)_imageMessageCellSelected:(BRMessageCell *)messageCell
{
    __weak BRMessageViewController *weakSelf = self;
    BRMessageModel *model = messageCell.model;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)model.message.body;
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if ([imageBody type] == EMMessageBodyTypeImage) {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSucceed) {
            // 将图片动画放大
            UIImage *image = nil;
            if (imageBody.downloadStatus == EMDownloadStatusSucceed) {
                image = model.image ? model.image : [UIImage imageWithContentsOfFile:model.fileLocalPath];
            }
            else {
                image = model.thumbnailImage;
            }
            self.oldFrame = [messageCell.bubbleView convertRect:messageCell.bubbleView.imageView.frame toView:self.view];
            CGRect newFrame = CGRectMake(0, 5, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.transitionView = [[UIImageView alloc] initWithFrame:self.oldFrame];
            self.transitionView.image = image;
            self.transitionView.contentMode = UIViewContentModeScaleAspectFit;
            self.transitionView.backgroundColor = [UIColor clearColor];
            [self.navigationController.view addSubview:self.transitionView];
            [UIView animateWithDuration:KTransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.transitionView.frame = newFrame;
                self.transitionView.backgroundColor = [UIColor blackColor];
            } completion:^(BOOL finished) {
                // 弹出图片浏览器
                [[BRMessageReadManager defaultManager] showBrowserWithModels:@[model] animated:NO];
            }];
        }else{
            //get the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:model.message];
            } else {
                [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                    if (!error) {
                        [weakSelf _reloadTableViewDataWithMessage:model.message];
                    }else{
                        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!");
                        [hud hideAnimated:YES afterDelay:1.5];
                    }
                }];
            }
        }
    }
}

/*!
 @method
 @brief 语音消息被点击选择
 @param model 消息model
 */
- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later");
        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed || downloadStatus == EMDownloadStatusPending)
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later");
        BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (error == nil) {
                    [hud hideAnimated:YES];
                }
                else {
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = error.errorDescription;
                    [hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }
        
        return;
    }
    
    // play the audio
    if (model.bodyType == EMMessageBodyTypeVoice) {
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak BRMessageViewController *weakSelf = self;
        BOOL isPrepare = [[BRMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(BRMessageModel *prevAudioModel, BRMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak BRMessageViewController *weakSelf = self;
            [[BRCDDeviceManager sharedInstance] enableProximitySensor];
            [[BRCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[BRMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[BRCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - pivate data

/*!
 @method
 @brief 加载历史消息
 @param messageId 参考消息的ID
 @param count     获取条数
 @param isAppend  是否在dataArray直接添加
 */
- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    void (^refresh)(NSArray *messages) = ^(NSArray *messages) {
        dispatch_async(_messageQueue, ^{
            //Format the message
            NSArray *formattedMessages = [weakSelf formatMessages:messages];
            
            //Refresh the page
            dispatch_async(dispatch_get_main_queue(), ^{
                BRMessageViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    NSInteger scrollToIndex = 0;
                    if (isAppend) {
                        [strongSelf.messsagesSource insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                        
                        //Combine the message
                        id object = [strongSelf.dataArray firstObject];
                        if ([object isKindOfClass:[NSString class]]) {
                            NSString *timestamp = object;
                            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model]) {
                                    [strongSelf.dataArray removeObjectAtIndex:0];
                                    *stop = YES;
                                }
                            }];
                        }
                        scrollToIndex = [strongSelf.dataArray count];
                        [strongSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
                    }
                    else {
                        [strongSelf.messsagesSource removeAllObjects];
                        [strongSelf.messsagesSource addObjectsFromArray:messages];
                        
                        [strongSelf.dataArray removeAllObjects];
                        [strongSelf.dataArray addObjectsFromArray:formattedMessages];
                    }
                    
                    EMMessage *latest = [strongSelf.messsagesSource lastObject];
                    strongSelf.messageTimeIntervalTag = latest.timestamp;
                    
                    [strongSelf.tableView reloadData];
                    
                    [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            });
            
            //re-download all messages that are not successfully downloaded
            for (EMMessage *message in messages)
            {
                [weakSelf _downloadMessageAttachments:message];
            }
            
            //send the read acknoledgement
//            [weakSelf _sendHasReadResponseForMessages:messages isRead:NO];
        });
    };
    
    _isLoadingMessages = YES;
    [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError) {
            if (aMessages.count) {
                refresh(aMessages);
                _isLoadingMessages = NO;
            }
            else {
                _isLoadingMessages = YES;
            }
        }
        else {
            _isLoadingMessages = NO;
        }
    }];
}

#pragma mark - GestureRecognizer

-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        BOOL canLongPress = NO;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
            canLongPress = [_dataSource messageViewController:self
                                   canLongPressRowAtIndexPath:indexPath];
        }
        
        if (!canLongPress) {
            return;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
            [_dataSource messageViewController:self
                    didLongPressRowAtIndexPath:indexPath];
        }
        else{
            id object = [self.dataArray objectAtIndex:indexPath.row];
            if (![object isKindOfClass:[NSString class]]) {
                BRMessageCell *cell = (BRMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell becomeFirstResponder];
                _menuIndexPath = indexPath;
                [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //time cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [BRMessageTimeCell cellIdentifier];
        BRMessageTimeCell *timeCell = (BRMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[BRMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    else{
        id<IMessageModel> model = object;
        
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:cellForMessageModel:)]) {
            UITableViewCell *cell = [_delegate messageViewController:tableView cellForMessageModel:model];
            if (cell) {
                if ([cell isKindOfClass:[BRMessageCell class]]) {
                    BRMessageCell *emcell= (BRMessageCell*)cell;
                    if (emcell.delegate == nil) {
                        emcell.delegate = self;
                    }
                }
                return cell;
            }
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                NSString *CellIdentifier = [BRCustomMessageCell cellIdentifierWithModel:model];
                //send cell
                BRCustomMessageCell *sendCell = (BRCustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                // Configure the cell...
                if (sendCell == nil) {
                    sendCell = [[BRCustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                    sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                if (_dataSource && [_dataSource respondsToSelector:@selector(emotionURLFormessageViewController:messageModel:)]) {
                    BREmotion *emotion = [_dataSource emotionURLFormessageViewController:self messageModel:model];
                    if (emotion) {
                        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[emotion.emotionOriginal stringByAppendingString:@"@2x"] ofType:@"gif"];
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSData *data = [NSData dataWithContentsOfFile:retinaPath];
                            model.image = [UIImage sd_animatedGIFWithData:data];
                            model.fileURLPath = emotion.emotionOriginalURL;
                        });
                    }
                }
                sendCell.model = model;
                sendCell.delegate = self;
                return sendCell;
            }
        }
        
        NSString *CellIdentifier = [BRMessageCell cellIdentifierWithModel:model];
        
        BRBaseMessageCell *sendCell = (BRBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[BRBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        
        sendCell.model = model;
        return sendCell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:heightForMessageModel:withCellWidth:)]) {
            CGFloat height = [_delegate messageViewController:self heightForMessageModel:model withCellWidth:tableView.frame.size.width];
            if (height) {
                return height;
            }
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                return [BRCustomMessageCell cellHeightWithModel:model];
            }
        }
        
        return [BRBaseMessageCell cellHeightWithModel:model];
    }
}

#pragma mark - UIScrollviewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatToolbar endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_isLoadingMessages) {
        return;
    }
    if (scrollView.contentOffset.y < 5) {
        EMMessage *firstMessage = [self.messsagesSource firstObject];
        if (firstMessage) {
            [self _loadMessagesBefore:firstMessage.messageId count:self.messageCountOfPage append:YES];
            [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    NSLog(@"TO TOP");
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        } else {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                if (asset) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                        if (data != nil) {
                            [self sendImageMessageWithData:data];
                        } else {
                            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.label.text = NSLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one");
                        }
                    }];
                }
            }];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[BRSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[BRSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - BRMessageCellDelegate

- (void)messageCellSelected:(BRMessageCell *)messageCell
{
    id<IMessageModel> model = messageCell.model;
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:)]) {
        BOOL flag = [_delegate messageViewController:self didSelectMessageModel:model];
        if (flag) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
            return;
        }
    }
    
    switch (model.bodyType) {
        case EMMessageBodyTypeImage:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:messageCell];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            [self _locationMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            [self _videoMessageCellSelected:messageCell];
            
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"Custom implementation!";
        }
            break;
        default:
            break;
    }
}

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(BRMessageCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            [weakself _refreshAfterSentMessage:message];
        }
        else {
            [weakself.tableView reloadData];
        }
    }];
    
    [self.tableView reloadData];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectAvatarMessageModel:)]) {
        [_delegate messageViewController:self didSelectAvatarMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight - iPhoneX_BOTTOM_HEIGHT;
        self.tableView.frame = rect;
    }];
    
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewWillBeginEditing:(BRTextView *)inputTextView
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
        [self.atTargets removeAllObjects];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:selectAtTarget:)] && self.conversation.type == EMConversationTypeGroupChat) {
        location += 1;
        __weak typeof(self) weakSelf = self;
        [self.delegate messageViewController:self selectAtTarget:^(BRAtTarget *target) {
            __strong BRMessageViewController *strongSelf = weakSelf;
            if (strongSelf && target) {
                if ([target.userId length] || [target.nickname length]) {
                    [strongSelf.atTargets addObject:target];
                    NSString *insertStr = [NSString stringWithFormat:@"%@ ", target.nickname ? target.nickname : target.userId];
                    BRChatToolbar *toolbar = (BRChatToolbar*)strongSelf.chatToolbar;
                    NSMutableString *originStr = [toolbar.inputTextView.text mutableCopy];
                    NSUInteger insertLocation = location > originStr.length ? originStr.length : location;
                    [originStr insertString:insertStr atIndex:insertLocation];
                    toolbar.inputTextView.text = originStr;
                    toolbar.inputTextView.selectedRange = NSMakeRange(insertLocation + insertStr.length, 0);
                    [toolbar.inputTextView becomeFirstResponder];
                }
            }
            else if (strongSelf) {
                BRChatToolbar *toolbar = (BRChatToolbar*)strongSelf.chatToolbar;
                [toolbar.inputTextView becomeFirstResponder];
            }
        }];
        BRChatToolbar *toolbar = (BRChatToolbar*)self.chatToolbar;
        toolbar.inputTextView.text = [NSString stringWithFormat:@"%@@", toolbar.inputTextView.text];
        [toolbar.inputTextView resignFirstResponder];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location
{
    BRChatToolbar *toolbar = (BRChatToolbar*)self.chatToolbar;
    if ([toolbar.inputTextView.text length] == location + 1) {
        //delete last character
        NSString *inputText = toolbar.inputTextView.text;
        NSRange range = [inputText rangeOfString:@"@" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            if (location - range.location > 1) {
                NSString *sub = [inputText substringWithRange:NSMakeRange(range.location + 1, location - range.location - 1)];
                for (BRAtTarget *target in self.atTargets) {
                    if ([sub isEqualToString:target.userId] || [sub isEqualToString:target.nickname]) {
                        inputText = range.location > 0 ? [inputText substringToIndex:range.location] : @"";
                        toolbar.inputTextView.text = inputText;
                        toolbar.inputTextView.selectedRange = NSMakeRange(inputText.length, 0);
                        [self.atTargets removeObject:target];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if ([ext objectForKey:EMOTION_DEFAULT_EXT]) {
        BREmotion *emotion = [ext objectForKey:EMOTION_DEFAULT_EXT];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(emotionExtFormessageViewController:emotion:)]) {
            NSDictionary *ext = [self.dataSource emotionExtFormessageViewController:self emotion:emotion];
            [self sendTextMessage:emotion.emotionTitle withExt:ext];
        } else {
            [self sendTextMessage:emotion.emotionTitle withExt:@{MESSAGE_ATTR_EXPRESSION_ID:emotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)}];
        }
        return;
    }
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}

- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    __weak typeof(self) weakSelf = self;
    [self _canRecordCompletion:^(BRRecordResponse recordResponse) {
        switch (recordResponse) {
            case BRRequestRecord:
                
                break;
            case BRCanRecord:
            {
                if ([weakSelf.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
                    [weakSelf.delegate messageViewController:self didSelectRecordView:recordView withEvenType:BRRecordViewTypeTouchDown];
                } else {
                    if ([weakSelf.recordView isKindOfClass:[BRRecordView class]]) {
                        [(BRRecordView *)weakSelf.recordView recordButtonTouchDown];
                    }
                }
                _isRecording = YES;
                BRRecordView *tmpView = (BRRecordView *)recordView;
                tmpView.center = self.view.center;
                [weakSelf.view addSubview:tmpView];
                [weakSelf.view bringSubviewToFront:recordView];
                int x = arc4random() % 100000;
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
                
                [[BRCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
                 {
                     if (error) {
                         NSLog(@"%@",NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
                         _isRecording = NO;
                     }
                 }];
                
            }
                break;
            case BRCanNotRecord:
            {
                [self showAuthorizationAlertWithType:@"microphone"];
            }
                break;
            default:
                break;
        }
    }];
}


- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    if(_isRecording) {
        [[BRCDDeviceManager sharedInstance] cancelCurrentRecording];
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:BRRecordViewTypeTouchUpOutside];
        } else {
            if ([self.recordView isKindOfClass:[BRRecordView class]]) {
                [(BRRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
        
        _isRecording = NO;
    }
}

- (void)didFinishRecordingVoiceAction:(UIView *)recordView
{
    if (_isRecording) {
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:BRRecordViewTypeTouchUpInside];
        } else {
            if ([self.recordView isKindOfClass:[BRRecordView class]]) {
                [(BRRecordView *)self.recordView recordButtonTouchUpInside];
            }
            [self.recordView removeFromSuperview];
        }
        __weak typeof(self) weakSelf = self;
        [[BRCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            if (!error) {
                [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
            }
            else {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.label.text = error.domain;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            }
        }];
        _isRecording = NO;
    }
}

- (void)didDragInsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:BRRecordViewTypeDragInside];
    } else {
        if ([self.recordView isKindOfClass:[BRRecordView class]]) {
            [(BRRecordView *)self.recordView recordButtonDragInside];
        }
    }
}

- (void)didDragOutsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:BRRecordViewTypeDragOutside];
    } else {
        if ([self.recordView isKindOfClass:[BRRecordView class]]) {
            [(BRRecordView *)self.recordView recordButtonDragOutside];
        }
    }
}

#pragma mark - BRChatBarMoreViewDelegate

- (void)moreView:(BRChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectMoreView:AtIndex:)]) {
        [self.delegate messageViewController:self didSelectMoreView:moreView AtIndex:index];
        return;
    }
}

- (void)moreViewPhotoAction:(BRChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        void (^authorizedBlock)(void) = ^() {
            // Pop image picker
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
            
            self.isViewDidAppear = NO;
            [[BRSDKHelper shareHelper] setIsShowingimagePicker:YES];
        };
        
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                        authorizedBlock();
                        break;
                        
                    case PHAuthorizationStatusDenied:
                        break;
                        
                    default:
                        break;
                }
            }];
        }
        else if (authStatus == PHAuthorizationStatusAuthorized) {
            authorizedBlock();
        }
    }
}

- (void)moreViewTakePicAction:(BRChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        void (^authorizedBlock)(void) = ^() {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
            
            self.isViewDidAppear = NO;
            [[BRSDKHelper shareHelper] setIsShowingimagePicker:YES];
        };
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    authorizedBlock();
                }
            }];
        }
        else if (authStatus == AVAuthorizationStatusAuthorized) {
            authorizedBlock();
        }
    }
}

- (void)moreViewLocationAction:(BRChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self showAuthorizationAlertWithType:@"GPS"];
    } else {
        BRLocationViewController *locationController = [[BRLocationViewController alloc] init];
        locationController.delegate = self;
        [self.navigationController pushViewController:locationController animated:YES];
    }
   
}

- (void)moreViewAudioCallAction:(BRChatBarMoreView *)moreView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Prompt", nil) message:NSLocalizedString(@"The function is in the process of development", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
}

- (void)moreViewVideoCallAction:(BRChatBarMoreView *)moreView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Prompt", nil) message:NSLocalizedString(@"The function is in the process of development", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
}

#pragma mark - EMLocationViewDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - Hyphenate

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self addMessageToDataSource:message progress:nil];
            
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"receiveCmd", @"receive cmd message");
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block id<IMessageModel> model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj conformsToProtocol:@protocol(IMessageModel)])
             {
                 model = (id<IMessageModel>)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave){
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
            [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError;
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error{
    if (!error) {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVideo){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVoice){
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[BRCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    NSMutableSet *usernameSet = [NSMutableSet set];
    for (EMMessage *message in messages) {
        //Calculate time interval
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:stringForDate:)]) {
                timeStr = [_dataSource messageViewController:self stringForDate:messageDate];
            }
            else{
                timeStr = [messageDate formattedTime];
            }
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //Construct message model
        BRMessageModel *model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[BRMessageModel alloc] initWithMessage:message];
            model.failImageName = @"imageDownloadFail";
        }
        
        if (model) {
            if (self.friendsInfo == nil) {
                self.friendsInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:model.message.from];
            }
            // 发送方
            if (model.isSender) {
                UIImage *avatar = [UIImage imageWithData:self.userInfo.avatar];
                model.avatarImage = avatar ? avatar : [UIImage imageNamed:@"user_default"];
                model.username = self.userInfo.nickname.length ? self.userInfo.nickname : self.userInfo.username;
            }
            // 非发送方单聊
            else if (_conversation.type == EMConversationTypeChat) {
                UIImage *avatar = [UIImage imageWithData:self.friendsInfo.avatar];
                model.avatarImage = avatar ? avatar : [UIImage imageNamed:@"user_default"];
                model.username = self.friendsInfo.nickname.length ? self.friendsInfo.nickname : self.friendsInfo.username;
            }
            // 非发送方群聊
            else {
                BRContactListModel *userModel = nil;
                if ((userModel = self.dict[model.username])) {
                    model.avatarImage = userModel.avatarImage;
                    model.username = userModel.nickname ? userModel.nickname : userModel.username;
                }
                else {
                    // 从数据库中获取成员信息
                    
                    BRFriendsInfo *info = [[[BRCoreDataManager sharedInstance] fetchGroupMembersByGroupID:_conversation.conversationId andGroupMemberUserNameArray:[NSArray arrayWithObject:model.username]] firstObject];
//                    BRFriendsInfo *info = [[[BRCoreDataManager sharedInstance] fetchGroupMembersByGroupID:_conversation.conversationId andGroupMemberUserName:model.username] firstObject];
                    if (info) {
                        model.username = info.nickname ? info.nickname : info.username;
                        UIImage *avatarImage = [UIImage imageWithData:info.avatar];
                        model.avatarImage = avatarImage;
                        
                        userModel = [[BRContactListModel alloc] init];
                        userModel.username = info.username;
                        userModel.nickname = info.nickname;
                        userModel.avatarImage = avatarImage;
                        self.dict[info.username] = userModel;
                    }
                    else {
                        model.avatarImage = [UIImage imageNamed:@"user_default"];
                        [usernameSet addObject:model.username];
                    }
                }
            }
            
            [formattedArray addObject:model];
        }
    }
    
    if (_conversation.type == EMConversationTypeGroupChat && usernameSet.count > 0) {
        NSArray *usernameArray = [usernameSet allObjects];
        
        // 从服务器获取成员信息
        [[BRClientManager sharedManager] getUserInfoWithUsernames:usernameArray andSaveFlag:NO success:^(NSMutableArray *modelArray) {
            for (BRContactListModel *userModel in modelArray) {
                self.dict[userModel.username] = userModel;
            }
            [[BRCoreDataManager sharedInstance] saveGroupMembersToCoreData:modelArray toGroup:_conversation.conversationId];
            for (id obj in self.dataArray) {
                if (![obj isKindOfClass:[BRMessageModel class]]) {
                    continue;
                }
                BRMessageModel *messageModel = (BRMessageModel *)obj;
                BRContactListModel *userModel = self.dict[messageModel.username];
                if (userModel) {
                    messageModel.username = userModel.nickname ? userModel.nickname : userModel.username;
                    messageModel.avatarURLPath = userModel.avatarURLPath;
                    messageModel.avatarImage = userModel.avatarImage;
                }
            }
            [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
        } failure:nil];
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    [self.messsagesSource addObject:message];
    
    __weak BRMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - public
- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0) {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
}

#pragma mark - send message

- (void)_refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime) {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = self.messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]]) {
            
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound) {
                [self.messsagesSource removeObjectAtIndex:index];
                [self.messsagesSource addObject:aMessage];
                
                //格式化消息
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:formattedMessages];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                return;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)sendMessage:(EMMessage *)message
    isNeedUploadFile:(BOOL)isUploadFile
{
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom){
        message.chatType = EMChatTypeChatRoom;
    }
    
    BRCoreDataManager *manager = [BRCoreDataManager sharedInstance];
    [manager insertConversationToCoreData:message];
    
    __weak typeof(self) weakself = self;
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && isUploadFile) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"message.autoTransfer", @"Please customize the transfer attachment method") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self addMessageToDataSource:message
                            progress:nil];
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
                [weakself.dataSource messageViewController:weakself updateProgress:progress messageModel:nil messageBody:message.body];
            }
        } completion:^(EMMessage *aMessage, EMError *aError) {
            if (!aError) {
                [weakself _refreshAfterSentMessage:aMessage];
            }
            else {
                [weakself.tableView reloadData];
            }
        }];
    }
}

- (void)sendTextMessage:(NSString *)text
{
    NSDictionary *ext = nil;
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSArray *targets = [self _searchAtTargets:text];
        if ([targets count]) {
            __block BOOL atAll = NO;
            [targets enumerateObjectsUsingBlock:^(NSString *target, NSUInteger idx, BOOL *stop) {
                if ([target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    atAll = YES;
                    *stop = YES;
                }
            }];
            if (atAll) {
                ext = @{kGroupMessageAtList: kGroupMessageAtAll};
            }
            else {
                ext = @{kGroupMessageAtList: targets};
            }
        }
    }
    [self sendTextMessage:text withExt:ext];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [BRSDKHelper getTextMessage:text to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:ext];
    [self sendMessage:message isNeedUploadFile:NO];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [BRSDKHelper getLocationMessageWithLatitude:latitude longitude:longitude address:address to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:NO];
}

- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [BRSDKHelper getImageMessageWithImageData:imageData to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [BRSDKHelper getImageMessageWithImage:image to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVoice];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [BRSDKHelper getVoiceMessageWithLocalPath:localPath duration:duration to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVideo];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [BRSDKHelper getVideoMessageWithURL:url to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendFileMessageWith:(EMMessage *)message {
    [self sendMessage:message isNeedUploadFile:YES];
}

#pragma mark - notification
- (void)didBecomeActive
{
    self.messageTimeIntervalTag = -1;
    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
    [self.tableView reloadData];
    
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:nil];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewControllerMarkAllMessagesAsRead:)]) {
            [self.dataSource messageViewControllerMarkAllMessagesAsRead:self];
        }
    }
}

- (void)hideImagePicker
{
    if (_imagePicker && [BRSDKHelper shareHelper].isShowingimagePicker) {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - private
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message
{
    if ([self.conversation.conversationId isEqualToString:message.conversationId])
    {
        for (int i = 0; i < self.dataArray.count; i ++) {
            id object = [self.dataArray objectAtIndex:i];
            if ([object isKindOfClass:[BRMessageModel class]]) {
                id<IMessageModel> model = object;
                if ([message.messageId isEqualToString:model.messageId]) {
                    id<IMessageModel> model = nil;
                    if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                        model = [self.dataSource messageViewController:self modelForMessage:message];
                    }
                    else{
                        model = [[BRMessageModel alloc] initWithMessage:message];
                        model.avatarImage = [UIImage imageNamed:@"user_default"];
                        model.failImageName = @"imageDownloadFail";
                    }
                    
                    [self.tableView beginUpdates];
                    [self.dataArray replaceObjectAtIndex:i withObject:model];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting) {
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:aMessage];
        }
        else{
            model = [[BRMessageModel alloc] initWithMessage:aMessage];
            model.avatarImage = [UIImage imageNamed:@"user_default"];
            model.failImageName = @"imageDownloadFail";
        }
        if (model) {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(BRMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                    if ([aMessage.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (index != NSNotFound)
            {
                [self.dataArray replaceObjectAtIndex:index withObject:model];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

- (NSArray*)_searchAtTargets:(NSString*)text
{
    NSMutableArray *targets = nil;
    if (text.length > 1) {
        targets = [NSMutableArray array];
        NSArray *splits = [text componentsSeparatedByString:@"@"];
        if ([splits count]) {
            for (NSString *split in splits) {
                if (split.length) {
                    NSString *atALl = NSLocalizedString(@"group.atAll", @"all");
                    if (split.length >= atALl.length && [split compare:atALl options:NSCaseInsensitiveSearch range:NSMakeRange(0, atALl.length)] == NSOrderedSame) {
                        [targets removeAllObjects];
                        [targets addObject:kGroupMessageAtAll];
                        return targets;
                    }
                    for (BRAtTarget *target in self.atTargets) {
                        if ([target.userId length]) {
                            if ([split hasPrefix:target.userId] || (target.nickname && [split hasPrefix:target.nickname])) {
                                [targets addObject:target.userId];
                                [self.atTargets removeObject:target];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return targets;
}


/**
 提示开启权限设置
 */
- (void)showAuthorizationAlertWithType:(NSString *)type
{
    NSString *title = [@"Unable to access " stringByAppendingString:type];
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *open = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleDestructive handler:nil];
    
    [actionSheet addAction:open];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
