//
//  BRLocationViewController.h
//  KnowN
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol BRLocationViewDelegate <NSObject>

/*!
 @method
 @brief 发送位置信息的回调
 @param latitude    纬度
 @param longitude   经度
 @param address     地址信息
 */
-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface BRLocationViewController : UIViewController

@property (strong, nonatomic) NSArray *rightItems;

//default YES;
@property (nonatomic) BOOL endEditingWhenTap;

@property (nonatomic, assign) id<BRLocationViewDelegate> delegate;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
