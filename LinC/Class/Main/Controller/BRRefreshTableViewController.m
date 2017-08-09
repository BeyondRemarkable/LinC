//
//  BRRefreshTableViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRRefreshTableViewController.h"
#import <MJRefresh.h>

@interface BRRefreshTableViewController ()
@property (nonatomic, readonly) UITableViewStyle style;
@end

@implementation BRRefreshTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = self.defaultFooterView;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    _page = 0;
    _showRefreshHeader = NO;
    _showRefreshFooter = NO;
    _showTableBlankView = NO;
}

#pragma mark - getter

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableDictionary *)dataDictionary
{
    if (_dataDictionary == nil) {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    
    return _dataDictionary;
}

- (UIView *)defaultFooterView
{
    if (_defaultFooterView == nil) {
        _defaultFooterView = [[UIView alloc] init];
    }
    
    return _defaultFooterView;
}

#pragma mark - setter

- (void)setShowRefreshHeader:(BOOL)showRefreshHeader {
    if (_showRefreshHeader != showRefreshHeader) {
        _showRefreshHeader = showRefreshHeader;
        if (_showRefreshHeader) {
            __weak BRRefreshTableViewController *weakSelf = self;
            MJRefreshHeader *header =[MJRefreshNormalHeader headerWithRefreshingBlock:^{
                NSLog(@"正在刷新...");
                [weakSelf tableViewDidTriggerHeaderRefresh];
            }];
            
            self.tableView.mj_header = header;
        }
        else {
            [self.tableView setMj_header:nil];
        }
    }
}

- (void)setShowRefreshFooter:(BOOL)showRefreshFooter {
    if (_showRefreshFooter != showRefreshFooter) {
        _showRefreshFooter = showRefreshFooter;
        if (_showRefreshFooter) {
            __weak BRRefreshTableViewController *weakSelf = self;
            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
            }];
        }
        else {
            [self.tableView setMj_footer:nil];
        }
    }
}

- (void)setShowTableBlankView:(BOOL)showTableBlankView {
    if (_showTableBlankView != showTableBlankView) {
        _showTableBlankView = showTableBlankView;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCellDefaultHeight;
}

#pragma mark - public refresh

- (void)autoTriggerHeaderRefresh
{
    if (self.showRefreshHeader) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    
}

- (void)tableViewDidTriggerFooterRefresh
{
    
}

- (void)tableViewDidFinishRefresh:(BRRefreshTableViewWidget)widget reload:(BOOL)reload {
    __weak BRRefreshTableViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload)
            [weakSelf.tableView reloadData];
        if (widget == BRRefreshTableViewWidgetHeader) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    });
}

@end
