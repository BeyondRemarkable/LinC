//
//  BRMediaBrowserViewController.h
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRMedia.h"

@interface BRMediaBrowserViewController : UICollectionViewController

- (instancetype)initWithMediaArray:(NSArray *)mediaArray;

@end
