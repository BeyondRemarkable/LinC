//
//  BRLocationViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLocationViewController.h"
#import <MBProgressHUD.h>

static BRLocationViewController *defaultLocation = nil;

@interface BRLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isSendLocation;
    
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation BRLocationViewController

@synthesize addressString = _addressString;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    
    return self;
}

+ (instancetype)defaultLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocation = [[BRLocationViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return defaultLocation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewAction:)];
    [self.view addGestureRecognizer:_tapRecognizer];
    _endEditingWhenTap = YES;
    
    self.title = NSLocalizedString(@"location.messageType", @"location message");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    if (_isSendLocation) {
        _mapView.showsUserLocation = YES;//显示当前位置
        
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [sendButton setTitle:NSLocalizedString(@"send", @"Send") forState:UIControlStateNormal];
        sendButton.accessibilityIdentifier = @"send_location";
        [sendButton setTitleColor:[UIColor colorWithRed:32 / 255.0 green:134 / 255.0 blue:158 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [sendButton addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:sendButton]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self startLocation];
    }
    else{
        [self removeToLocation:_currentLocationCoordinate];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [hud hideAnimated:YES];
    if (error.code == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
        default:
            break;
    }
}

#pragma mark - public

/*!
 @method
 @brief 开启定位
 */
- (void)startLocation
{
    if([CLLocationManager locationServicesEnabled]){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"location.ongoning", @"locating...");
}

/*!
 @method
 @brief 地图添加大头针
 @param coords  位置信息
 */
-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    [_mapView addAnnotation:_annotation];
}

/*!
 @method
 @brief 大头针移动到指定位置
 @param locationCoordinate  指定位置
 */
- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [hud hideAnimated:YES];
    
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (void)sendLocation
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocationLatitude:longitude:andAddress:)]) {
        [_delegate sendLocationLatitude:_currentLocationCoordinate.latitude longitude:_currentLocationCoordinate.longitude andAddress:_addressString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setter

- (void)setEndEditingWhenTap:(BOOL)endEditingWhenTap
{
    if (_endEditingWhenTap != endEditingWhenTap) {
        _endEditingWhenTap = endEditingWhenTap;
        
        if (_endEditingWhenTap) {
            [self.view addGestureRecognizer:self.tapRecognizer];
        }
        else{
            [self.view removeGestureRecognizer:self.tapRecognizer];
        }
    }
}

#pragma mark - action

- (void)tapViewAction:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

@end