//
//  BRRefreshTableViewController.h
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

/** tabeleView的cell高度 */
#define KCellDefaultHeight 50

typedef enum : NSUInteger {
    BRRefreshTableViewWidgetHeader,
    BRRefreshTableViewWidgetFooter,
} BRRefreshTableViewWidget;

/** 带加载、刷新的Controller(包含UITableView) */
@interface BRRefreshTableViewController : UITableViewController

/** 导航栏右侧BarItem */
@property (strong, nonatomic) NSArray *rightItems;
/** 默认的tableFooterView */
@property (strong, nonatomic) UIView *defaultFooterView;

/** tableView的数据源，用户UI显示 */
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;

/** 当前加载的页数 */
@property (nonatomic) int page;

/** 是否启用下拉加载更多，默认为NO */
@property (nonatomic) BOOL showRefreshHeader;
/** 是否启用上拉加载更多，默认为NO */
@property (nonatomic) BOOL showRefreshFooter;
/** 是否显示无数据时的空白提示，默认为NO(未实现提示页面) */
@property (nonatomic) BOOL showTableBlankView;


/*!
 @method
 @brief 下拉加载更多(下拉刷新)
 */
- (void)tableViewDidTriggerHeaderRefresh;

/*!
 @method
 @brief 上拉加载更多
 */
- (void)tableViewDidTriggerFooterRefresh;

/*!
 @method
 @brief 加载结束
 @discussion 加载结束后，通过参数reload来判断是否需要调用tableView的reloadData，判断isHeader来停止加载
 @param widget   是否结束下拉加载(或者上拉加载)
 @param reload     是否需要重载TabeleView
 */
- (void)tableViewDidFinishRefresh:(BRRefreshTableViewWidget)widget reload:(BOOL)reload;

@end
