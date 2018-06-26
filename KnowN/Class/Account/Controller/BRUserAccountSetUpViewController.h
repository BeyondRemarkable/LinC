//
//  BRUserInfoSetUpViewController.h
//  KnowN
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BRRegisterType) {
    BRRegisterTypeEmail,
    BRRegisterTypeMobile
};

@interface BRUserAccountSetUpViewController : UIViewController

@property (nonatomic, assign) BRRegisterType registerType;

@end
