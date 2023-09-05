//
//  YCGridView.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#import "YCGridView.h"
#import "NSArray+YCTools.h"
#import "YCCollectionView.h"

@interface YCGridViewItem ()

- (void)_privateSetThemeAttributes:(NSDictionary *)themeAttributes;

@end

typedef NS_OPTIONS(NSUInteger, YCGridViewOperation) {
    YCGridViewOperationNone = 0,
    YCGridViewOperationSelectedColumnTitle = 1 << 0,
    YCGridViewOperationSelectedRowTitle = 1 << 1,
    YCGridViewOperationSelectedCell = 1 << 1,
};

@interface YCGridView () <YCCollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *rightScrollView;

@property (nonatomic, strong) YCCollectionView *leftView;

@property (nonatomic, strong) YCCollectionView *rightView;

@property (nonatomic, strong) YCCollectionView *leftHeader;

@property (nonatomic, strong) YCCollectionView *rightHeader;

@property (nonatomic, strong) UIScrollView *rightHeaderScrollView;

@property (nonatomic, assign) NSUInteger rowCount;

@property (nonatomic, assign) NSUInteger columnCount;

@property (nonatomic, strong) NSArray *columnTitleArray;

@property (nonatomic, strong) NSArray *rowTitleArray;

@property (nonatomic, strong) NSArray<NSArray *> *cellArray;

@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, assign) NSInteger selectedColumn;

@property (nonatomic, assign) YCGridViewOperation operation;

@property (nonatomic, strong) Class cellClass;

@end

@implementation YCGridView

+ (instancetype)gridViewWithCellClass:(Class)cellClass {
    NSParameterAssert([cellClass isSubclassOfClass:[YCGridViewCell class]]);
    YCGridView *grid = [[YCGridView alloc] initWithFrame:CGRectZero cellClass:cellClass ?: [YCGridViewCell class]];
    return grid;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame cellClass:[YCGridViewCell class]];
}

- (instancetype)initWithFrame:(CGRect)frame cellClass:(Class)cellClass {
    self = [super initWithFrame:frame];
    if (self) {
        _selectedRow = YCGridViewNoSelection;
        _selectedColumn = YCGridViewNoSelection;
        _titleColumnWidth = 40;
        _cellColumnWidth = 40;
        _titleRowHeight = 40;
        _cellRowHeight = 40;
        _cellClass = cellClass;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.rightScrollView];
    [self.rightScrollView addSubview:self.rightView];
    [self addSubview:self.rightHeaderScrollView];
    [self.rightHeaderScrollView addSubview:self.rightHeader];
    [self addSubview:self.leftView];
    [self addSubview:self.leftHeader];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadUI];
}

- (void)reloadUI {
    _leftView.flowLayout.itemSize = CGSizeMake(_titleColumnWidth, _cellRowHeight);
    _rightView.flowLayout.itemSize = CGSizeMake(_cellColumnWidth, _cellRowHeight);
    _leftHeader.flowLayout.itemSize = CGSizeMake(_titleColumnWidth, _titleRowHeight);
    _rightHeader.flowLayout.itemSize = CGSizeMake(_cellColumnWidth, _titleRowHeight);
    __block CGFloat rightWidth = _cellColumnWidth * _columnCount + kYCGridViewExtraOffset; //add a left offset
    NSDictionary *columnTheme = self.extraThemeAttributes[YCGridViewColumnAttributeName];
    [columnTheme enumerateKeysAndObjectsUsingBlock:^(NSNumber *_Nonnull key,
                                                     NSDictionary *_Nonnull obj,
                                                     BOOL *_Nonnull stop) {
        NSNumber *value = obj[YCGridViewWidthAttributeName];
        if (value != nil) {
            rightWidth += value.floatValue - self.cellColumnWidth;
        }
    }];
    self.leftHeader.frame = CGRectMake(0, 0, self.titleColumnWidth, self.titleRowHeight);
    self.leftView.frame = CGRectMake(0, self.titleRowHeight, self.titleColumnWidth, self.bounds.size.height - self.titleRowHeight);
    CGFloat leftOffset = self.titleColumnWidth - kYCGridViewExtraOffset;

    self.rightScrollView.frame = CGRectMake(leftOffset, self.titleRowHeight, self.bounds.size.width - leftOffset - 1, self.bounds.size.height - self.titleRowHeight);
    self.rightView.frame = CGRectMake(0, 0, rightWidth, self.bounds.size.height - self.titleRowHeight);
    self.rightScrollView.contentSize = CGSizeMake(rightWidth, self.bounds.size.height - self.titleRowHeight);

    self.rightHeaderScrollView.frame = CGRectMake(leftOffset, 0, self.bounds.size.width - leftOffset - 1, self.titleRowHeight);
    self.rightHeader.frame = CGRectMake(0, 0, rightWidth, _titleRowHeight);
    self.rightHeaderScrollView.contentSize = CGSizeMake(rightWidth, _titleRowHeight);
}

- (void)reloadData {
    BOOL check = [self check];
    if (!check) {
        NSParameterAssert(check);
        return;
    }
    _selectedRow = YCGridViewNoSelection;
    _selectedColumn = YCGridViewNoSelection;
    NSArray *transform = [self.data yc_mapWithBlock:^id(NSUInteger index, id origin) {
        YCGridViewItem *item = [YCGridViewItem new];
        item.data = origin;
        item.selectedColor = self.selectedCellColor;
        return item;
    }];
    self.cellArray = [transform yc_selectWithBlock:^BOOL(NSUInteger index, YCGridViewItem *origin) {
        if (index != 0) {
            if ([origin isKindOfClass:[YCGridViewItem class]]) {
                origin.itemSize = CGSizeMake(self.cellColumnWidth, self.cellRowHeight);
                [origin _privateSetThemeAttributes:self.themeAttributes[YCGridViewRightCellAttributeName]];
            }
            return YES;
        }
        return NO;
    }];
    _columnCount = self.data.firstObject.count - 1;
    _rowCount = self.cellArray.count;
    self.rowTitleArray = [transform yc_selectWithBlock:^BOOL(NSUInteger index, YCGridViewItem *origin) {
                             if ([origin isKindOfClass:[NSArray class]]) {
                                 return YES;
                             }
                             if (index == 0) {
                                 [origin _privateSetThemeAttributes:self.themeAttributes[YCGridViewLeftCellAttributeName]];
                                 origin.itemSize = CGSizeMake(self.titleColumnWidth, self.titleRowHeight);
                                 return YES;
                             }
                             return NO;
                         }]
                             .yc_flattern;
    self.columnTitleArray = [transform.firstObject yc_mapWithBlock:^id(NSUInteger index, YCGridViewItem *origin) {
        if (index == 0) {
            [origin _privateSetThemeAttributes:self.themeAttributes[YCGridViewLeftTitleAttributeName]];
            origin.itemSize = CGSizeMake(self.titleColumnWidth, self.titleRowHeight);
        } else {
            [origin _privateSetThemeAttributes:self.themeAttributes[YCGridViewRightTitleAttributeName]];
            origin.itemSize = CGSizeMake(self.cellColumnWidth, self.titleRowHeight);
        }
        return origin;
    }];
    self.rowTitleArray = [self.rowTitleArray subarrayWithRange:NSMakeRange(1, _rowCount)];
    self.leftHeader.dataSource[YCCollectionViewSingleSectionKey] = @[self.columnTitleArray.firstObject];
    self.leftView.dataSource[YCCollectionViewSingleSectionKey] = self.rowTitleArray;
    self.rightHeader.dataSource[YCCollectionViewSingleSectionKey] = [self.columnTitleArray subarrayWithRange:NSMakeRange(1, _columnCount)];
    self.rightView.dataSource[YCCollectionViewSingleSectionKey] = [self.cellArray yc_flattern];
    [self.leftHeader reloadData];
    [self.rightHeader reloadData];
    [self.leftView reloadData];
    [self.rightView reloadData];
    [self reloadUI];
    if (self.rightView.dataSource[YCCollectionViewSingleSectionKey].count == 0) {
        self.emptyView.frame = self.rightView.bounds;
        self.rightView.collectionView.backgroundView = self.emptyView;
    } else {
        self.rightView.collectionView.backgroundView = nil;
    }
}

- (BOOL)check {
    NSUInteger count = self.data.firstObject.count;
    for (NSArray *obj in self.data) {
        if (obj.count != count) {
            return NO;
        }
    }
    return count >= 2 && self.data.count >= 1;
}

- (void)reloadRow:(NSInteger)row column:(NSInteger)column {
    //no selection, return
    if (row == YCGridViewNoSelection && column == YCGridViewNoSelection) {
        return;
    }
    NSMutableArray *cellArray = [NSMutableArray array];
    if (row == YCGridViewTitleRowIndex) { //selected first row
        [self.leftView.collectionView reloadData];
        return;
    } else if (row != YCGridViewNoSelection) { //selected some row
        if (column == YCGridViewNoSelection) { //the whole row
            for (NSUInteger index = 0; index < _columnCount; index++) {
                [cellArray addObject:[NSIndexPath indexPathForItem:(row * _columnCount + index) inSection:0]];
            }
        } else {
            [cellArray addObject:[NSIndexPath indexPathForItem:(row * _columnCount + column) inSection:0]];
        }
        [self.leftView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:row inSection:0]]];
    } else { //selected a column
        if (column != YCGridViewTitleColumnIndex) {
            for (NSUInteger index = 0; index < _rowCount; index++) {
                [cellArray addObject:[NSIndexPath indexPathForItem:(index * _columnCount + column) inSection:0]];
            }
        }
    }
    [self.rightView.collectionView reloadItemsAtIndexPaths:cellArray];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _leftView.collectionView) {
        _rightView.collectionView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    } else if (scrollView == _rightView.collectionView) {
        _leftView.collectionView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    }
    if (scrollView == _rightHeaderScrollView) {
        _rightScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    } else if (scrollView == _rightScrollView) {
        _rightHeaderScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

#pragma mark - YCCollectionView

- (id)collectionView:(YCCollectionView *)collectionView objectAtIndexPath:(NSIndexPath *)indexPath {
    YCGridViewPosition *position = [self positionInCollectionView:collectionView atIndexPath:indexPath];
    return position.item;
}

- (void)collectionView:(YCCollectionView *)collectionView action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    //init selection
    YCGridViewPosition *position = [self positionInCollectionView:collectionView atIndexPath:indexPath];
    NSInteger row = position.row;
    NSInteger column = position.column;
    YCGridViewItem *item = position.item;
    if ([self.delegate respondsToSelector:@selector(gridView:didSelectRow:column:data:)]) {
        [self.delegate gridView:self didSelectRow:row column:column data:item.data];
    }
    if (self.selectionMode == YCGridViewSelectionModeNone) {
        return;
    }
    //save old selection
    NSInteger oldRow = self.selectedRow;
    NSInteger oldColumn = self.selectedColumn;

    if (column == YCGridViewTitleColumnIndex) {
        if (oldRow != row) {
            [self clearSelectionWithRow:oldRow column:oldColumn];
        }
        self.selectedRow = row;
        self.selectedColumn = YCGridViewNoSelection; //means select whole row, reset `selectedColumn`
        self.operation |= YCGridViewOperationSelectedRowTitle;
        [self reloadRow:self.selectedRow column:self.selectedColumn];
        self.operation ^= YCGridViewOperationSelectedRowTitle;
        return;
    }
    if (row == YCGridViewTitleRowIndex) {
        if (oldColumn != column) {
            [self clearSelectionWithRow:oldRow column:oldColumn];
        }
        self.selectedColumn = column;
        self.selectedRow = YCGridViewNoSelection; //means select whole column, reset `selectedRow`
        self.operation |= YCGridViewOperationSelectedColumnTitle;
        [self reloadRow:self.selectedRow column:self.selectedColumn];
        self.operation ^= YCGridViewOperationSelectedColumnTitle;
        return;
    }
    if (self.selectionMode & YCGridViewSelectionModeColumn) {
        //in column selection mode, select the whole column, when touched in `cell area`,
        if (oldColumn != column) {
            [self clearSelectionWithRow:oldRow column:oldColumn];
        }
        self.selectedColumn = column;
        self.selectedRow = YCGridViewNoSelection;
        [self reloadRow:YCGridViewNoSelection column:self.selectedColumn];
    } else if (self.selectionMode & YCGridViewSelectionModeRow) {
        if (oldRow != row) {
            [self clearSelectionWithRow:oldRow column:oldColumn];
        }
        self.selectedRow = row;
        self.selectedColumn = YCGridViewNoSelection;
        [self reloadRow:self.selectedRow column:YCGridViewNoSelection];
    } else if (self.selectionMode & YCGridViewSelectionModeCell) {
        if (oldRow != row || oldColumn != column) {
            [self clearSelectionWithRow:oldRow column:oldColumn];
        }
        self.selectedRow = row;
        self.selectedColumn = column;
        [self reloadRow:self.selectedRow column:self.selectedColumn];
    } else if (self.selectionMode == YCGridViewSelectionModeNone) {
        if (oldRow != row || oldColumn != column) {
            [self clearSelectionWithRow:oldRow column:YCGridViewNoSelection];
            [self clearSelectionWithRow:YCGridViewNoSelection column:oldColumn];
        }
        self.selectedRow = row;
        self.selectedColumn = column;
        [self reloadRow:self.selectedRow column:self.selectedColumn];
    }
}

- (void)clearSelectionWithRow:(NSInteger)row column:(NSInteger)column {
    self.selectedRow = YCGridViewNoSelection;
    self.selectedColumn = YCGridViewNoSelection;
    [self reloadRow:YCGridViewNoSelection column:column];
    [self reloadRow:row column:YCGridViewNoSelection];
}

- (CGSize)collectionView:(YCCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCGridViewPosition *position = [self positionInCollectionView:collectionView atIndexPath:indexPath];
    NSDictionary *rowTheme = self.extraThemeAttributes[YCGridViewRowAttributeName];
    CGFloat heightOffset = 0;
    if (rowTheme) {
        NSDictionary *theme = rowTheme[@(position.row)];
        if (theme) {
            NSNumber *value = theme[YCGridViewWidthAttributeName];
            if (value != nil) {
                heightOffset = value.floatValue - _cellRowHeight;
            }
        }
    }
    NSDictionary *columnTheme = self.extraThemeAttributes[YCGridViewColumnAttributeName];
    CGFloat height = position.row == -1 ? _titleRowHeight : _cellRowHeight;
    CGFloat width = position.column == -1 ? _titleColumnWidth : _cellColumnWidth;
    CGFloat widthOffset = position.column == 0 ? kYCGridViewExtraOffset : 0;
    if (columnTheme) {
        NSDictionary *theme = columnTheme[@(position.column)];
        if (theme) {
            NSNumber *value = theme[YCGridViewWidthAttributeName];
            CGFloat configWidth = value != nil ? [value floatValue] : width;
            if (value != nil) {
                position.item.itemSize = CGSizeMake(width, _cellRowHeight);
            }
            configWidth += widthOffset;
            return CGSizeMake(configWidth, height + heightOffset);
        }
    }
    if (widthOffset > 0 || heightOffset > 0) {
        return CGSizeMake(width + widthOffset, height + heightOffset);
    }
    return CGSizeZero;
}

#pragma mark - Custom Cell

- (void)collectionView:(YCCollectionView *)collectionView willDisplayCell:(YCGridViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    YCGridViewPosition *position = [self positionInCollectionView:collectionView atIndexPath:indexPath];
    YCGridViewItem *item = position.item;
    NSInteger row = position.row;
    NSInteger column = position.column;
    if (position.column == 0) {
        item.columnPosition = YCGridViewCellTableColumnPositionFirst;
    } else if (position.column == _columnCount - 1) {
        item.columnPosition = YCGridViewCellTableColumnPositionLast;
    } else {
        item.columnPosition = YCGridViewCellTableColumnPositionMiddle;
    }
    if (!cell.data) {
        [cell presetData:item];
    }
    [self getSelectionStatusInCollectionView:collectionView position:position];
    [self updateExtraTheme:position cell:cell];
    if ([self.delegate respondsToSelector:@selector(gridView:willDisplayCell:row:column:)]) {
        [self.delegate gridView:self willDisplayCell:cell row:row column:column];
    }
}

- (void)getSelectionStatusInCollectionView:(YCCollectionView *)collectionView position:(YCGridViewPosition *)position {
    YCGridViewItem *item = position.item;
    NSInteger row = position.row;
    NSInteger column = position.column;
    //get selection status
    item.selected = NO;
    if (self.selectionMode & YCGridViewSelectionModeRow) {
        if ((self.selectedRow != YCGridViewNoSelection && row == self.selectedRow)) {
            item.selected = YES;
        }
    }
    if (self.selectionMode & YCGridViewSelectionModeColumn) {
        if ((self.selectedColumn != YCGridViewNoSelection && column == self.selectedColumn)) {
            item.selected = YES;
        }
    }
    if (self.selectionMode & YCGridViewSelectionModeCell) {
        if ((self.selectedRow != YCGridViewNoSelection && row == self.selectedRow) &&
            (self.selectedColumn != YCGridViewNoSelection && column == self.selectedColumn) &&
            collectionView == self.rightView) {
            item.selected = YES;
        }
    }
    if (self.selectedRow == YCGridViewTitleColumnIndex &&
        collectionView == _leftView) {
        item.selected = YES;
    }
    if (!(self.selectionMode & YCGridViewSelectionModeCell) &&
        column == YCGridViewTitleColumnIndex &&
        self.selectedRow == row) {
        item.selected = YES;
    }
    if (self.operation & YCGridViewOperationSelectedRowTitle && self.selectedRow == row) {
        item.selected = YES;
    }
    if (self.operation & YCGridViewOperationSelectedColumnTitle && self.selectedColumn == column) {
        item.selected = YES;
    }
}

- (void)updateExtraTheme:(YCGridViewPosition *)position cell:(YCGridViewCell *)cell {
    //custom extra theme
    NSDictionary *rowTheme = self.extraThemeAttributes[YCGridViewRowAttributeName];
    if (rowTheme) {
        NSDictionary *theme = rowTheme[@(position.row)];
        if (theme) {
            [cell.attributes setValuesForKeysWithDictionary:theme];
        }
    }
    NSDictionary *columnTheme = self.extraThemeAttributes[YCGridViewColumnAttributeName];
    if (columnTheme) {
        NSDictionary *theme = columnTheme[@(position.column)];
        if (theme) {
            [cell.attributes setValuesForKeysWithDictionary:theme];
        }
    }
    NSDictionary *rowAndColumnTheme = self.extraThemeAttributes[YCGridViewRowAndColumnAttributeName];
    if (rowAndColumnTheme) {
        NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)position.row, (long)position.column];
        NSDictionary *theme = rowAndColumnTheme[key];
        if (theme) {
            [cell.attributes setValuesForKeysWithDictionary:theme];
        }
    }
}

- (YCGridViewPosition *)positionInCollectionView:(YCCollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = YCGridViewNoSelection;
    NSInteger column = YCGridViewNoSelection;
    YCGridViewItem *item;
    if (collectionView == self.rightView) {
        row = indexPath.item / self.columnCount;
        column = indexPath.item - self.columnCount * row;
        item = self.cellArray[row][column];
    } else if (collectionView == self.leftView) {
        row = indexPath.item;
        column = YCGridViewTitleColumnIndex;
        item = self.rowTitleArray[row];
    } else if (collectionView == self.leftHeader) {
        row = YCGridViewTitleRowIndex;
        column = -1;
        item = self.columnTitleArray[0];
    } else if (collectionView == self.rightHeader) {
        row = YCGridViewTitleRowIndex;
        column = indexPath.row;
        item = self.columnTitleArray[column + 1];
    }
    YCGridViewPosition *position = [YCGridViewPosition new];
    position.row = row;
    position.column = column;
    position.item = item;
    return position;
}

- (void)collectionView:(YCCollectionView *)collectionView didDisplayCell:(YCGridViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(gridView:didDisplayCell:row:column:)]) {
        YCGridViewPosition *position = [self positionInCollectionView:collectionView atIndexPath:indexPath];
        [self.delegate gridView:self didDisplayCell:cell row:position.row column:position.column];
    }
}

#pragma mark - Did Set

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    _rightScrollView.bounces = _bounces;
    _rightHeaderScrollView.bounces = _bounces;
    _leftHeader.collectionView.bounces = _bounces;
    _rightHeader.collectionView.bounces = _bounces;
    _leftView.collectionView.bounces = _bounces;
    _rightView.collectionView.bounces = _bounces;
}

#pragma mark - Lazy Load

- (UIScrollView *)rightScrollView {
    if (_rightScrollView == nil) {
        _rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _rightScrollView.backgroundColor = [UIColor clearColor];
        _rightScrollView.directionalLockEnabled = YES;
        _rightScrollView.delegate = self;
        _rightScrollView.bounces = _bounces;
        _rightScrollView.showsHorizontalScrollIndicator = NO;
        _rightScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rightScrollView;
}

- (UIScrollView *)rightHeaderScrollView {
    if (_rightHeaderScrollView == nil) {
        _rightHeaderScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _rightHeaderScrollView.backgroundColor = [UIColor clearColor];
        _rightHeaderScrollView.directionalLockEnabled = YES;
        _rightHeaderScrollView.delegate = self;
        _rightHeaderScrollView.bounces = _bounces;
        _rightHeaderScrollView.alwaysBounceVertical = NO;
        _rightHeaderScrollView.alwaysBounceHorizontal = NO;
        _rightHeaderScrollView.showsHorizontalScrollIndicator = NO;
        _rightHeaderScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rightHeaderScrollView;
}

- (YCCollectionView *)leftView {
    if (_leftView == nil) {
        _leftView = [self buildinCollectionView];
        _leftView.flowLayout.itemSize = CGSizeMake(_titleColumnWidth, _cellRowHeight);
    }
    return _leftView;
}

- (YCCollectionView *)rightView {
    if (_rightView == nil) {
        _rightView = [self buildinCollectionView];
        _rightView.flowLayout.itemSize = CGSizeMake(_cellColumnWidth, _cellRowHeight);
    }
    return _rightView;
}

- (YCCollectionView *)leftHeader {
    if (_leftHeader == nil) {
        _leftHeader = [self buildinCollectionView];
        _leftHeader.flowLayout.itemSize = CGSizeMake(_titleColumnWidth, _titleRowHeight);
    }
    return _leftHeader;
}

- (YCCollectionView *)rightHeader {
    if (_rightHeader == nil) {
        _rightHeader = [self buildinCollectionView];
        _rightHeader.flowLayout.itemSize = CGSizeMake(_cellColumnWidth, _titleRowHeight);
    }
    return _rightHeader;
}

- (YCCollectionView *)buildinCollectionView {
    YCCollectionView *collectionView = [[YCCollectionView alloc] initWithFrame:CGRectZero];
    collectionView.delegate = self;
    [self customLayout:collectionView.flowLayout];
    collectionView.collectionView.bounces = _bounces;
    collectionView.collectionView.showsVerticalScrollIndicator = NO;
    collectionView.cellClass = _cellClass;
    collectionView.backgroundColor = [UIColor clearColor];
    return collectionView;
}

- (void)customLayout:(UICollectionViewFlowLayout *)flowLayout {
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
}

@end
