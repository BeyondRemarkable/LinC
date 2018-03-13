//
//  BRLectureVideoModel.h
//  LinC
//
//  Created by Yingwei Fan on 3/10/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRLectureVideoModel : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *instructor;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;

@end
