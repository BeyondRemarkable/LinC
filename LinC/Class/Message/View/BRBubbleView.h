//
//  BRBubbleView.h
//  LinC
//
//  Created by Yingwei Fan on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const BRMessageCellPadding;

extern NSString *const BRMessageCellIdentifierSendText;
extern NSString *const BRMessageCellIdentifierSendLocation;
extern NSString *const BRMessageCellIdentifierSendVoice;
extern NSString *const BRMessageCellIdentifierSendVideo;
extern NSString *const BRMessageCellIdentifierSendImage;
extern NSString *const BRMessageCellIdentifierSendFile;

extern NSString *const BRMessageCellIdentifierRecvText;
extern NSString *const BRMessageCellIdentifierRecvLocation;
extern NSString *const BRMessageCellIdentifierRecvVoice;
extern NSString *const BRMessageCellIdentifierRecvVideo;
extern NSString *const BRMessageCellIdentifierRecvImage;
extern NSString *const BRMessageCellIdentifierRecvFile;

@interface BRBubbleView : UIView
{
    UIEdgeInsets _margin;
    CGFloat _fileIconSize;
}

@property (nonatomic) BOOL isSender;

@property (nonatomic, readonly) UIEdgeInsets margin;

@property (strong, nonatomic) NSMutableArray *marginConstraints;

@property (strong, nonatomic) UIImageView *backgroundImageView;

//text views
@property (strong, nonatomic) UILabel *textLabel;

//image views
@property (strong, nonatomic) UIImageView *imageView;

//location views
@property (strong, nonatomic) UIImageView *locationImageView;
@property (strong, nonatomic) UILabel *locationLabel;

//voice views
@property (strong, nonatomic) UIImageView *voiceImageView;
@property (strong, nonatomic) UILabel *voiceDurationLabel;
@property (strong, nonatomic) UIImageView *isReadView;

//video views
@property (strong, nonatomic) UIImageView *videoImageView;
@property (strong, nonatomic) UIImageView *videoTagView;

//file views
@property (strong, nonatomic) UIImageView *fileIconView;
@property (strong, nonatomic) UILabel *fileNameLabel;
@property (strong, nonatomic) UILabel *fileSizeLabel;

- (instancetype)initWithMargin:(UIEdgeInsets)margin
                      isSender:(BOOL)isSender;

@end
