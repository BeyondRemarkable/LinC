//
//  UIView+Animation.m
//  KnowN
//
//  Created by zhe wu on 9/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)shakeAnimation {
    
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint currentPoint = self.layer.position;
    keyframeAnimation.values = @[[NSValue valueWithCGPoint:currentPoint],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x - 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x + 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x - 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x + 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x - 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:CGPointMake(currentPoint.x + 10, currentPoint.y)],
                                 [NSValue valueWithCGPoint:currentPoint]];
    keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    keyframeAnimation.duration = 0.4f;
    [self.layer addAnimation:keyframeAnimation forKey:keyframeAnimation.keyPath];
}

@end
