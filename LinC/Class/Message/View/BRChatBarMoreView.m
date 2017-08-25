//
//  BRChatBarMoreView.m
//  LinC
//
//  Created by Yingwei Fan on 8/25/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRChatBarMoreView.h"
#import "BRChatBarMoreViewCell.h"

#define MOREVIEW_ITEM_SIZE CGSizeMake(50,60)
#define INSETS 10
#define PADDING 25

@implementation UIView (MoreView)

- (void)removeAllSubview
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface BRChatBarMoreView () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    BRChatToolbarType _type;
    NSInteger _maxIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation BRChatBarMoreView

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    BRChatBarMoreView *moreView = [self appearance];
    moreView.moreViewBackgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(BRChatToolbarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self setupSubviewsForType:_type];
    }
    return self;
}

- (void)setupSubviewsForType:(BRChatToolbarType)type
{
    //self.backgroundColor = [UIColor clearColor];
    self.accessibilityIdentifier = @"more_view";
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.minimumLineSpacing = INSETS;
    _layout.minimumInteritemSpacing = PADDING;
    _layout.itemSize = MOREVIEW_ITEM_SIZE;
    _layout.sectionInset = UIEdgeInsetsMake(INSETS, PADDING, INSETS + PADDING, PADDING);
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"BRChatBarMoreViewCell" bundle:nil] forCellWithReuseIdentifier:[BRChatBarMoreViewCell cellReuseIdentifier]];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    
}

- (void)setMoreViewBackgroundColor:(UIColor *)moreViewBackgroundColor
{
    _moreViewBackgroundColor = moreViewBackgroundColor;
    if (_moreViewBackgroundColor) {
        [self setBackgroundColor:_moreViewBackgroundColor];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_type == BRChatToolbarTypeChat) {
        return 5;
    }
    else if (_type == BRChatToolbarTypeGroup) {
        return 3;
    }
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRChatBarMoreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BRChatBarMoreViewCell cellReuseIdentifier] forIndexPath:indexPath];
    
    switch (indexPath.item) {
        case 0:
            [cell.imageView setImage:[UIImage imageNamed:@"location"]];
            cell.titleLabel.text = NSLocalizedString(@"Location", nil);
            break;
            
        case 1:
            [cell.imageView setImage:[UIImage imageNamed:@"Camera"]];
            cell.titleLabel.text = NSLocalizedString(@"Camera", nil);
            break;
        
        case 2:
            [cell.imageView setImage:[UIImage imageNamed:@"Album"]];
            cell.titleLabel.text = NSLocalizedString(@"Album", nil);
            break;
            
        case 3:
            [cell.imageView setImage:[UIImage imageNamed:@"Voice"]];
            cell.titleLabel.text = NSLocalizedString(@"Voice", nil);
            break;
            
        case 4:
            [cell.imageView setImage:[UIImage imageNamed:@"Video"]];
            cell.titleLabel.text = NSLocalizedString(@"Video", nil);
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.item) {
        case 0:
            [self locationAction];
            break;
            
        case 1:
            [self takePicAction];
            break;
            
        case 2:
            [self photoAction];
            break;
            
        case 3:
            [self takeAudioCallAction];
            break;
            
        case 4:
            [self takeVideoCallAction];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark - action

- (void)takePicAction{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

- (void)takeAudioCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
        [_delegate moreViewAudioCallAction:self];
    }
}

- (void)takeVideoCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoCallAction:)]) {
        [_delegate moreViewVideoCallAction:self];
    }
}

@end
