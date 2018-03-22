//
//  BRMediaBrowserViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMediaBrowserViewController.h"
#import "BRMediaCell.h"
#import "IMessageModel.h"

@interface BRMediaBrowserViewController () <BRMediaCellDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *modelArray;

@end

@implementation BRMediaBrowserViewController

static NSString * const reuseIdentifier = @"BRMediaCell";

- (instancetype)initWithModelArray:(NSArray *)modelArray {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
//    if (@available(iOS 11.0, *)) {
//        layout.sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromContentInset;
//    }
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if (@available(iOS 11.0, *)) {
        layout.sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromContentInset;
    } else {
        // Fallback on earlier versions
    }
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.modelArray = modelArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Register cell classes
    [self.collectionView registerClass:[BRMediaCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    id<IMessageModel> model = [self.modelArray objectAtIndex:indexPath.item];
    cell.model = model;
    
    return cell;
}

#pragma mark - BRMediaCell delegate
- (void)mediaCell:(BRMediaCell *)cell didClickBackButton:(UIButton *)button {
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)mediaCell:(BRMediaCell *)cell didTapImage:(UIImage *)image {
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
