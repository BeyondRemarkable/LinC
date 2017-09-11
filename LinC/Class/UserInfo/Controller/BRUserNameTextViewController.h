//
//  UserNameTextViewController.h
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendUserNameProtocol <NSObject>

- (void)sendUserNameBack:(NSString *)userName;

@end

@interface BRUserNameTextViewController : UIViewController

@property (nonatomic, copy) NSString *nameText;

@property(nonatomic,assign)id delegate;

@end
