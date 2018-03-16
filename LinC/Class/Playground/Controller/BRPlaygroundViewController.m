//
//  BRPlaygroundViewController.m
//  LinC
//
//  Created by Yingwei Fan on 3/8/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRPlaygroundViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRLectureVideoModel.h"
#import "BRLectureVideoCell.h"
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

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
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/videos/"];
    NSDictionary *parameters = @{@"page":@"1", @"perPage":@"10"};
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"%@", dict);
        NSArray *videoInfoArray = dict[@"data"][@"data"];
        for (NSDictionary *infoDict in videoInfoArray) {
            BRLectureVideoModel *model = [[BRLectureVideoModel alloc] init];
            model.identifier = infoDict[@"_id"];
            model.title = infoDict[@"title"];
            model.instructor = infoDict[@"instructor_name"];
            model.detail = infoDict[@"description"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSMutableString *dateString = [NSMutableString stringWithString:infoDict[@"created_at"]];
            [dateString deleteCharactersInRange:NSMakeRange(dateString.length - 1, 1)];
            [dateString replaceOccurrencesOfString:@"T" withString:@" " options:NSLiteralSearch range:NSRangeFromString(dateString)];
            model.createTime = [formatter dateFromString:dateString];
            dateString = [NSMutableString stringWithString:infoDict[@"updated_at"]];
            [dateString deleteCharactersInRange:NSMakeRange(dateString.length - 1, 1)];
            [dateString replaceOccurrencesOfString:@"T" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, dateString.length)];
            model.updateTime = [formatter dateFromString:dateString];
            
            [self.dataArray addObject:model];
        }
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
        hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.localizedDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (void)tableViewDidTriggerFooterRefresh {
    
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
//    model.title = @"Financial Meeting Interview";
//    model.instructor = @"Michael Jiang";
//    model.detail = @"Test video. Try everything to avoid a bug!";
//    cell.model = model;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AVPlayerViewController *playerVc = [[AVPlayerViewController alloc] init];

    [self.navigationController pushViewController:playerVc animated:YES];
}

@end
