//
//  BRMediaBrowserViewController.m
//  LinC
//
//  Created by Yingwei Fan on 8/15/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRMediaBrowserViewController.h"
#import "BRMediaCell.h"

@interface BRMediaBrowserViewController () <BRMediaCellDelegate>

@property (nonatomic, strong) NSArray *mediaArray;

@end

@implementation BRMediaBrowserViewController

static NSString * const reuseIdentifier = @"BRMediaCell";

- (instancetype)initWithMediaArray:(NSArray *)mediaArray {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.mediaArray = mediaArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.contentMode = UIViewContentModeCenter;
    
    // Register cell classes
    [self.collectionView registerClass:[BRMediaCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    BRMedia *media = [self.mediaArray objectAtIndex:indexPath.item];
    cell.delegate = self;
    cell.media = media;
    
    return cell;
}

#pragma mark - BRMediaCell delegate
- (void)mediaCell:(BRMediaCell *)cell didClickBackButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaCell:(BRMediaCell *)cell didTapImage:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
