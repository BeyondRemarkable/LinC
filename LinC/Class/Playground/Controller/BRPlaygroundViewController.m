//
//  BRPlaygroundViewController.m
//  LinC
//
//  Created by Yingwei Fan on 3/8/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "BRPlaygroundViewController.h"
#import "BRHTTPSessionManager.h"
#import "BRLectureVideoCell.h"

@interface BRPlaygroundViewController ()

@end

@implementation BRPlaygroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = YES;
    self.showRefreshFooter = YES;
    
    [self.tableView registerClass:[BRLectureVideoCell class] forCellReuseIdentifier:[BRLectureVideoCell reuseIdentifier]];
    self.tableView.rowHeight = [BRLectureVideoCell defaultCellHeight];
}

- (void)tableViewDidTriggerHeaderRefresh {
    BRHTTPSessionManager *manager = [BRHTTPSessionManager manager];
    NSString *url = [kBaseURL stringByAppendingPathComponent:@"/api/v1/videos/"];
    NSDictionary *parameters = @{@"page":@"1", @"perPage":@"10"};
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"%@", dict);
        [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ERROR - %@", error.localizedDescription);
    }];
}

- (void)tableViewDidTriggerFooterRefresh {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRLectureVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[BRLectureVideoCell reuseIdentifier] forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate


@end
