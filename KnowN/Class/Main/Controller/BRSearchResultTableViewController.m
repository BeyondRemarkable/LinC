//
//  BRSearchResultTableViewController.m
//  KnowN
//
//  Created by Yingwei Fan on 4/25/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRSearchResultTableViewController.h"
#import "BRContactListModel.h"
#import "BRSearchResultCell.h"
#import "BRFriendInfoTableViewController.h"

@interface BRSearchResultTableViewController ()

@property (nonatomic, strong) NSMutableArray *resultArray;

@end

@implementation BRSearchResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.rowHeight = [BRSearchResultCell defaultRowHeight];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[BRSearchResultCell class] forCellReuseIdentifier:[BRSearchResultCell identifier]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;//不加的话，table会下移
    self.edgesForExtendedLayout = UIRectEdgeNone;//不加的话，UISearchBar返回后会上移，键盘不会弹出
}

- (NSMutableArray *)resultArray {
    if (_resultArray == nil) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:[BRSearchResultCell identifier] forIndexPath:indexPath];
    
    BRContactListModel *model = self.resultArray[indexPath.row];
    cell.model = model;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Matched Contacts", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BRContactListModel *contactListModel = self.resultArray [indexPath.row];
    
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    
    BRFriendInfoTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendInfoTableViewController"];
    vc.contactListModel = contactListModel;
    vc.isFriend = YES;
    
    [self.presentingViewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    if (self.resultArray.count > 0) {
        [self.resultArray removeAllObjects];
    }
    for (BRContactListModel *model in self.dataArray) {
        if ([model.nickname localizedCaseInsensitiveContainsString:inputStr]) {
            [self.resultArray addObject:model];
        }
        else if([model.username localizedCaseInsensitiveContainsString:inputStr]) {
            [self.resultArray addObject:model];
        }
    }
    [self.tableView reloadData];
}

@end
