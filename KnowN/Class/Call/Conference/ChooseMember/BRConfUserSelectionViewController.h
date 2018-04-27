//
//  EMConfUserSelectionViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 8/31/16.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@property (copy) void (^selecteUserFinishedCompletion)(NSArray *selectedUsers);

- (instancetype)initWithDataSource:(NSArray *)aDataSource
                     selectedUsers:(NSArray *)aSelectedUsers andCreateCon:(BOOL) isCreateCon;

@end
