//
//  YCCollectionView.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#import "YCCollectionView.h"

@interface YCCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) __kindof UICollectionViewLayout *flowLayout;

@end

@implementation YCCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _section = @[YCCollectionViewSingleSectionKey];
        _dataSource = [@{YCCollectionViewSingleSectionKey: @[]} mutableCopy];
        _flowLayout = layout;
    }
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    return [self initWithFrame:CGRectZero collectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame collectionViewLayout:nil];
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
    if ([self.delegate respondsToSelector:@selector(collectionView:objectAtIndexPath:)]) {
        return [self.delegate collectionView:self objectAtIndexPath:indexPath];
    }
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
    if ([self.delegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        return [self.delegate collectionView:self numberOfItemsInSection:section];
    }
    NSString *key = self.section[section];
    return self.dataSource[key].count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.section.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    if (self.reuseIdentifierBlock) {
        identifier = self.reuseIdentifierBlock(indexPath);
    } else {
        identifier = NSStringFromClass(self.cellClass);
    }
    UICollectionViewCell<YCCollectionViewCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell ?: [UICollectionViewCell new];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell<YCCollectionViewCellProtocol> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weak_self = self;
    if ([cell respondsToSelector:@selector(willDisplayBlock)]) {
        __weak typeof(cell) weak_cell = cell;
        cell.willDisplayBlock = ^{
            if (weak_self.customCellBlock) {
                weak_self.customCellBlock(indexPath, weak_cell);
            } else {
                if ([weak_self.delegate respondsToSelector:@selector(collectionView:willDisplayCell:indexPath:)]) {
                    [weak_self.delegate collectionView:weak_self willDisplayCell:weak_cell indexPath:indexPath];
                }
            }
        };
    } else {
        if (weak_self.customCellBlock) {
            weak_self.customCellBlock(indexPath, cell);
        } else {
            if ([weak_self.delegate respondsToSelector:@selector(collectionView:willDisplayCell:indexPath:)]) {
                [weak_self.delegate collectionView:weak_self willDisplayCell:cell indexPath:indexPath];
            }
        }
    }
    if ([cell respondsToSelector:@selector(reloadWithData:)]) {
        [cell reloadWithData:[self objectAtIndexPath:indexPath]];
    }
    if ([self.delegate respondsToSelector:@selector(collectionView:didDisplayCell:indexPath:)]) {
        [self.delegate collectionView:self didDisplayCell:cell indexPath:indexPath];
    }
    if ([cell respondsToSelector:@selector(actionBlock)]) {
        [cell setActionBlock:^(id action) {
            [weak_self action:action atIndexPath:indexPath];
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        CGSize size = [self.delegate collectionView:self layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    return self.flowLayout.itemSize;
}

- (UICollectionReusableView *)collectionView:(YCCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        return [self.delegate collectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [self.delegate collectionView:self layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
    if (collectionViewLayout == self.flowLayout) {
        return self.flowLayout.headerReferenceSize;
    }
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [self.delegate collectionView:self layout:collectionViewLayout referenceSizeForFooterInSection:section];
    }
    if (collectionViewLayout == self.flowLayout) {
        return self.flowLayout.footerReferenceSize;
    }
    return CGSizeMake(0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate collectionView:self didSelectItemAtIndexPath:indexPath];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(collectionView:action:atIndexPath:)]) {
        id item = [self objectAtIndexPath:indexPath];
        [self.delegate collectionView:self action:item atIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:action:atIndexPath:)]) {
        [self.delegate collectionView:self action:action atIndexPath:indexPath];
        return;
    }
    if (self.actionBlock) {
        self.actionBlock(@{@"action": action ?: @"undefined",
                           @"indexPath": indexPath});
    }
}

- (void)silenceReloadAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<YCCollectionViewCellProtocol> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
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
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        [self pinView:_collectionView toView:self attribute:NSLayoutAttributeLeft];
        [self pinView:_collectionView toView:self attribute:NSLayoutAttributeRight];
        [self pinView:_collectionView toView:self attribute:NSLayoutAttributeTop];
        [self pinView:_collectionView toView:self attribute:NSLayoutAttributeBottom];
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
