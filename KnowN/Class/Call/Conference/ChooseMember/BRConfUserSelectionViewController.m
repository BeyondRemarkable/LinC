//
//  BRConfUserSelectionViewController.m
//
//  Copyright © 2018 Zhe Wu. All rights reserved.
//

#import "BRConfUserSelectionViewController.h"

#import "BRConfManager.h"
#import "BRFriendsInfo+CoreDataClass.h"
#import "BRConfAddUserCell.h"
//#import "UIViewController+SearchController.h"
#import "BRConferenceViewController.h"
#import "BRSDKHelper.h"
#import "BRClientManager.h"
#import "BRCoreDataManager.h"
#import "BRGroup+CoreDataClass.h"
#import "BRConferenceViewController.h"

@implementation BRConfSelectionUserView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAction:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - action

- (void)deleteAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(deselectUser:)]) {
            [_delegate deselectUser:self.nameLabel.text];
        }
    }
}

@end

@interface BRConfUserSelectionViewController()<UITableViewDelegate, UITableViewDataSource, /*EMSearchControllerDelegate,*/ BRConfAddUserCellDelegate, BRConfSelectionUserViewDelegate>
{
    int _border;
    int _userViewSize;
}

@property (nonatomic, strong) UIScrollView *selectedView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *topShowArray;
@property (nonatomic, strong) NSMutableArray *selectedNames;
@property (nonatomic, strong) NSMutableArray *userViews;
@property (nonatomic, assign) BOOL isCreateCon;
@property (nonatomic, assign) BOOL isInviteMoreMember;
@property (nonatomic, strong) NSMutableArray *selectedFriendInfo;
@end

@implementation BRConfUserSelectionViewController

- (instancetype)initWithDataSource:(NSArray *)aDataSource
                     selectedUsers:(NSArray *)aSelectedUsers andCreateCon:(BOOL) isCreateCon andGroupID:(NSString *)groupID
{
    self = [super init];
    if (self) {
        self.dataArray = aDataSource;
        self.topShowArray = aSelectedUsers;
        self.selectedNames = [[NSMutableArray alloc] init];
        self.userViews = [[NSMutableArray alloc] init];
        self.isCreateCon = isCreateCon;
        self.selectedFriendInfo = [[NSMutableArray alloc] init];
        self.groupID = groupID;
    }
    
    return self;
}

- (instancetype)initWithInviteMoreMembers:(NSArray *)aDataSource
                            selectedUsers:(NSArray *)aSelectedUsers andCreateCon:(BOOL) isCreateCon andGroupID:(NSString *)groupID
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.isInviteMoreMember = YES;
    return [self initWithDataSource:aDataSource selectedUsers:aSelectedUsers andCreateCon:isCreateCon andGroupID:groupID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popVC) name:@"poptoMessageViewController" object:nil];
    self.title = NSLocalizedString(@"Invite a Friend", nil);
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (!self.isInviteMoreMember) {
        [self loadGroupMembersFromServer];
    }
    [self _setupSubviews];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.tableView.tag != 1) {
        self.tableView.tag = 1;
        CGFloat oY = CGRectGetMaxY(self.selectedView.frame) + 13;
        self.tableView.frame = CGRectMake(0, oY, self.view.frame.size.width, self.view.frame.size.height - oY);
    }
}

- (void)loadGroupMembersFromServer {
    
    if (!self.dataArray.count) {
        hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow animated:YES];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    }
    
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupID cursor:nil pageSize:-1 completion:^(EMCursorResult *aResult, EMError *aError) {
        NSMutableArray *groupMembersArray = [aResult.list mutableCopy];
        BRGroup *group = [[[BRCoreDataManager sharedInstance] fetchGroupsWithGroupID:self.groupID] lastObject];
        [groupMembersArray addObject:group.groupOwner];
        
        if (!groupMembersArray.count) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Empty Chat Group.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:action];
            [self pushAlertView:alertVC];
        }

        if (!aError) {
            // 获取群成员信息
            [[BRClientManager sharedManager] getFriendInfoWithUsernames:groupMembersArray andSaveFlag:NO success:^(NSMutableArray *groupMembersInfoArray) {
                [groupMembersInfoArray sortUsingComparator:^NSComparisonResult(BRContactListModel *left, BRContactListModel *right) {
                    return [left.nickname compare: right.nickname];
                }];

                // 保存到数据库
                [[BRCoreDataManager sharedInstance] saveGroupMembersToCoreData:groupMembersInfoArray toGroup:self.groupID];
                NSMutableArray *groupMembersArray = [[[BRCoreDataManager sharedInstance] fetchGroupMembersByGroupID:self.groupID andGroupMemberUserNameArray:nil] mutableCopy];
                
                for (BRFriendsInfo *groupMemberInfo in groupMembersArray) {
                    if ([[EMClient sharedClient].currentUsername isEqualToString:groupMemberInfo.username]) {
                        [groupMembersArray removeObject:groupMemberInfo];
                        break;
                    }
                }
                self.dataArray = groupMembersArray;
                
                [self->hud hideAnimated:YES];
                [self.tableView reloadData];
            } failure:^(EMError *error) {
                self->hud.mode = MBProgressHUDModeText;
                self->hud.label.text = error.errorDescription;
                [self->hud hideAnimated:YES afterDelay:1.5];
            }];
        } else {
            self->hud.mode = MBProgressHUDModeText;
            self->hud.label.text = aError.errorDescription;
            [self->hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}
         
         
#pragma mark - Subviewa

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    int oY = 0;
    _border = 10;
    _userViewSize = 70;
    
//    [self enableSearchController];
//    UISearchBar *searchBar = self.searchController.searchBar;
//    CGRect frame = searchBar.frame;
//    frame.origin.x = 0;
//    frame.origin.y = 0;
//    searchBar.frame = frame;
//    [self.view addSubview:searchBar];
    
//    oY = CGRectGetMaxY(searchBar.frame);
    
    self.selectedView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, oY, self.view.frame.size.width, _userViewSize + 10)];
    self.selectedView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectedView];
    oY = CGRectGetMaxY(self.selectedView.frame);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, oY + 10, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:229 / 255.0 green:233 / 255.0 blue:236 / 255.0 alpha:1.0];
    [self.view addSubview:lineView];
    oY = CGRectGetMaxY(lineView.frame);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, oY, self.view.frame.size.width, self.view.frame.size.height - oY) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithRed:173 / 255.0 green:185 / 255.0 blue:193 / 255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:229 / 255.0 green:233 / 255.0 blue:236 / 255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 50;
    
    UINib *nib = [UINib nibWithNibName:@"BRConfAddUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"BRConfAddUserCell"];
    [self.view addSubview:self.tableView];
    
    for (BRFriendsInfo *friendInfo in self.topShowArray) {
        BRConfSelectionUserView *loginView = [self _setupUserView:friendInfo];
        loginView.deleteImgView.hidden = YES;
    }
}

- (BRConfSelectionUserView *)_setupUserView:(BRFriendsInfo *)aUser
{
    int count = (int)[self.userViews count];
    float ox = _border + count * (_border + _userViewSize);
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BRConfSelectionUserView" owner:self options:nil];
    BRConfSelectionUserView *userView = [nib objectAtIndex:0];
    userView.frame = CGRectMake(ox, _border, _userViewSize, _userViewSize);
    userView.delegate = self;
    if (aUser.nickname) {
        userView.nameLabel.text = aUser.nickname;
    } else {
        userView.nameLabel.text = aUser.username;
    }
    userView.userID = aUser.username;
    if (aUser.avatar) {
        userView.imgView.image = [UIImage imageWithData:aUser.avatar];
    } else {
        userView.imgView.image = [UIImage imageNamed:@"user_default"];
    }
    [self.userViews addObject:userView];
    [self.selectedView addSubview:userView];
    [self.selectedFriendInfo addObject:aUser];
    ++count;
    self.selectedView.contentSize = CGSizeMake(count * (_border + _userViewSize) + _border, self.selectedView.frame.size.height);
    
    return userView;
}

- (void)_removeUserView:(NSString *)aUserName
{
    int count = (int)[self.userViews count];
    int i = 0;
    for (; i < count; i++) {
        BRConfSelectionUserView *userView = [self.userViews objectAtIndex:i];

        if ([userView.userID isEqualToString:aUserName]) {
            [self.userViews removeObjectAtIndex:i];
            [userView removeFromSuperview];
            for (BRFriendsInfo *deleFriendInfo in self.selectedFriendInfo) {
                if (deleFriendInfo.username == aUserName) {
                    [self.selectedFriendInfo removeObject:deleFriendInfo];
                    break;
                }
            }
            break;
        }
    }
    
    if (i < count) {
        --count;
        for (; i < count; i++) {
            float ox = _border + i * (_border + _userViewSize);
            BRConfSelectionUserView *userView = [self.userViews objectAtIndex:i];
            userView.frame = CGRectMake(ox, _border, _userViewSize, _userViewSize);
        }
    }
    
    self.selectedView.contentSize = CGSizeMake(count * (_border + _userViewSize) + _border, self.selectedView.frame.size.height);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BRConfAddUserCell";
    BRConfAddUserCell *cell = (BRConfAddUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    
    BRFriendsInfo *friendInfo = [self.dataArray objectAtIndex:indexPath.row];
    if (friendInfo.nickname) {
        cell.nameLabel.text = friendInfo.nickname;
    } else {
        cell.nameLabel.text = friendInfo.username;
    }
    if (friendInfo.avatar) {
        cell.imgView.image = [UIImage imageWithData:friendInfo.avatar];
    } else {
        cell.imgView.image = [UIImage imageNamed:@"user_default"];
    }
    
    
//    cell.checkButton.selected = [self.selectedNames containsObject:username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRFriendsInfo *friendInfo = [self.dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.selectedNames containsObject:friendInfo.username];
    if (isChecked) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedNames removeObject:friendInfo.username];
        [self _removeUserView:friendInfo.username];
    } else {
//        if ([self.selectedNames count] == 6) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            return;
//        }
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedNames addObject:friendInfo.username];
        [self _setupUserView:friendInfo];
    }
    if (self.selectedNames.count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}



#pragma mark - BRConfAddUserCellDelegate

- (void)cell:(BRConfAddUserCell *)aCell checkUserAction:(NSString *)aUsername
{
//    if ([self.selectedNames containsObject:aUsername]) {
//        [self.selectedNames removeObject:aUsername];
//        [self _removeUserView:aUsername];
//    } else {
//        if ([self.selectedNames count] == 6) {
//            aCell.checkButton.selected = NO;
//            return;
//        }
//        [self.selectedNames addObject:aUsername];
//        [self _setupUserView:aUsername];
//    }
}

#pragma mark - BRConfSelectionUserViewDelegate

- (void)deselectUser:(NSString *)aUserName
{
    if (aUserName == [EMClient sharedClient].currentUsername) {
        return;
    }
    BRConfSelectionUserView *deleteUserView = nil;
    for (BRConfSelectionUserView *userView in self.userViews) {
        if (userView.nameLabel.text == aUserName) {
            deleteUserView = userView;
            break;
        }
    }
    if (deleteUserView) {
        
        for (BRFriendsInfo *friendInfo in self.dataArray) {
            if ([friendInfo.nickname isEqualToString:aUserName] || [friendInfo.username isEqualToString:aUserName]) {
                [self.selectedNames removeObject:friendInfo.username];
                break;
            }
        }
        
        [self _removeUserView:deleteUserView.userID];
        if (self.selectedNames.count) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        NSInteger index = -1;
        for (NSInteger i = 0; i < self.dataArray.count; i++) {
            BRFriendsInfo *friendInfo = [self.dataArray objectAtIndex:i];
            if (friendInfo.username == deleteUserView.userID) {
                index = i;
            }
        }
        if (index >= 0) {
            BRConfAddUserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

#pragma mark - action

- (void)doneAction
{
    if (self.isCreateCon) {
        
        [[BRConfManager sharedManager] createConferenceWithFriendsList:self.selectedFriendInfo fromGroupID:self.groupID];
        
    } else {

        if (_selecteUserFinishedCompletion) {
            _selecteUserFinishedCompletion(self.selectedNames);
            [self cancelAction];
        }
    }
}

- (void)popVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 弹出alert view
 
 @param alertController alertView
 */
- (void)pushAlertView:(UIAlertController *)alertController {
    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if([rootViewController isKindOfClass:[UINavigationController class]])
    {
        rootViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
    }
    if([rootViewController isKindOfClass:[UITabBarController class]])
    {
        rootViewController = ((UITabBarController *)rootViewController).selectedViewController;
    }
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
