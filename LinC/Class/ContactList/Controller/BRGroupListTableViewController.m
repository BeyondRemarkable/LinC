//
//  BRGroupListTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/27/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRGroupListTableViewController.h"
#import "BRGroupMemberTableViewCell.h"
#import <Hyphenate/Hyphenate.h>

@interface BRGroupListTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *groupArray;

@end

@implementation BRGroupListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    
     [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRGroupMemberTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"groupCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.groupArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRGroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
    cell.grounName.text = [NSString stringWithFormat:@"%@", self.groupArray[indexPath.row]];
   
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

@end
