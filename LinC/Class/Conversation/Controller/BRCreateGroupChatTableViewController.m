//
//  BRGroupChatSettingTableViewController.m
//  LinC
//
//  Created by zhe wu on 12/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRCreateGroupChatTableViewController.h"
#import "BRClientManager.h"
#import "BRMessageViewController.h"
#import <MBProgressHUD.h>
#import "BRNavigationController.h"
#import "BRCoreDataManager.h"


@interface BRCreateGroupChatTableViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (assign, nonatomic) NSInteger groupStyle;
@property(strong,nonatomic) NSIndexPath *selectedIndex;
@property(assign,nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

@end

@implementation BRCreateGroupChatTableViewController

typedef enum : NSInteger {
    TableViewGroupName = 0,
    TableViewGroupDescription,
    TableViewGroupStyle,
} UITableViewRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.delegate = self;
    self.groupStyle = -1;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneCreatingGroup:)];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        self.textViewPlaceHolder.hidden = NO;
    } else {
        self.textViewPlaceHolder.hidden = YES;
    }
}
- (void)doneCreatingGroup:(UIBarButtonItem *)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (self.groupName.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Group's name is required.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    if (self.description.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Group's description is required.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    if (self.groupStyle == -1) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Group's style is required.";
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = 500;
    setting.style = (EMGroupStyle)self.groupStyle;
    [[EMClient sharedClient].groupManager createGroupWithSubject:self.groupName.text description:self.textView.text invitees:self.selectedList message:@""  setting:setting completion:^(EMGroup *aGroup, EMError *aError) {
        if(!aError){

//            [[BRCoreDataManager sharedInstance] saveGroupToCoreData:aGroup withIcon:nil];
            [hud hideAnimated:YES];
            // 退出创建界面
            BRMessageViewController *vc = [[BRMessageViewController alloc] initWithConversationChatter:aGroup.groupId conversationType:EMConversationTypeGroupChat];
            vc.title = aGroup.subject;
            [self dismissViewControllerAnimated:YES completion:^{
                self.dismissViewControllerCompletionBlock(vc);
            }];
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = aError.errorDescription;
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

//关闭键盘
-(void) dismissKeyBoard{
    [self.textView resignFirstResponder];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupStyle) {
        
        NSInteger newRow = [indexPath row];
        NSInteger oldRow = (self.selectedIndex != nil)?[self.selectedIndex row] : -1;
        if (newRow != oldRow) {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndex];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedIndex = indexPath;
            self.groupStyle = indexPath.row;
        }
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupStyle) {
        return 40;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
}

#pragma mark - Table view Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableViewGroupStyle) {
        return 4;
    } else {
        return [super tableView:tableView
          numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupStyle) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupStyle"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupStyle"];
        }
        
        NSInteger row = [indexPath row];
        NSInteger oldRow = [self.selectedIndex row];
        if (row == oldRow && self.selectedIndex != nil) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Host Invitation Only";
                break;
            case 1:
                cell.textLabel.text = @"Host/Member Invitation Only";
                break;
            case 2:
                cell.textLabel.text = @"Member Invitation/Join Request Only";
                break;
            case 3:
                cell.textLabel.text = @"Automatically Join";
                break;
            default:
                break;
        }
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableViewGroupStyle) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TableViewGroupStyle]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}


@end
