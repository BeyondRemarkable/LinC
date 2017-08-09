//
//  BREmotionEscape.h
//  LinC
//
//  Created by Yingwei Fan on 8/9/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BREmotionEscape : NSObject

+ (BREmotionEscape *)sharedInstance;

+ (NSMutableAttributedString *) attributtedStringFromText:(NSString *) aInputText;

+ (NSAttributedString *) attStringFromTextForChatting:(NSString *) aInputText;

+ (NSAttributedString *) attStringFromTextForInputView:(NSString *) aInputText;

- (NSAttributedString *) attStringFromTextForChatting:(NSString *) aInputText textFont:(UIFont*)font;

- (NSAttributedString *) attStringFromTextForInputView:(NSString *) aInputText textFont:(UIFont*)font;

- (void) setBREmotionEscapePattern:(NSString*)pattern;

- (void) setBREmotionEscapeDictionary:(NSDictionary*)dict;

@end

@interface EMTextAttachment : NSTextAttachment

@property(nonatomic, strong) NSString *imageName;

@end
