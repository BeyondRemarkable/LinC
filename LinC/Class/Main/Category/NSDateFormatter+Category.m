//
//  NSDateFormatter+Category.m
//  LinC
//
//  Created by Yingwei Fan on 8/8/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "NSDateFormatter+Category.h"

@implementation NSDateFormatter (Category)

+ (id)dateFormatter
{
    return [[self alloc] init];
}

+ (id)dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)defaultDateFormatter
{
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

@end
