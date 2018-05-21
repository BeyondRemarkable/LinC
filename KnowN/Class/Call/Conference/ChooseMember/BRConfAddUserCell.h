//
//  BRConfAddUserCell.h
//  Copyright © 2016 Zhe Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRConfAddUserCellDelegate;

@interface BRConfAddUserCell : UITableViewCell

@property (weak, nonatomic) id<BRConfAddUserCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

@protocol BRConfAddUserCellDelegate <NSObject>

@optional

- (void)cell:(BRConfAddUserCell *)aCell checkUserAction:(NSString *)aUsername;

@end
