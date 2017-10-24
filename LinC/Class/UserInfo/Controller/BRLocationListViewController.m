//
//  LocationListTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLocationListViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>

@interface BRLocationListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *hud;
}

@property (nonatomic, strong) NSArray *locationArray;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, copy) NSString *selectedLocation;

@end

@implementation BRLocationListViewController

// Tableview cell identifier
static NSString * const cellIdentifier = @"LocationListCell";

- (instancetype)initWithSytle:(UITableViewStyle)style locationArray:(NSArray *)locationArray {
    if (self = [super initWithStyle:style]) {
        _locationArray = [NSArray arrayWithArray:locationArray];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)doneAction {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *array = self.navigationController.viewControllers;
    NSMutableString *locationStr = [NSMutableString string];
    for (BRLocationListViewController *vc in array) {
        [locationStr appendString:vc.selectedLocation];
        [locationStr appendString:@" "];
    }
    NSString *newLocation = [NSString stringWithString:locationStr];
    newLocation = [newLocation trimString];
    [[BRClientManager sharedManager] updateSelfInfoWithKeys:@[@"location"] values:@[newLocation] success:^(NSString *message) {
        [hud hideAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(locationDidUpdateTo:)]) {
            [_delegate locationDidUpdateTo:newLocation];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(EMError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = error.errorDescription;
        [hud hideAnimated:YES afterDelay:1.5];
    }];
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableview data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locationArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    NSDictionary *dict = self.locationArray[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    if (dict[@"contains"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.locationArray[indexPath.row];
    self.selectedLocation = dict[@"name"];
    NSArray *array = dict[@"contains"];
    if (array) {
        BRLocationListViewController *vc = [[BRLocationListViewController alloc] initWithSytle:UITableViewStyleGrouped locationArray:dict[@"contains"]];
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        UITableViewCell *cell = nil;
        if (self.selectedIndex) {
            cell = [tableView cellForRowAtIndexPath:self.selectedIndex];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        self.selectedIndex = indexPath;
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


@end
