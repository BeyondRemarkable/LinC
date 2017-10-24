//
//  NicknameTextViewController.h
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRNicknameTextViewControllerDelegate <NSObject>
@optional
- (void)nicknameDidChangeTo:(NSString *)newNickname;

@end

@interface BRNicknameTextViewController : UITableViewController

@property (nonatomic, copy) NSString *nameText;

@property (nonatomic, weak) id<BRNicknameTextViewControllerDelegate> delegate;

@end
