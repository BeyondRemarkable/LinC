//
//  BRFriendInfoTableViewController.m
//  LinC
//
//  Created by zhe wu on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRFriendInfoTableViewController.h"
#import "BRAddingFriendViewController.h"

@interface BRFriendInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@end

@implementation BRFriendInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isFriend) {
        [self.addFriendButton setHidden:YES];
    }
    else {
        [self.chatButton setHidden:YES];
        [self.deleteFriendButton setHidden:YES];
    }
    
    [self setupNavigationBarItem];
}

- (void)setupNavigationBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}



#pragma mark - UITableView data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - button actions
- (void)clickMoreInfo {
    
}

- (IBAction)clickAddFriend:(id)sender {
   
}

- (IBAction)clickDeleteFriend:(id)sender {
    
}

- (IBAction)clickChat:(id)sender {
}



@end
