//
//  BRConvertToCommonEmoticonsHelper.h
//  KnowN
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRConvertToCommonEmoticonsHelper : NSObject

/*!
 @method
 @brief 系统emoji表情转换为表情编码
 @param text   待转换的文字
 @return  转换后的文字
 */
+ (NSString *)convertToCommonEmoticons:(NSString *)text;

/*!
 @method
 @brief 表情编码转换为系统emoji表情
 @param text   待转换的文字
 @return  转换后的文字
 */
+ (NSString *)convertToSystemEmoticons:(NSString *)text;

@end
