//
//  LocationListTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLocationListViewController.h"
#import "BRLocationCitiListTableViewController.h"

@interface BRLocationListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *provincesArray;
@property (nonatomic, strong) NSMutableArray *plistData;

@end

@implementation BRLocationListViewController

// Tableview cell identifier
static NSString * const cellIdentifier = @"LocationListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Lazy load NSMutableArray provincesArray
 *
 *  @return _provincesArray
 */
- (NSMutableArray *)provincesArray
{
    if (!_provincesArray) {
        _provincesArray = [NSMutableArray array];
    }
    return _provincesArray;
}

/**
 *  Load plist file
 */
-(void)loadData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ProvincesAndCities" ofType:@"plist"];
    
    self.plistData = [NSMutableArray arrayWithContentsOfFile:filePath];
    for (NSDictionary *dicr in self.plistData) {
        [self.provincesArray addObject:[dicr objectForKey:@"State"]];
    }
    [self.tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.provincesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    cell.textLabel.text = self.provincesArray[indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *citydict = self.plistData[indexPath.row];
    BRLocationCitiListTableViewController *vc = [[BRLocationCitiListTableViewController alloc] initWithNibName:@"BRLocationCitiListTableViewController" bundle:nil];
    
    vc.cityData = citydict;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
