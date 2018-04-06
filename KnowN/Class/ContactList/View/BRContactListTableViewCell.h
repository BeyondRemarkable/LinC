//
//  BRRefreshTableViewCell.h
//  KnowN
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRContactListModel.h"

@interface BRContactListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

/** @brief 角标数 */
@property (nonatomic) NSInteger badgeValue;

/** @brief 是否显示角标 */
@property (nonatomic) BOOL showBadge;

///** @brief 头像圆角 */
//@property (nonatomic) CGFloat imageCornerRadius UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) BRContactListModel *contactListModel;

+ (NSString *)cellIdentifierWithModel:(id)model;

@end
