//
//  UIView+Animation.m
//  LinC
//
//  Created by zhe wu on 9/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)shakeAnimation {
    
    self.transform = CGAffineTransformMakeTranslation(15, 0);
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.15 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
