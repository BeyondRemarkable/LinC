//
//  BRGroupIconGenerator.m
//  KnowN
//
//  Created by zhe wu on 1/31/18.
//  Copyright © 2018 BeyondRemarkable. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BRGroupIconGenerator.h"

@implementation BRGroupIconGenerator

/**
 生成群头像
 
 @param imageArray 群成员头像数组
 */
+ (UIImage *)groupIconGenerator:(NSMutableArray *)imageArray {
    
    NSMutableArray *positionForImageArray = [self initImageposition: imageArray.count];
    return [self makeGroupAvatar:imageArray withPosition:positionForImageArray];
    
}

/**
 初始化图片在UIView中图片的坐标
 
 @param numberOfImage 群成员数量
 */
+ (NSMutableArray *)initImageposition:(NSInteger)numberOfImage{
    
    NSMutableArray *positionForImageArray = [NSMutableArray array];
    
    switch (numberOfImage) {
        case 1:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 4, 185, 185)]];
            break;
        case 2:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 57.5, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(98.5, 57.5, 90.5, 90.5)]];
            break;
        case 3:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(47.5, 4, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 98.5, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(98.5, 98.5, 90.5, 90.5)]];
            break;
        case 4:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 4, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(98.5, 4, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 98.5, 90.5, 90.5)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(98.5, 98.5, 90.5, 90.5)]];
            break;
        case 5:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(35.5, 33.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(98.5, 33.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 96.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 96.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(132, 96.5, 59, 59)]];
            break;
        case 6:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 37.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 37.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 37.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 100.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 100.5, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 100.5, 59, 59)]];
            break;
        case 7:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 130, 59, 59)]];
            break;
        case 8:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 130, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 130, 59, 59)]];
            break;
        case 9:
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 4, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 67, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(4, 130, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(67, 130, 59, 59)]];
            [positionForImageArray addObject:[NSValue valueWithCGRect:CGRectMake(130, 130, 59, 59)]];
            break;
        default:
            break;
    }
    return positionForImageArray;
}

/**
 把成员头像拼接成群头像
 
 @param imageArray 群成员头像数组
 @param positionArray 群成员头像的拼接坐标
 */
+ (UIImage *)makeGroupAvatar: (NSMutableArray *)imageArray withPosition:(NSMutableArray *)positionArray {
    //数组为空，退出函数
    if ([imageArray count] == 0){
        return nil;
    }
    
    UIView *groupAvatarView = [[UIView alloc]initWithFrame:CGRectMake(0,0,193,193)];
    groupAvatarView.backgroundColor = [UIColor lightGrayColor];
    UIImageView *tempImageView;
    for (int i = 0; i < [imageArray count]; i++){
        if (positionArray[i]) {
            tempImageView = [[UIImageView alloc]initWithFrame:[[positionArray objectAtIndex:i] CGRectValue]];
            
            [tempImageView setImage:[imageArray objectAtIndex:i]];
            [groupAvatarView addSubview:tempImageView];
        }
        
    }
    
    //把UIView设置为image并修改图片大小55*55
    UIImage *reImage = [self scaleToSize:[self convertViewToImage:groupAvatarView]size:CGSizeMake(55, 55)];
    
    return reImage;
}

+ (UIImage*)convertViewToImage:(UIView*)v{
    
    CGSize s = v.bounds.size;
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
    
    UIGraphicsBeginImageContextWithOptions(s, YES, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
    
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
