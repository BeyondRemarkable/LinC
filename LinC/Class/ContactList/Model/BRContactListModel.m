//
//  ContactListModel.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListModel.h"
#import "BRClientManager.h"

@implementation BRContactListModel

- (void)loadWithDictionary:(NSDictionary *)dict
{
    
}

- (instancetype)initWithBuddy:(NSString *)buddy
{
    _buddy = buddy;
    _username = buddy;
    return self;
}


@end
