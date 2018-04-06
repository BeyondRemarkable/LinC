//
//  BRMedia.m
//  KnowN
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMedia.h"
#import <UIKit/UIKit.h>

@interface BRMedia ()

@property (nonatomic, assign) CGSize assetTargetSize;

@end

@implementation BRMedia

#pragma mark - Class Methods

+ (BRMedia *)mediaWithImage:(UIImage *)image {
    return [[BRMedia alloc] initWithImage:image];
}

+ (BRMedia *)mediaWithImageURL:(NSURL *)url {
    return [[BRMedia alloc] initWithImageURL:url];
}

+ (BRMedia *)mediaWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    return [[BRMedia alloc] initWithAsset:asset targetSize:targetSize];
}

+ (BRMedia *)mediaWithVideoURL:(NSURL *)url {
    return [[BRMedia alloc] initWithVideoURL:url];
}

- (id)init {
    if ((self = [super init])) {
        self.type = BRMediaEmpty;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
        self.type = BRMediaImage;
    }
    return self;
}

- (id)initWithImageURL:(NSURL *)url {
    if ((self = [super init])) {
        self.imageURL = url;
        self.type = BRMediaWebImage;
    }
    return self;
}

- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if ((self = [super init])) {
        self.asset = asset;
        self.assetTargetSize = targetSize;
        self.type = asset.mediaType == PHAssetMediaTypeVideo? BRMediaVideo : BRMediaImage;
    }
    return self;
}

- (id)initWithVideoURL:(NSURL *)url {
    if ((self = [super init])) {
        self.videoURL = url;
        self.type = BRMediaVideo;
    }
    return self;
}


@end
