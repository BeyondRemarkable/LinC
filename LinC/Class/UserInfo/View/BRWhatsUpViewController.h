//
//  WhatsUpViewController.h
//  LinC
//
//  Created by zhe wu on 8/14/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendWhatUpProtocol <NSObject>

- (void)sendWhatUpBack: (NSString *)text;

@end


@interface BRWhatsUpViewController : UIViewController

@property (nonatomic, assign) NSString *whatUpText;

@property (nonatomic, assign) id delegate;

@end
