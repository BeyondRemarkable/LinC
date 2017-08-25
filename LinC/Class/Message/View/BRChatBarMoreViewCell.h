//
//  BRChatBarMoreViewCell.h
//  LinC
//
//  Created by Yingwei Fan on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRChatBarMoreViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (NSString *)cellReuseIdentifier;

@end
