//
//  BRMedia.h
//  KnowN
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, BRMediaType) {
    BRMediaEmpty,
    BRMediaImage,
    BRMediaWebImage,
    BRMediaVideo,
};

@interface BRMedia : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BRMediaType type;

+ (BRMedia *)mediaWithImage:(UIImage *)image;
+ (BRMedia *)mediaWithImageURL:(NSURL *)url;
+ (BRMedia *)mediaWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (BRMedia *)mediaWithVideoURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithImageURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;

@end
