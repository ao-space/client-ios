//
//  YCCollectionViewController.m
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCCollectionViewController.h"
#import "YCItemDefine.h"
#import <Masonry/Masonry.h>

@interface YCCollectionViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) __kindof UICollectionViewLayout *flowLayout;

@end

@implementation YCCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _flowLayout = layout;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = NSMutableDictionary.dictionary;
}

- (void)setCellClass:(Class)cellClass {
    _cellClass = cellClass;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)setCellClassArray:(NSArray<Class> *)cellClassArray {
    [cellClassArray enumerateObjectsUsingBlock:^(Class _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self setCellClass:obj];
    }];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    if (self.section.count <= indexPath.section) {
        return nil;
    }
    NSString *key = self.section[indexPath.section];
    NSArray *cellArray = self.dataSource[key];
    if (cellArray.count <= indexPath.row) {
        return nil;
    }
    return cellArray[indexPath.row];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *key = self.section[section];
    return self.dataSource[key].count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.section.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    id<YCItemProtocol> data = [self objectAtIndexPath:indexPath];
    if ([data respondsToSelector:@selector(identifier)] && [data identifier]) {
        identifier = [data identifier];
    } else {
        identifier = NSStringFromClass(self.cellClass);
    }
    if (!data) {
        return [UICollectionViewCell new];
    }
    UICollectionViewCell<YCActionCallbackProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell ?: [UICollectionViewCell new];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell<YCActionCallbackProtocol> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    id<YCItemProtocol> data = [self objectAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(actionBlock)]) {
        __weak __typeof__(self) weak_self = self;
        [cell setActionBlock:^(id action) {
            [weak_self action:action atIndexPath:indexPath];
        }];
    }
    if ([cell respondsToSelector:@selector(reloadWithData:)]) {
        [cell reloadWithData:data];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.flowLayout.itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self action:nil atIndexPath:indexPath];
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
}

- (void)silenceReloadAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<YCActionCallbackProtocol> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(reloadWithData:)]) {
        [cell reloadWithData:[self objectAtIndexPath:indexPath]];
    }
}

- (void)pinView:(UIView *)view toView:(UIView *)toView attribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:toView
                                                                  attribute:attribute
                                                                 multiplier:1
                                                                   constant:0];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [toView addConstraint:constraint];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(110, 110);
        _flowLayout = flowLayout;
    }
    return _flowLayout;
}

@end
