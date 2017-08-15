//
//  BRRefreshViewController.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListViewController.h"
#import "BRContactListTableViewCell.h"
#import "BRFriendInfoViewController.h"

@interface BRContactListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contactListArray;
@property (nonatomic, strong) NSArray *storedListArray;

@end

@implementation BRContactListViewController

// Tableview cell identifier
static NSString * const cellIdentifier = @"ContactListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpTableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Lazy load NSMutableArray dataArray
 *
 *  @return _dataArray
 */
- (NSMutableArray *)dataArray
{
    if (!_contactListArray) {
        _contactListArray = [NSMutableArray array];
    }
    return _contactListArray;
}


/**
 * Set up tableView
 */
- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Register reuseable tableview cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRRefreshTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.storedListArray = @[@"New Friend", @"Group"];
}


#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if (section == 1 ) {
        return self.storedListArray.count;
    } else {
        return self.contactListArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRRefreshTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    BRContactListModel *contactListModel = [self.contactListArray objectAtIndex:[indexPath row]];
    cell.contactList = contactListModel;
    
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

/**
 * Set up white space between groups
 */
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 50;
    } else {
        return 0;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRContactListModel *contactListModel = self.contactListArray[indexPath.row];
    
    BRFriendInfoViewController *friendVC = [[BRFriendInfoViewController alloc] initWithNibName:@"BRFriendInfoView" bundle:nil];
    
    friendVC.imageIcon.image = [UIImage imageNamed:contactListModel.iconURL];
    friendVC.userName.text = contactListModel.userName;
    
    [self.navigationController pushViewController: friendVC animated:YES];
}



@end
