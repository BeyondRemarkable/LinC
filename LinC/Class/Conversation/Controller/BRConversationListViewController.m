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

@interface BRConversationListViewController () <EMClientDelegate>

@property (nonatomic, strong) BRDropDownViewController *dropDownVC;

@end

@implementation BRConversationListViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"BRConversationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BRConversationCell cellIdentifierWithModel:nil]];

    [self setUpNavigationBarItem];
    
    self.navigationItem.title = @"LinC";
    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//- (void)setUpNavigationBar {
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action: @selector(dropdownMenu)];
//}

- (void)setUpNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"add_setting_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickAddDropdownMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)chatBtnTapped:(UIButton *)sender {
    [self.dropDownVC.view removeFromSuperview];
    self.dropDownVC = nil;
    
    BRCreateChatViewController *vc = [[BRCreateChatViewController alloc] initWithStyle:UITableViewStylePlain];
    BRNavigationController *naviVc = [[BRNavigationController alloc] initWithRootViewController:vc];
    [vc setDismissCompletionBlock:^(UIViewController *vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self presentViewController:naviVc animated:YES completion:nil];
}

- (void)scanQRCodeBtnTapped:(UIButton *)sender {
    [self.dropDownVC.view removeFromSuperview];
    self.dropDownVC = nil;
    BRScannerViewController *vc = [[BRScannerViewController alloc] initWithNibName:@"BRScannerViewController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)clickAddDropdownMenu {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (!self.dropDownVC) {
        self.dropDownVC = [[BRDropDownViewController alloc] initWithNibName:@"BRDropDownViewController" bundle:nil];
        UIView *dropDownMenuView = self.dropDownVC.view;
        [self.dropDownVC.chatButton addTarget:self action:@selector(chatBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.dropDownVC.scanQRCodeButton addTarget:self action:@selector(scanQRCodeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
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
        BRConversationModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:nil];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - data

/*!
 @method
 @brief 加载会话列表
 */
//- (void)tableViewDidTriggerHeaderRefresh
//{
//
//    NSArray *sorted =  [[EMClient sharedClient].chatManager getAllConversations];
//
//    NSArray *brConversationsArray = [[BRCoreDataManager sharedInstance] fetchConversations];
//
//    NSMutableArray *sorted = [NSMutableArray array];
//    NSMutableArray *conversationArray = [NSMutableArray array];
//    NSMutableArray *iconArray = [NSMutableArray array];
//
//    for (BRConversation *conversation in brConversationsArray) {
//        EMConversation *emConversation = [[EMClient sharedClient].chatManager getConversation:conversation.conversationId type:conversation.chatType createIfNotExist:NO];
//        BRFriendsInfo *friendInfo = [[BRCoreDataManager sharedInstance] fetchFriendInfoBy:conversation.conversationId];
//        UIImage *image = [UIImage imageWithData:friendInfo.avatar];
//        if (image) {
//            [iconArray addObject: image];
//        }
//        if (emConversation) {
//             [conversationArray addObject:emConversation];
//        }
//
//    }
//
//    for (NSUInteger i = 0; i < conversationArray.count; i++) {
//        EMConversation *conversation = [conversationArray objectAtIndex:i];
//        BRConversationModel *model = [[BRConversationModel alloc] initWithConversation:conversation];
//
//        if (i < iconArray.count) {
//            model.avatarImage =  [iconArray objectAtIndex:i];
//        }
//        if (model) {
//            [sorted addObject:model];
//        }
//    }
//
//    [sorted sortedArrayUsingComparator:
//    ^(BRConversationModel *obj1, BRConversationModel* obj2){
//        EMMessage *message1 = [obj1.conversation latestMessage];
//        EMMessage *message2 = [obj2.conversation latestMessage];
//        if(message1.timestamp > message2.timestamp) {
//            return(NSComparisonResult)NSOrderedAscending;
//        }else {
//            return(NSComparisonResult)NSOrderedDescending;
//        }
//    }];
//    [self.dataArray removeAllObjects];
//    self.dataArray = [sorted copy];
//
//    [self.tableView reloadData];
//    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
//}

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
    for (EMConversation *converstion in sorted) {
        BRConversationModel *model = [[BRConversationModel alloc] initWithConversation:converstion];
        
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    
    [self.tableView reloadData];
    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
}

#pragma mark - EMGroupManagerDelegate

- (void)didUpdateGroupList:(NSArray *)groupList
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - EMCliendDelegate

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
    [self unregisterNotifications];
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
                latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [BRConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
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
//    [[BRCoreDataManager sharedInstance] insertConversationToCoreData: aMessages];
}

@end
