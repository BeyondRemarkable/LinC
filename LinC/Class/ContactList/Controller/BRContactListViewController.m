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
#import "IUserModel.h"
#import "BRAddingFriendViewController.h"
#import <MJRefresh.h>


@interface BRContactListViewController () <UITableViewDelegate, UITableViewDataSource>

//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *storedListArray;

@end

@implementation BRContactListViewController

typedef enum : NSInteger {
    TableViewSectionZerro = 0,
    TableViewSectionOne,
} TableViewSession;

typedef enum : NSInteger {
    TableViewNewFriend = 0,
    TableVIewGroup,
} UITableViewRow;

// Tableview cell identifier
static NSString * const cellIdentifier = @"ContactListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpTableView];
    [self setUpNavigationBarItem];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  Lazy load NSArray storedListArray
 *
 *  @return _storedListArray
 */
- (NSArray *)storedListArray
{
    if (!_storedListArray) {
        _storedListArray = [NSArray array];
    }
    return _storedListArray;
}

/**
 * Set up tableView
 */
- (void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Register reuseable tableview cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BRContactListTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.storedListArray = @[@"New Friend", @"Group"];
}

#pragma mark 

- (void)setUpNavigationBarItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_new_friend"] style:UIBarButtonItemStylePlain target:self action: @selector(addNewFriend)];
}

-(void)addNewFriend {
//    BRAddingContentView *cView = [[[NSBundle mainBundle] loadNibNamed:@"BRAddingContentView" owner:self options:nil] firstObject];
//    cView.frame = CGRectMake(50, 50, 200, 200);
//    cView.backgroundColor = [UIColor redColor];
//    [self.view addSubview: cView];
    
    BRAddingFriendViewController *vc = [[BRAddingFriendViewController alloc] initWithNibName:@"BRAddingFriendViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if (section == TableViewSectionZerro ) {
        return self.storedListArray.count;
    } else {
        return self.dataArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == TableViewSectionZerro) {
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell.nickName.text = self.storedListArray[indexPath.row];
        
//        if (indexPath.row == 0) {
//            cell.nickName.text = @"New Friend";
//        }
//        if (indexPath.row == 1) {
//            cell.nickName.text = @"Group";
//        }
        
        return cell;
    } else {
    
        BRContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
        id<IUserModel> contactListModel = [self.dataArray objectAtIndex: indexPath.row];
        cell.contactList = contactListModel;
    
        return cell;
    }
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

/**
 * Set up white space between groups
 */
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 50;
//    } else {
//        return 0;
//    }
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == TableViewSectionZerro) {
        return 40;
    } else {
        return 70;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // New friend and group session
    if (indexPath.section == TableViewSectionZerro) {
        if (indexPath.row == TableVIewGroup) {
            
        }
        if (indexPath.row == TableViewNewFriend) {
            
        }
    }
    // User contact list cell
    if (indexPath.section == TableViewSectionOne) {
        BRContactListModel *contactListModel = self.dataArray[indexPath.row];
        
        BRFriendInfoViewController *friendVC = [[BRFriendInfoViewController alloc] initWithNibName:@"BRFriendInfoView" bundle:nil];
        
        friendVC.imageIcon.image = [UIImage imageNamed:contactListModel.iconURL];
        friendVC.userName.text = contactListModel.userName;
        
        [self.navigationController pushViewController: friendVC animated:YES];
    }
    
}


- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            NSMutableArray *contactsSource = [NSMutableArray arrayWithArray:buddyList];
            NSMutableArray *tempDataArray = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
            for (NSInteger i = 0; i < buddyList.count; i++) {
                NSString *buddy = [buddyList objectAtIndex:i];
                if (![blockList containsObject:buddy]) {
                    [contactsSource addObject:buddy];
                    
                    BRContactListModel *model = [[BRContactListModel alloc] initWithBuddy:buddy];
                    
                    if(model){
                        [tempDataArray addObject:model];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray removeAllObjects];
                [weakself.dataArray addObjectsFromArray:tempDataArray];
                [weakself.tableView reloadData];
            });
        }
        [weakself tableViewDidFinishRefresh:BRRefreshTableViewWidgetHeader reload:NO];
    });
}

@end
