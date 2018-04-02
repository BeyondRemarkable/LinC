//
//  BRPlaygroundViewController.m
//  LinC
//
//  Created by Yingwei Fan on 3/8/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BRPlaygroundViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRLectureVideoModel.h"
#import "BRLectureVideoCell.h"
#import "BRClientManager.h"
#import "BRVideoPlayerViewController.h"

@interface BRPlaygroundViewController ()
{
    MBProgressHUD *hud;
}

@end

@implementation BRPlaygroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = YES;
    self.showRefreshFooter = YES;
    
    [self.tableView registerClass:[BRLectureVideoCell class] forCellReuseIdentifier:[BRLectureVideoCell reuseIdentifier]];
    self.tableView.rowHeight = [BRLectureVideoCell defaultCellHeight];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)tableViewDidTriggerHeaderRefresh {
    NSDate *date = nil;
    if (self.dataArray.count != 0) {
        BRLectureVideoModel *model = [self.dataArray firstObject];
        date = model.updateTime;
    }
    [[BRClientManager sharedManager] getVideoListWithNumberOfPages:0 numberOfVideosPerPage:0 after:date success:^(NSArray *videoModelArray) {
        [self.dataArray addObjectsFromArray:videoModelArray];
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
    } failure:^(EMError *error) {
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
        hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (void)tableViewDidTriggerFooterRefresh {
    [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetFooter reload:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
//    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRLectureVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[BRLectureVideoCell reuseIdentifier] forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
//    BRLectureVideoModel *model = [[BRLectureVideoModel alloc] init];
//    model.identifier = @"5aaed698483692550a74a8b6";
//    model.title = @"Financial Meeting Interview";
//    model.instructor = @"Michael Jiang";
//    model.detail = @"Test video. Try everything to avoid a bug!";
//    model.price = 0;
//    cell.model = model;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BRVideoPlayerViewController *playerVc = [[BRVideoPlayerViewController alloc] init];
    BRLectureVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    playerVc.model = cell.model;
    [self.navigationController pushViewController:playerVc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
