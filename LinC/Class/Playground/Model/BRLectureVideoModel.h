//
//  BRLectureVideoModel.h
//  LinC
//
//  Created by Yingwei Fan on 3/10/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BRLectureVideoModel : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *instructor;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) BOOL isBought;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *thumbnailURL;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;

@end
