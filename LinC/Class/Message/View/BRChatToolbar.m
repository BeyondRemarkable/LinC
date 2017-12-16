//
//  BRChatToolbar.m
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRChatToolbar.h"

#import "BREmoji.h"
#import "BREmotionEscape.h"
#import "BREmotionManager.h"

@interface BRChatToolbar () <UITextViewDelegate, BRFaceDelegate>

@property (nonatomic) CGFloat version;
@property (strong, nonatomic) UIImageView *toolbarBackgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) BOOL isShowButtomView;
@property (strong, nonatomic) UIView *activityButtomView;
@property (strong, nonatomic) UIView *toolbarView;
@property (nonatomic, strong) UIButton *styleButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIButton *emojiButton;
@property (nonatomic) CGFloat previousTextViewContentHeight;//上一次inputTextView的contentSize.height
@property (nonatomic) NSLayoutConstraint *inputViewWidthItemsLeftConstraint;
@property (nonatomic) NSLayoutConstraint *inputViewWidthoutItemsLeftConstraint;

@end

@implementation BRChatToolbar

@synthesize faceView = _faceView;
@synthesize moreView = _moreView;
@synthesize recordView = _recordView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame horizontalPadding:8 verticalPadding:5 inputViewMinHeight:36 inputViewMaxHeight:150 type:BRChatToolbarTypeGroup];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                         type:(BRChatToolbarType)type
{
    self = [self initWithFrame:frame horizontalPadding:8 verticalPadding:5 inputViewMinHeight:36 inputViewMaxHeight:150 type:type];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
            horizontalPadding:(CGFloat)horizontalPadding
              verticalPadding:(CGFloat)verticalPadding
           inputViewMinHeight:(CGFloat)inputViewMinHeight
           inputViewMaxHeight:(CGFloat)inputViewMaxHeight
                         type:(BRChatToolbarType)type
{
    if (frame.size.height < (verticalPadding * 2 + inputViewMinHeight)) {
        frame.size.height = verticalPadding * 2 + inputViewMinHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.accessibilityIdentifier = @"chatbar";
        
        _horizontalPadding = horizontalPadding;
        _verticalPadding = verticalPadding;
        _inputViewMinHeight = inputViewMinHeight;
        _inputViewMaxHeight = inputViewMaxHeight;
        _chatBarType = type;
        
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _activityButtomView = nil;
        _isShowButtomView = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - setup subviews

/*!
 @method
 @brief 加载视图
 */
- (void)_setupSubviews
{
    //backgroundImageView
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.image = [[UIImage imageNamed:@"message_toolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:_backgroundImageView];
    
    //toolbar
    _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
    _toolbarView.backgroundColor = [UIColor clearColor];
    [self addSubview:_toolbarView];
    
    _toolbarBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _toolbarView.frame.size.width, _toolbarView.frame.size.height)];
    _toolbarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
    [_toolbarView addSubview:_toolbarBackgroundImageView];
    
    CGFloat btnX = self.horizontalPadding;
    CGFloat btnY = self.verticalPadding;
    CGFloat btnH = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    CGFloat btnW = btnH;
    //change input type
    _styleButton = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
    _styleButton.accessibilityIdentifier = @"style";
    _styleButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_styleButton setImage:[UIImage imageNamed:@"chatbar_record"] forState:UIControlStateNormal];
    [_styleButton setImage:[UIImage imageNamed:@"chatbar_record_highlighted"] forState:UIControlStateHighlighted];
    [_styleButton setImage:[UIImage imageNamed:@"chatbar_keyboard"] forState:UIControlStateSelected];
    [_styleButton addTarget:self action:@selector(styleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_styleButton];
    
    //emoji
    btnX = self.toolbarView.frame.size.width - btnW * 2 - self.horizontalPadding * 2;
    _emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
    _emojiButton.accessibilityIdentifier = @"emoji";
    _emojiButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji_highlighted"] forState:UIControlStateHighlighted];
    [_emojiButton setImage:[UIImage imageNamed:@"chatbar_keyboard"] forState:UIControlStateSelected];
    [_emojiButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_emojiButton];
    
    //more
    btnX = self.toolbarView.frame.size.width - btnW - self.horizontalPadding;
    _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
    _moreButton.accessibilityIdentifier = @"more";
    _moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_moreButton setImage:[UIImage imageNamed:@"chatbar_more"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"chatBar_more_highlighted"] forState:UIControlStateHighlighted];
    [_moreButton setImage:[UIImage imageNamed:@"chatbar_keyboard"] forState:UIControlStateSelected];
    [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_moreButton];
    
    //input textview
    _inputTextView = [[BRTextView alloc] initWithFrame:CGRectMake(self.horizontalPadding * 2 + btnW, self.verticalPadding, self.frame.size.width - self.horizontalPadding * 5 - btnW * 3, self.frame.size.height - self.verticalPadding * 2)];
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    _inputTextView.scrollEnabled = NO;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self _getTextViewContentH:_inputTextView];
    [_toolbarView addSubview:_inputTextView];
    
    //record
    self.recordButton = [[UIButton alloc] initWithFrame:self.inputTextView.frame];
    self.recordButton.accessibilityIdentifier = @"record";
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"button_border"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"button_border_highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
    [self.recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
    self.recordButton.hidden = YES;
    [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    self.recordButton.hidden = YES;
    [self.toolbarView addSubview:self.recordButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

#pragma mark - getter

- (UIView *)recordView
{
    if (_recordView == nil) {
        _recordView = [[BRRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    
    return _recordView;
}

- (UIView *)faceView
{
    if (_faceView == nil) {
        CGFloat diff = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        _faceView = [[BRFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame) + diff, self.frame.size.width, 180)];
        [(BRFaceView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _faceView;
}

- (UIView *)moreView
{
    if (_moreView == nil) {
        CGFloat diff = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        _moreView = [[BRChatBarMoreView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame) + diff, self.frame.size.width, 220) type:self.chatBarType];
        _moreView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _moreView;
}

#pragma mark - setter

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    if ([self.moreView isKindOfClass:[BRChatBarMoreView class]]) {
        [(BRChatBarMoreView *)_moreView setDelegate:delegate];
    }
}

- (void)setRecordView:(UIView *)recordView
{
    if(_recordView != recordView){
        _recordView = recordView;
    }
}

- (void)setMoreView:(UIView *)moreView
{
    if (_moreView != moreView) {
        _moreView = moreView;
    }
}

- (void)setFaceView:(UIView *)faceView
{
    if (_faceView != faceView) {
        _faceView = faceView;
    }
}

/*!
 @method
 @brief 设置toolBar左侧菜单选项
 @param inputViewLeftItems 左侧选项
 */
- (void)setInputViewLeftItems:(NSArray *)inputViewLeftItems
{
    CGFloat oX = self.horizontalPadding;
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    CGFloat itemWidth = itemHeight;
    CGFloat oY = (self.toolbarView.frame.size.height - itemHeight) / 2.0;
    self.recordButton.frame = CGRectMake(oX, oY, itemWidth, itemHeight);
    [self.toolbarView addSubview:self.recordButton];
    
    oX += (itemWidth + self.horizontalPadding);
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = inputFrame.origin.x - oX;
    inputFrame.origin.x = oX;
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

/*!
 @method
 @brief 设置toolBar右侧菜单选项
 @param inputViewRightItems 右侧选项
 */
- (void)setInputViewRightItems:(NSArray *)inputViewRightItems
{
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    CGFloat itemWidth = itemHeight;
    CGFloat oMaxX = self.toolbarView.frame.size.width - self.horizontalPadding - itemWidth;
    CGFloat oY = (self.toolbarView.frame.size.height - itemHeight) / 2.0;
    self.moreButton.frame = CGRectMake(oMaxX, oY, itemWidth, itemHeight);
    [self.toolbarView addSubview:self.moreButton];
    
    oMaxX -= self.horizontalPadding;
//    self.faceButton.frame = CGRectMake(oMaxX, oY, itemWidth, itemHeight);
//    [self.toolbarView addSubview:self.faceButton];
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = oMaxX - CGRectGetMaxX(inputFrame);
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

#pragma mark - private input view

/*!
 @method
 @brief 获取textView的高度(实际为textView的contentSize的高度)
 @param textView 文本框
 @result content height
 */
- (CGFloat)_getTextViewContentH:(UITextView *)textView
{
    if (self.version >= 7.0)
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

/*!
 @method
 @brief 通过传入的toHeight，跳转toolBar的高度
 @param toHeight 改变为的高度
 */
- (void)_willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < self.inputViewMinHeight) {
        toHeight = self.inputViewMinHeight;
    }
    if (toHeight > self.inputViewMaxHeight) {
        toHeight = self.inputViewMaxHeight;
        self.inputTextView.scrollEnabled = YES;
    }
    else {
        self.inputTextView.scrollEnabled = NO;
    }
    
    if (toHeight == _previousTextViewContentHeight)
    {
        return;
    }
    else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect toolbarRect = self.frame;
        toolbarRect.size.height += changeHeight;
        toolbarRect.origin.y -= changeHeight;
        
        CGRect textViewRect = self.inputTextView.frame;
        textViewRect.size.height += changeHeight;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = toolbarRect;
            self.inputTextView.frame = textViewRect;
        }];
        
//        rect = self.toolbarView.frame;
//        rect.size.height += changeHeight;
//        self.toolbarView.frame = rect;
        
        if (self.version < 7.0) {
            [self.inputTextView setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:YES];
        }
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:)]) {
            [_delegate chatToolbarDidChangeFrameToHeight:self.frame.size.height];
        }
    }
}

#pragma mark - private bottom view

/*!
 @method
 @brief 调整toolBar的高度
 @param bottomHeight 底部菜单的高度
 */
- (void)_willShowToolBarToBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    }
    else{
        self.isShowButtomView = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = toFrame;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:)]) {
        [_delegate chatToolbarDidChangeFrameToHeight:toHeight];
    }
}

/*!
 @method
 @brief 切换菜单视图
 @param bottomView 菜单视图
 */
- (void)_willShowBottomView:(UIView *)bottomView
{
    UIView *activityButtomView = self.activityButtomView;
    if (![activityButtomView isEqual:bottomView]) {
        if (activityButtomView) {
            // 计算activityBottomView的新frame
            CGRect frame = self.activityButtomView.frame;
            frame.origin.y = CGRectGetMaxY(self.frame) + frame.size.height;
            // 隐藏activityBottomView
            [UIView animateWithDuration:0.25 animations:^{
                activityButtomView.frame = frame;
            } completion:^(BOOL finished) {
                [activityButtomView removeFromSuperview];
            }];
        }
        self.activityButtomView = bottomView;
        
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self _willShowToolBarToBottomHeight:bottomHeight];
        
        // 让选择的界面从下面往上出现
        if (bottomView) {
            [self addSubview:bottomView];
            CGRect rect = bottomView.frame;
            rect.origin.y = self.frame.size.height - bottomHeight;
            [UIView animateWithDuration:0.25 animations:^{
                bottomView.frame = rect;
            }];
        }
        
    }
}

- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self _willShowToolBarToBottomHeight:toFrame.size.height - iPhoneX_BOTTOM_HEIGHT];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self _willShowToolBarToBottomHeight:0];
    }
    else{
        [self _willShowToolBarToBottomHeight:toFrame.size.height - iPhoneX_BOTTOM_HEIGHT];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    self.recordButton.selected = NO;
    [self.recordButton setImage:[UIImage imageNamed:@"chatbar_record_highlighted"] forState:UIControlStateHighlighted];
    self.emojiButton.selected = NO;
    [self.emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji_highlighted"] forState:UIControlStateHighlighted];
    self.moreButton.selected = NO;
    [self.moreButton setImage:[UIImage imageNamed:@"chatbar_more_highlighted"] forState:UIControlStateHighlighted];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.inputTextView.text = @"";
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    else if ([text isEqualToString:@"@"]) {
        if ([self.delegate respondsToSelector:@selector(didInputAtInLocation:)]) {
            if ([self.delegate didInputAtInLocation:range.location]) {
                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
                return NO;
            }
        }
    }
    else if ([text length] == 0) {
        //delete one character
        if (range.length == 1 && [self.delegate respondsToSelector:@selector(didDeleteCharacterFromLocation:)]) {
            return ![self.delegate didDeleteCharacterFromLocation:range.location];
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView]];
}

#pragma mark - DXFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.inputTextView.text;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputTextView.attributedText];
    
    if (!isDelete && str.length > 0) {
        if (self.version >= 7.0) {
            NSRange range = [self.inputTextView selectedRange];
            [attr insertAttributedString:[[BREmotionEscape sharedInstance] attStringFromTextForInputView:str textFont:self.inputTextView.font] atIndex:range.location];
            self.inputTextView.attributedText = attr;
        } else {
            self.inputTextView.text = @"";
            self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
        }
    }
    else {
        if (self.version >= 7.0) {
            if (chatText.length > 0) {
                NSInteger length = 1;
                if (chatText.length >= 2) {
                    NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                    if ([BREmoji stringContainsEmoji:subStr]) {
                        length = 2;
                    }
                }
                self.inputTextView.attributedText = [self backspaceText:attr length:length];
            }
        } else {
            if (chatText.length >= 2)
            {
                NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                if ([(BRFaceView *)self.faceView stringIsFace:subStr]) {
                    self.inputTextView.text = [chatText substringToIndex:chatText.length-2];
                    [self textViewDidChange:self.inputTextView];
                    return;
                }
            }
            
            if (chatText.length > 0) {
                self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
            }
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}

/*!
 @method
 @brief 删除文本光标前长度为length的字符串
 @param attr   待修改的富文本
 @param length 字符串长度
 @result   修改后的富文本
 */
-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            
            if (![_inputTextView.text isEqualToString:@""]) {
                
                //转义回来
                NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.inputTextView.attributedText.string];
                [_inputTextView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                          inRange:NSMakeRange(0, self.inputTextView.attributedText.length)
                                                          options:NSAttributedStringEnumerationReverse
                                                       usingBlock:^(id value, NSRange range, BOOL *stop)
                 {
                     if (value) {
                         BRTextAttachment* attachment = (BRTextAttachment*)value;
                         NSString *str = [NSString stringWithFormat:@"%@",attachment.imageName];
                         [attStr replaceCharactersInRange:range withString:str];
                     }
                 }];
                [self.delegate didSendText:attStr];
                self.inputTextView.text = @"";
                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];;
            }
        }
    }
}

- (void)sendFaceWithEmotion:(BREmotion *)emotion
{
    if (emotion) {
        if ([self.delegate respondsToSelector:@selector(didSendText:withExt:)]) {
            [self.delegate didSendText:emotion.emotionTitle withExt:@{EMOTION_DEFAULT_EXT:emotion}];
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];;
        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)(void) = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}

#pragma mark - action

- (void)styleButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        [button setImage:[UIImage imageNamed:@"chatbar_keyboard_highlighted"] forState:UIControlStateHighlighted];
        
        self.emojiButton.selected = NO;
        [self.emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji_highlighted"] forState:UIControlStateHighlighted];
        self.moreButton.selected = NO;
        [self.moreButton setImage:[UIImage imageNamed:@"chatbar_more_highlighted"] forState:UIControlStateHighlighted];
        
        [self _willShowBottomView:nil];
        
        self.inputTextView.text = @"";
        [self textViewDidChange:self.inputTextView];
        [self.inputTextView resignFirstResponder];
    }
    else{
        [self.inputTextView becomeFirstResponder];
    }
    
    self.recordButton.hidden = !button.selected;
    self.inputTextView.hidden = button.selected;
}

- (void)faceButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (button.selected) {
        [self.inputTextView resignFirstResponder];
        
        [button setImage:[UIImage imageNamed:@"chatbar_keyboard_highlighted"] forState:UIControlStateHighlighted];
        
        self.styleButton.selected = NO;
        [self.styleButton setImage:[UIImage imageNamed:@"chatbar_record_highlighted"] forState:UIControlStateHighlighted];
        self.moreButton.selected = NO;
        [self.moreButton setImage:[UIImage imageNamed:@"chatbar_more_highlighted"] forState:UIControlStateHighlighted];
        
        [self _willShowBottomView:self.faceView];
        
        self.recordButton.hidden = button.selected;
        self.inputTextView.hidden = !button.selected;
    } else {
        [self _willShowBottomView:nil];
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)moreButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (button.selected) {
        [self.inputTextView resignFirstResponder];
        
        [button setImage:[UIImage imageNamed:@"chatbar_keyboard_highlighted"] forState:UIControlStateHighlighted];
        
        self.styleButton.selected = NO;
        [self.styleButton setImage:[UIImage imageNamed:@"chatbar_record_highlighted"] forState:UIControlStateHighlighted];
        self.emojiButton.selected = NO;
        [self.emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji_highlighted"] forState:UIControlStateHighlighted];
        
        [self _willShowBottomView:self.moreView];
        
        self.recordButton.hidden = button.selected;
        self.inputTextView.hidden = !button.selected;
    }
    else
    {
        [self _willShowBottomView:nil];
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)recordButtonTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpInside
{
    self.recordButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(didFinishRecordingVoiceAction:)])
    {
        [self.delegate didFinishRecordingVoiceAction:self.recordView];
    }
    self.recordButton.enabled = YES;
}

- (void)recordDragOutside
{
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside
{
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

#pragma mark - public

+ (CGFloat)defaultHeight
{
    return 5 * 2 + 36;
}

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    self.recordButton.selected = NO;
    [self.recordButton setImage:[UIImage imageNamed:@"chatbar_record_highlighted"] forState:UIControlStateHighlighted];
    self.emojiButton.selected = NO;
    [self.emojiButton setImage:[UIImage imageNamed:@"chatbar_emoji_highlighted"] forState:UIControlStateHighlighted];
    self.moreButton.selected = NO;
    [self.moreButton setImage:[UIImage imageNamed:@"chatbar_more_highlighted"] forState:UIControlStateHighlighted];
    
    [self _willShowBottomView:nil];
    
    return result;
}

- (void)cancelTouchRecord
{
    if ([_recordView isKindOfClass:[BRRecordView class]]) {
        [(BRRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    [self _willShowBottomView:bottomView];
}

@end
