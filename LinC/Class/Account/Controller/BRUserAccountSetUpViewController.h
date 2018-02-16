//
//  BRUserInfoSetUpViewController.h
//  LinC
//
//  Created by zhe wu on 8/21/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BRRegisterTypeEmail,
    BRRegisterTypeMobile
} BRRegisterType;

@interface BRUserAccountSetUpViewController : UIViewController

@property (nonatomic, assign) BRRegisterType registerType;

@end
