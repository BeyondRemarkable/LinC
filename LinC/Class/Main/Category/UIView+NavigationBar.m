//
//  UIView+NavigationBar.m
//  LinC
//
//  Created by Yingwei Fan on 1/31/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//

#import "UIView+NavigationBar.h"

@implementation UIView (NavigationBar)

- (void)addNavigationBarConstraintsWithWidth:(CGFloat)width height:(CGFloat)height {
    if (width == 0 || height == 0) {
        return;
    }
    
    NSLayoutConstraint *widthConstraint = [self.widthAnchor constraintEqualToConstant:width];
    NSLayoutConstraint *heightConstraint = [self.heightAnchor constraintEqualToConstant:height];
    widthConstraint.active = YES;
    heightConstraint.active = YES;
}

@end
