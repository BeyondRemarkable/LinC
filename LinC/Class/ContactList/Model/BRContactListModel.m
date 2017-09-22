//
//  ContactListModel.m
//  LinC
//
//  Created by zhe wu on 8/10/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRContactListModel.h"

@implementation BRContactListModel


- (instancetype)initWithBuddy:(NSString *)buddy
{
    self.username = buddy;
    return self;
}


@end
