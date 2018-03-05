//
//  BRConversationListViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRConversationListViewController.h"
#import "BRMessageViewController.h"
#import "BRConversationModel.h"
#import "BRConversationCell.h"
#import "BRGroupModel.h"
#import "NSDate+Category.h"
#import "BREmotionEscape.h"
#import "BRConvertToCommonEmoticonsHelper.h"
#import "BRDropDownViewController.h"
#import "BRScannerViewController.h"
#import "BRCreateChatViewController.h"
#import "BRNavigationController.h"
#import "BRClientManager.h"
#import <SAMKeychain.h>
#import "BRCoreDataManager.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRAvatarView.h"
#import <MBProgressHUD.h>
#import "BRFriendInfoTableViewController.h"
#import "BRGroupChatSettingTableViewController.h"

@interface BRConversationListViewController () <EMClientDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MBProgressHUD *hud;
}

@property (nonatomic, strong) BRDropDownViewController *dropDownVC;

@end

@implementation BRConversationListViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
    self.navigationController.navigationBar.hidden = NO;
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in conversations) {
        totalUnreadCount += conversation.unreadMessagesCount;
    }
    if (!totalUnreadCount) {
        self.tabBarItem.badgeValue = nil;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    } else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (long)totalUnreadCount];
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalUnreadCount;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRConversationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BRConversationCell cellIdentifierWithModel:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRefreshMessage) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self registerNotifications];
    [self setUpNavigationBarItem];
    
    self.navigationItem.title = @"LinC";
    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)checkRefreshMessage {
    BOOL hasMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"receivedMessage"];
    if (hasMessage) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)setUpNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickAddDropdownMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)deleteCellAction:(NSIndexPath *)indexPath {
    BRConversationModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:nil];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Action
/**
    点击创建聊天按钮
 */
- (void)chatBtnTapped:(UIButton *)sender {
    [self.dropDownVC.view removeFromSuperview];
    self.dropDownVC = nil;
    
    BRCreateChatViewController *vc = [[BRCreateChatViewController alloc] initWithStyle:UITableViewStylePlain];
    BRNavigationController *naviVc = [[BRNavigationController alloc] initWithRootViewController:vc];
    [vc setDismissViewControllerCompletionBlock:^(UIViewController *vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self presentViewController:naviVc animated:YES completion:nil];
}


/**
    点击扫描按钮
 */
- (void)getQRCodeBtnTapped:(UIButton *)sender {
    [self.dropDownVC.view removeFromSuperview];
    self.dropDownVC = nil;
    
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *scan = [UIAlertAction actionWithTitle:NSLocalizedString(@"Scan from camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self scanQRCodeBtnTapped];
    }];
    UIAlertAction *load = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load from album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self readQRCodeFromAlbum];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:scan];
    [actionSheet addAction:load];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


/**
    点击下拉菜单
 */
- (void)clickAddDropdownMenu {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (!self.dropDownVC) {
        self.dropDownVC = [[BRDropDownViewController alloc] initWithNibName:@"BRDropDownViewController" bundle:nil];
        UIView *dropDownMenuView = self.dropDownVC.view;
        [self.dropDownVC.chatButton addTarget:self action:@selector(chatBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.dropDownVC.scanQRCodeButton addTarget:self action:@selector(getQRCodeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set up drop down menu frame
        CGFloat viewX = 0;
        CGFloat viewY = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat viewWidth = self.view.bounds.size.width;
        CGFloat viewHeigh = self.view.bounds.size.height;
        [self.view addSubview: dropDownMenuView];
        [self addChildViewController:self.dropDownVC];
        [self.dropDownVC didMoveToParentViewController:self];
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            dropDownMenuView.frame = CGRectMake(viewX, viewY, viewWidth, viewHeigh);
        } completion:^(BOOL finished) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    } else {
        UIView *view = self.dropDownVC.view;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            view.frame = CGRectMake(0, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            [self.dropDownVC removeFromParentViewController];
            self.dropDownVC = nil;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    }
}


/**
    点击相机扫描按钮
 */
- (void)scanQRCodeBtnTapped {
    
    BRScannerViewController *vc = [[BRScannerViewController alloc] initWithNibName:@"BRScannerViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.toolbarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)readQRCodeFromAlbum {
    // 判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>

/**
 识别图片中的二维码
 
 @param info 用户选取的图片信息
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *qrImage = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    NSData *imageData = UIImagePNGRepresentation(qrImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    NSArray *features = [detector featuresInImage: ciImage];
    
    if (features.count == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"QR code not found.";
        [hud hideAnimated:YES afterDelay:1.5];
    } else if (features.count > 1) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Multi QR code found.";
        [hud hideAnimated:YES afterDelay:1.5];
    } else {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        [self searchByID:scannedResult];
    }
}

- (void)searchByID:(NSString *)searchID {
    
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    // 不能添加自己
    if ([searchID isEqualToString:currentUsername]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Can not add yourself.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    if ([searchID hasSuffix:@"group"]) {
        searchID = [searchID stringByReplacingOccurrencesOfString:@"group" withString:@""];
        [self searchGroupID:searchID];
    } else if (searchID.length == GroupIDLength) {
        [self searchGroupID:searchID];
    } else {
        [self searchFriendID: searchID];
    }
}

- (void)searchFriendID:(NSString *)friendID {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRClientManager sharedManager] getUserInfoWithUsernames:[NSArray arrayWithObject:friendID] andSaveFlag:NO success:^(NSMutableArray *aList) {
        [hud hideAnimated:YES];
        
        BRContactListModel *model = [aList firstObject];
        UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
        BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier: @"BRFriendInfoTableViewController"];
        vc.contactListModel = model;
        // 如果已经是好友
        NSArray *contactArray = [[EMClient sharedClient].contactManager getContacts];
        if ([contactArray containsObject:friendID]) {
            vc.isFriend = YES;
        }
        else {
            vc.isFriend = NO;
        }
        // Push BRFriendInfoTableViewController
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(EMError *aError) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = aError.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (void)searchGroupID:(NSString *)groupID {
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRGroupChatSettingTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRGroupChatSettingTableViewController"];
    vc.doesJoinGroup = YES;
    vc.groupID = groupID;
    [hud hideAnimated:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.dropDownVC) {
        UIView *view = self.dropDownVC.view;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            view.frame = CGRectMake(0, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
        } completion:^(BOOL finished) {
            [self.dropDownVC.view removeFromSuperview];
            [self.dropDownVC removeFromParentViewController];
            self.dropDownVC = nil;
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [BRConversationCell cellIdentifierWithModel:nil];
    BRConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([self.dataArray count] <= indexPath.row) {
        return cell;
    }
    
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
    cell.model = model;
    cell.showAvatar = YES;
    cell.detailLabel.attributedText =  [[BREmotionEscape sharedInstance] attStringFromTextForChatting:[self _latestMessageTitleForConversationModel:model]textFont:cell.detailLabel.font];
    
    cell.timeLabel.text = [self _latestMessageTimeForConversationModel:model];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BRConversationCell cellHeightWithModel:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BRConversationModel *model = [self.dataArray objectAtIndex:indexPath.row];
    BRMessageViewController *viewController = [[BRMessageViewController alloc] initWithConversationChatter:model.conversation.conversationId conversationType:model.conversation.type];
    
    viewController.title = model.title;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCellAction:indexPath];
    }
}

#pragma mark - data

/*!
 @method
 @brief 加载会话列表
 */
- (void)tableViewDidTriggerHeaderRefresh
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSArray* sorted = [conversations sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    
    [self.dataArray removeAllObjects];
    NSInteger totalUnreadCount = 0;
    
    for (EMConversation *conversation in sorted) {
        BRConversationModel *model = [[BRConversationModel alloc] initWithConversation:conversation];
        if (model) {
            [self.dataArray addObject:model];
        }
        
        totalUnreadCount += conversation.unreadMessagesCount;
    }

    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (long)totalUnreadCount];
    
    [self.tableView reloadData];
    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
}

#pragma mark - EMGroupManagerDelegate

- (void)didUpdateGroupList:(NSArray *)groupList
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    if (aConnectionState == EMConnectionConnected) {
        self.navigationItem.title = @"LinC";
    }
    else {
        self.navigationItem.title = @"Disconnected";
    }
}

#pragma mark - registerNotifications
-(void)registerNotifications{
//    [self unregisterNotifications];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)unregisterNotifications{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - private

/*!
 @method
 @brief 获取会话最近一条消息内容提示
 @param conversationModel  会话model
 @result 返回传入会话model最近一条消息提示
 */
- (NSString *)_latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = NSLocalizedString(@"Image Received", @"[image]");
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [BRConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = NSLocalizedString(@"Voice message", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"Shared location", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"Shared video", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"Shared file", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

/*!
 @method
 @brief 获取会话最近一条消息时间
 @param conversationModel  会话model
 @result 返回传入会话model最近一条消息时间
 */
- (NSString *)_latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

- (void)messagesDidReceive:(NSArray *)aMessages {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(tableViewDidTriggerHeaderRefresh) object:nil];
    for (EMMessage *message in aMessages) {
        if (message.chatType == EMChatTypeGroupChat) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:message.conversationId error:nil];
                BRGroupModel *groupModel = [[BRGroupModel alloc] init];
                groupModel.groupID = group.groupId;
                groupModel.groupDescription = group.description;
                groupModel.groupName = group.subject;
                groupModel.groupOwner = group.owner;
                groupModel.groupMembers = [NSMutableArray arrayWithArray:group.memberList];
                groupModel.groupStyle = group.setting.style;
                
                [[BRCoreDataManager sharedInstance] saveGroupToCoreData:@[groupModel]];
            }];
            [updateOperation addDependency:operation];
            [queue addOperation:operation];
        }
    }
    [[NSOperationQueue mainQueue] addOperation:updateOperation];
}


@end
