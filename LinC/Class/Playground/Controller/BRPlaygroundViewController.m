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
#import "BRLectureVideoModel.h"
#import "BRLectureVideoCell.h"
#import "BRClientManager.h"
#import "BRVideoPlayerViewController.h"
#import "BRCoreDataManager.h"

#define NumberOfVideosFromCoreData 15

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
    
    [self loadVideosFromCoreData];
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadVideosFromCoreData {
    NSArray *fetchedVideos = [[BRCoreDataManager sharedInstance] fetchVideosWithNumber:NumberOfVideosFromCoreData isBefore:YES time:[NSDate dateWithTimeIntervalSinceNow:0]];
    [self.dataArray addObjectsFromArray:fetchedVideos];
}

- (void)tableViewDidTriggerHeaderRefresh {
    NSDate *date = nil;
    if (self.dataArray.count != 0) {
        BRLectureVideoModel *model = [self.dataArray firstObject];
        date = model.updateTime;
    }
    [[BRClientManager sharedManager] getVideoListWithNumberOfPages:0 numberOfVideosPerPage:0 after:date success:^(NSArray *videoModelArray) {
        [[BRCoreDataManager sharedInstance] insertVideosToCoreData:videoModelArray];
        BRLectureVideoModel *model = [self.dataArray lastObject];
        NSArray *fetchedVideos = [[BRCoreDataManager sharedInstance] fetchVideosWithNumber:-1 isBefore:NO time:model.updateTime];
        self.dataArray = [NSMutableArray arrayWithArray:model?fetchedVideos:videoModelArray];
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
    if (self.dataArray.count) {
        BRLectureVideoModel *model = [self.dataArray lastObject];
        NSArray *fetchedVideos = [[BRCoreDataManager sharedInstance] fetchVideosWithNumber:NumberOfVideosFromCoreData isBefore:YES time:model.updateTime];
        [self.dataArray addObjectsFromArray:fetchedVideos];
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetFooter reload:YES];
    }
    else {
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetFooter reload:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRLectureVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[BRLectureVideoCell reuseIdentifier] forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];

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
