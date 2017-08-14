//
//  BRMessageTimeCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRMessageTimeCell : UITableViewCell

@property (strong, nonatomic) NSString *title;

/*
 *  时间显示字体
 */
@property (nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:12]

/*
 *  时间显示颜色
 */
@property (nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor]

+ (NSString *)cellIdentifier;

@end
