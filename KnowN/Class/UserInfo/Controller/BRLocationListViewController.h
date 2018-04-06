//
//  LocationListTableViewController.h
//  KnowN
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRLocationListViewControllerDelegate <NSObject>
@optional
- (void)locationDidUpdateTo:(NSString *)newLocation;

@end

@interface BRLocationListViewController : UITableViewController

@property (nonatomic, weak) id<BRLocationListViewControllerDelegate> delegate;

- (instancetype)initWithSytle:(UITableViewStyle)style locationArray:(NSArray *)locationArray;

@end
