//
//  UserGenderViewController.h
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendGenderProtocol <NSObject>

- (void)sendGenderBack:(NSString *)gender;

@end

@interface BRUserGenderViewController : UIViewController

@property (assign, nonatomic) BOOL isMale;

@property(nonatomic,assign)id delegate;

@end
