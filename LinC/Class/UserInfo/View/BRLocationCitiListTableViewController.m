//
//  BRLocationCItiListTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLocationCitiListTableViewController.h"

@interface BRLocationCitiListTableViewController ()

@property (nonatomic, strong) NSMutableArray *cityArray;

@property (nonatomic, copy) NSString *locationLabel;

@end

@implementation BRLocationCitiListTableViewController

static NSString * const cellIdentifier = @"LocationCityListCell";

/**
 *  Lazy load NSMutableArray cityArray
 *
 *  @return _cityArray
 */
- (NSMutableArray *)cityArray
{
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCityData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCityData
{

    NSArray *citi = [self.cityData objectForKey:@"Cities"];

    for (NSDictionary *dict in citi) {
        [self.cityArray addObject:[dict objectForKey:@"city"]];
    }
    
    self.locationLabel = [[self.cityData objectForKey:@"State"] stringByAppendingString:@" "];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.cityArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.locationLabel = [self.locationLabel stringByAppendingString:self.cityArray[indexPath.row]];
   NSDictionary* locationDict = @{@"location": self.locationLabel};
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"location" object:self userInfo:locationDict];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
