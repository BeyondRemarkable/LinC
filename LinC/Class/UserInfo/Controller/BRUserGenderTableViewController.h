//
//  UserGenderViewController.h
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRUserGenderTableViewControllerDelegate <NSObject>

- (void)genderDidChangeTo:(NSString *)newGender;

@end

@interface BRUserGenderTableViewController : UITableViewController



@property (nonatomic, weak) id<BRUserGenderTableViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL status;
@property (nonatomic, copy) NSString *gender;


@end
