//
//  BRConfUserSelectionViewController.h
//
//  Copyright © 2018 Zhe Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
@protocol BRConfSelectionUserViewDelegate <NSObject>

- (void)deselectUser:(NSString *)aUserName;

@end

@interface BRConfSelectionUserView : UIView

@property (weak, nonatomic) id<BRConfSelectionUserViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *userID;
@end

@interface BRConfUserSelectionViewController : UIViewController
{
    MBProgressHUD *hud;
}
@property (copy) void (^selecteUserFinishedCompletion)(NSArray *selectedUsers);

- (instancetype)initWithDataSource:(NSArray *)aDataSource
                     selectedUsers:(NSArray *)aSelectedUsers andCreateCon:(BOOL) isCreateCon andGroupID:(NSString *)groupID;
- (instancetype)initWithInviteMoreMembers:(NSArray *)aDataSource
                            selectedUsers:(NSArray *)aSelectedUsers andCreateCon:(BOOL) isCreateCon andGroupID:(NSString *)groupID;
@end
