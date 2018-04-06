//
//  NSString+Helper.m
//  KnowN
//
//  Created by Yingwei Fan on 4/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)trimString {
    // 移除字符串中所有空白字符(空格，\t，\n，\r)
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
