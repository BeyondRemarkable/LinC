//
//  BRNewFriendTableViewCell.h
//  KnowN
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRNewFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userID;

@property (weak, nonatomic) IBOutlet UILabel *userMessage;


@end
