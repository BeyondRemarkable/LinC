//
//  WhatsUpViewController.h
//  KnowN
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRWhatsUpViewControllerDelegate <NSObject>
@optional
- (void)whatsUpDidChangeTo:(NSString *)newWhatsUp;

@end


@interface BRWhatsUpViewController : UIViewController

@property (nonatomic, assign) NSString *whatUpText;

@property (nonatomic, weak) id<BRWhatsUpViewControllerDelegate> delegate;

@end
