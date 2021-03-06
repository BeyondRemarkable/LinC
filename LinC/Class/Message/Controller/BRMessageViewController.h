//
//  BRMessageViewController.h
//  LinC
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRRefreshTableViewController.h"
#import "IMessageModel.h"
#import "BRMessageModel.h"
#import "BRBaseMessageCell.h"
#import "BRChatToolbar.h"
#import "BRSDKHelper.h"
#import "BRCDDeviceManagerDelegate.h"
#import "BRLocationViewController.h"

@interface BRAtTarget : NSObject
@property (nonatomic, copy) NSString    *userId;
@property (nonatomic, copy) NSString    *nickname;

- (instancetype)initWithUserId:(NSString*)userId andNickname:(NSString*)nickname;
@end

typedef void(^BRSelectAtTargetCallback)(BRAtTarget*);

@class BRMessageViewController;

@protocol BRMessageViewControllerDelegate <NSObject>

@optional

/*!
 @method
 @brief 获取消息自定义cell
 @discussion 用户根据messageModel判断是否显示自定义cell,返回nil显示默认cell,否则显示用户自定义cell
 @param tableView 当前消息视图的tableView
 @param messageModel 消息模型
 @result 返回用户自定义cell
 */
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 获取消息cell高度
 @discussion 用户根据messageModel判断,是否自定义显示cell的高度
 @param viewController 当前消息视图
 @param messageModel 消息模型
 @param cellWidth 视图宽度
 @result 返回用户自定义cell
 */
- (CGFloat)messageViewController:(BRMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth;

/*!
 @method
 @brief 接收到消息的已读回执
 @discussion 接收到消息的已读回执的回调,用户可以自定义处理
 @param viewController 当前消息视图
 @param messageModel 消息模型
 */
- (void)messageViewController:(BRMessageViewController *)viewController
 didReceiveHasReadAckForModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 选中消息
 @discussion 选中消息的回调,用户可以自定义处理
 @param viewController 当前消息视图
 @param messageModel 消息模型
 @result BOOL
 */
- (BOOL)messageViewController:(BRMessageViewController *)viewController
        didSelectMessageModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 点击消息头像
 @discussion 获取用户点击头像回调
 @param viewController 当前消息视图
 @param messageModel 消息模型
 */
- (void)messageViewController:(BRMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 选中底部功能按钮
 @discussion 消息发送成功的回调,用户可以自定义处理
 @param viewController 当前消息视图
 @param moreView 更多视图
 @param index 选中底部功能按钮索引
 */
- (void)messageViewController:(BRMessageViewController *)viewController
            didSelectMoreView:(BRChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index;

/*!
 @method
 @brief 底部录音功能按钮状态回调
 @discussion 获取底部录音功能按钮状态回调,根据BRRecordViewType,用户自定义处理UI的逻辑
 @param viewController 当前消息视图
 @param recordView 录音视图
 @param type 录音按钮当前状态
 */
- (void)messageViewController:(BRMessageViewController *)viewController
          didSelectRecordView:(UIView *)recordView
                 withEvenType:(BRRecordViewType)type;

/*!
 @method
 @brief 获取要@的对象
 @discussion 用户输入了@，选择要@的对象
 @param selectedCallback 用于回调要@的对象的block
 */
- (void)messageViewController:(BRMessageViewController *)viewController
               selectAtTarget:(BRSelectAtTargetCallback)selectedCallback;

@end


@protocol BRMessageViewControllerDataSource <NSObject>

@optional

/*!
 @method
 @brief 指定消息附件上传或者下载进度的监听者,默认self
 @param viewController 当前消息视图
 @param messageBodyType 消息体类型
 */
- (id)messageViewController:(BRMessageViewController *)viewController
progressDelegateForMessageBodyType:(EMMessageBodyType)messageBodyType;

/*!
 @method
 @brief 附件进度有更新
 @param viewController 当前消息视图
 @param progress 进度
 @param messageModel 消息模型
 @param messageBody 消息体
 */
- (void)messageViewController:(BRMessageViewController *)viewController
               updateProgress:(float)progress
                 messageModel:(id<IMessageModel>)messageModel
                  messageBody:(EMMessageBody*)messageBody;

/*!
 @method
 @brief 消息时间间隔描述
 @param viewController 当前消息视图
 @param date 时间
 @result 返回消息时间描述
 */
- (NSString *)messageViewController:(BRMessageViewController *)viewController
                      stringForDate:(NSDate *)date;

/*!
 @method
 @brief 将EMMessage类型转换为符合<IMessageModel>协议的类型
 @discussion 将EMMessage类型转换为符合<IMessageModel>协议的类型,设置用户信息,消息显示用户昵称和头像
 @param viewController 当前消息视图
 @param message 聊天消息对象类型
 @result 返回<IMessageModel>协议的类型
 */
- (id<IMessageModel>)messageViewController:(BRMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message;

/*!
 @method
 @brief 是否允许长按
 @discussion 获取是否允许长按的回调,默认是NO
 @param viewController 当前消息视图
 @param indexPath 长按消息对应的indexPath
 @result BOOL
 */
- (BOOL)messageViewController:(BRMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/*!
 @method
 @brief 触发长按手势
 @discussion 获取触发长按手势的回调,默认是NO
 @param viewController 当前消息视图
 @param indexPath 长按消息对应的indexPath
 @result BOOL
 */
- (BOOL)messageViewController:(BRMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/*!
 @method
 @brief 是否标记为已读
 @discussion 是否标记为已读的回调
 @param viewController 当前消息视图
 @result BOOL
 */
- (BOOL)messageViewControllerShouldMarkMessagesAsRead:(BRMessageViewController *)viewController;

/*!
 @method
 @brief 是否发送已读回执
 @param viewController 当前消息视图
 @param message 要发送已读回执的message
 @param read message是否已读
 @result BOOL
 */
- (BOOL)messageViewController:(BRMessageViewController *)viewController
shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read;

/*!
 @method
 @brief 判断消息是否为表情消息
 @param viewController 当前消息视图
 @param messageModel 消息模型
 */
- (BOOL)isEmotionMessageFormessageViewController:(BRMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 根据消息获取表情信息
 @param viewController 当前消息视图
 @param messageModel 消息模型
 */
- (BREmotion*)emotionURLFormessageViewController:(BRMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel;

/*!
 @method
 @brief 获取表情列表
 @param viewController 当前消息视图
 @result 表情数组
 */
- (NSArray*)emotionFormessageViewController:(BRMessageViewController *)viewController;

/*!
 @method
 @brief 获取发送表情消息的扩展字段
 @param viewController 当前消息视图
 @param emotion 表情
 @result 表情扩展字典
 */
- (NSDictionary*)emotionExtFormessageViewController:(BRMessageViewController *)viewController
                                        emotion:(BREmotion*)emotion;

/*!
 @method
 @brief view标记已读
 @param viewController 当前消息视图
 */
- (void)messageViewControllerMarkAllMessagesAsRead:(BRMessageViewController *)viewController;

@end

@interface BRMessageViewController : BRRefreshTableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMChatManagerDelegate, BRCDDeviceManagerDelegate, BRChatToolbarDelegate, BRChatBarMoreViewDelegate, BRLocationViewDelegate,EMChatroomManagerDelegate, BRMessageCellDelegate>


@property (weak, nonatomic) id<BRMessageViewControllerDelegate> delegate;

@property (weak, nonatomic) id<BRMessageViewControllerDataSource> dataSource;

/*!
 @property
 @brief 聊天的会话对象
 */
@property (strong, nonatomic) EMConversation *conversation;

/*!
 @property
 @brief 时间间隔标记
 */
@property (nonatomic) NSTimeInterval messageTimeIntervalTag;

/*!
 @property
 @brief 如果conversation中没有任何消息，退出该页面时是否删除该conversation
 */
@property (nonatomic) BOOL deleteConversationIfNull; //default YES;

/*!
 @property
 @brief 当前页面显示时，是否滚动到最后一条
 */
@property (nonatomic) BOOL scrollToBottomWhenAppear; //default YES;

/*!
 @property
 @brief 页面是否处于显示状态
 */
@property (nonatomic) BOOL isViewDidAppear;

/*!
 @property
 @brief 加载的每页message的条数
 */
@property (nonatomic) NSInteger messageCountOfPage; //default 50

/*!
 @property
 @brief 时间分割cell的高度
 */
@property (nonatomic) CGFloat timeCellHeight;

/*!
 @property
 @brief 显示的EMMessage类型的消息列表
 */
@property (strong, nonatomic) NSMutableArray *messsagesSource;

/*!
 @property
 @brief 底部输入控件
 */
@property (strong, nonatomic) UIView *chatToolbar;

/*!
 @property
 @brief 底部功能控件
 */
@property(strong, nonatomic) BRChatBarMoreView *chatBarMoreView;

/*!
 @property
 @brief 底部表情控件
 */
@property(strong, nonatomic) BRFaceView *faceView;

/*!
 @property
 @brief 底部录音控件
 */
@property(strong, nonatomic) BRRecordView *recordView;

/*!
 @property
 @brief 菜单(消息复制,删除)
 */
@property (strong, nonatomic) UIMenuController *menuController;

/*!
 @property
 @brief 选中消息菜单索引
 */
@property (strong, nonatomic) NSIndexPath *menuIndexPath;

/*!
 @property
 @brief 图片选择器
 */
@property (strong, nonatomic) UIImagePickerController *imagePicker;

/*!
 @property
 @brief 是否已经加入聊天室
 */
@property (nonatomic) BOOL isJoinedChatroom;

/*!
 @method
 @brief 初始化聊天页面
 @param conversationChatter 会话对方的用户名. 如果是群聊, 则是群组的id
 @param conversationType 会话类型
 */
- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType;

/*!
 @method
 @brief 下拉加载更多
 */
- (void)tableViewDidTriggerHeaderRefresh;

/*!
 @method
 @brief 发送文本消息
 @param text 文本消息
 */
- (void)sendTextMessage:(NSString *)text;

/*!
 @method
 @brief 发送文本消息
 @param text 文本消息
 @param ext  扩展信息
 */
- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext;

/*!
 @method
 @brief 发送图片消息
 @param image 发送图片
 */
- (void)sendImageMessage:(UIImage *)image;

/*!
 @method
 @brief 发送位置消息
 @param latitude 经度
 @param longitude 纬度
 @param address 地址
 */
- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address;

/*!
 @method
 @brief 发送语音消息
 @param localPath 语音本地地址
 @param duration 时长
 */
- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration;

/*!
 @method
 @brief 发送视频消息
 @param url 视频url
 */
- (void)sendVideoMessageWithURL:(NSURL *)url;

/*!
 @method
 @brief 发送视频消息
 @param message 聊天消息类
 */
- (void)sendFileMessageWith:(EMMessage *)message;


/*!
 @method
 @brief 添加消息
 @param message 聊天消息类
 @param progress 聊天消息发送接收进度条
 */
- (void)addMessageToDataSource:(EMMessage *)message
                      progress:(id)progress;

/*!
 @method
 @brief 显示消息长按菜单
 @param showInView  菜单的父视图
 @param indexPath 索引
 @param messageType 消息类型
 */
- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType;

/*!
 @method
 @brief 判断消息是否要发送已读回执
 @param message 聊天消息
 @param read    是否附件消息已读
 */
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read;

@end
