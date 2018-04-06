//
//  BRBlackListViewController.m
//  KnowN
//
//  Created by Yingwei Fan on 11/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRBlackListViewController.h"
#import <Hyphenate/Hyphenate.h>

@interface BRBlackListViewController ()

@end

@implementation BRBlackListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *blackList = [[EMClient sharedClient].contactManager getBlackList];
    self.dataArray = [NSMutableArray arrayWithArray:blackList];
}


- (void)tableViewDidTriggerHeaderRefresh {
    [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            self.dataArray = [NSMutableArray arrayWithArray:aList];
            [self tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:YES];
        }
    }];
}

@end
