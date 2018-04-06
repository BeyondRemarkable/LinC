//
//  BRLectureVideoCell.h
//  KnowN
//
//  Created by Yingwei Fan on 3/9/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRLectureVideoModel.h"

@interface BRLectureVideoCell : UITableViewCell

+ (NSString *)reuseIdentifier;

+ (CGFloat)defaultCellHeight;

@property (nonatomic, strong) BRLectureVideoModel *model;

@end
