//
//  BRMessageReadManager.m
//  LinC
//
//  Created by Yingwei Fan on 8/12/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMessageReadManager.h"
#import <SDWebImage/UIView+WebCache.h>
#import "BRCDDeviceManager.h"
#import "BRMediaBrowserViewController.h"

#define IMAGE_MAX_SIZE_5k 5120*2880

static BRMessageReadManager *detailInstance = nil;

@interface BRMessageReadManager ()

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSMutableArray *medias;
@property (strong, nonatomic) UINavigationController *photoNavigationController;
@property (nonatomic, strong) BRMediaBrowserViewController *mediaBrowser;

@end

@implementation BRMessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}

#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}

- (NSMutableArray *)medias
{
    if (_medias == nil) {
        _medias = [[NSMutableArray alloc] init];
    }
    
    return _medias;
}

- (BRMediaBrowserViewController *)mediaBrowser {
    if (_mediaBrowser == nil) {
        _mediaBrowser = [[BRMediaBrowserViewController alloc] initWithMediaArray:self.medias];
    }
    return _mediaBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mediaBrowser];
        _photoNavigationController = [[UINavigationController alloc] init];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [self.mediaBrowser.collectionView reloadData];
    return _photoNavigationController;
}


#pragma mark - private


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *mediaArray = [NSMutableArray array];
        for (id object in imageArray) {
            BRMedia *media = nil;
            if ([object isKindOfClass:[UIImage class]]) {
                CGFloat imageSize = ((UIImage*)object).size.width * ((UIImage*)object).size.height;
                if (imageSize > IMAGE_MAX_SIZE_5k) {
                    media = [BRMedia mediaWithImage:[self scaleImage:object toScale:(IMAGE_MAX_SIZE_5k)/imageSize]];
                } else {
                    media = [BRMedia mediaWithImage:object];
                }
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                media = [BRMedia mediaWithImageURL:object];
            }
            else if ([object isKindOfClass:[NSString class]])
            {
                
            }
            [mediaArray addObject:media];
        }
        
        self.medias = mediaArray;
    }
    
    UIViewController *rootController = [self.keyWindow rootViewController];
    [rootController presentViewController:self.photoNavigationController animated:YES completion:nil];
}

- (BOOL)prepareMessageAudioModel:(BRMessageModel *)messageModel
            updateViewCompletion:(void (^)(BRMessageModel *prevAudioModel, BRMessageModel *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if(messageModel.bodyType == EMMessageBodyTypeVoice)
    {
        BRMessageModel *prevAudioModel = self.audioMessageModel;
        BRMessageModel *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isMediaPlaying;
        if (isPlaying) {
            messageModel.isMediaPlaying = NO;
            self.audioMessageModel = nil;
            currentAudioModel = nil;
            [[BRCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            messageModel.isMediaPlaying = YES;
            prevAudioModel.isMediaPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isMediaPlayed) {
                messageModel.isMediaPlayed = YES;
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [[EMClient sharedClient].chatManager updateMessage:chatMessage completion:nil];
                    }
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:chatMessage.ext];
                    [dic setObject:@YES forKey:@"isPlayed"];
                    chatMessage.ext = dic;
                    [[EMClient sharedClient].chatManager updateMessage:chatMessage completion:nil];
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    
    return isPrepare;
}

- (BRMessageModel *)stopMessageAudioModel
{
    BRMessageModel *model = nil;
    if (self.audioMessageModel.bodyType == EMMessageBodyTypeVoice) {
        if (self.audioMessageModel.isMediaPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isMediaPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
