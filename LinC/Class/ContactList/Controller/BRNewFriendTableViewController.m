//
//  BRNewFriendTableViewController.m
//  LinC
//
//  Created by zhe wu on 9/22/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRNewFriendTableViewController.h"
#import "BRNewFriendTableViewCell.h"
#import "BRFileWithNewFriendsRequestData.h"
#import "BRFriendRequestTableViewController.h"

@interface BRNewFriendTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation BRNewFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register tableview cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRNewFriendTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"newFriendCell"];
    
    // 读取需要好友请求JSON数据， 更新tableview
    self.dataArray = [BRFileWithNewFriendsRequestData getAllNewFriendRequestData];
    NSLog(@"self.dataArray--%@", self.dataArray);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BRNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell" forIndexPath:indexPath];
    
    if (self.dataArray) {
        cell.userID.text = self.dataArray[indexPath.row][@"userID"];
        cell.userMessage.text = self.dataArray[indexPath.row][@"message"];
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.dataArray[indexPath.row];
    UIStoryboard *sc = [UIStoryboard storyboardWithName:@"BRFriendInfo" bundle:[NSBundle mainBundle]];
    BRFriendRequestTableViewController *vc = [sc instantiateViewControllerWithIdentifier:@"BRFriendRequestTableViewController"];
    vc.searchID = [dict objectForKey:@"userID"];
    vc.message = [dict objectForKey:@"message"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
