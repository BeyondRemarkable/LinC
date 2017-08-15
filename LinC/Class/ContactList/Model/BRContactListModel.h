//
//  ContactListModel.h
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRContactListModel : NSObject

@property (nonatomic, retain) NSString *iconURL;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userID;


- (void)loadWithDictionary:(NSDictionary *)dict;


@end
