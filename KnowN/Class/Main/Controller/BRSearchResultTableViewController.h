//
//  BRSearchResultTableViewController.h
//  KnowN
//
//  Created by Yingwei Fan on 4/25/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRSearchResultTableViewController : UITableViewController  <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UISearchBar *searchBar;

@end
