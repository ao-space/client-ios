//
//  YCTableViewController.m
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCTableViewController.h"
#import "Availability.h"
#import "YCItemDefine.h"
#import <Masonry/Masonry.h>

@interface YCTableViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *cellIdentifierArray;

@property (nonatomic, assign) UITableViewStyle style;

@end

@implementation YCTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super init];
    if (self) {
        _style = style;
        _cellHeight = 60;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (void)loadMoreData {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //data source
    _section = _section ?: @[];
    _dataSource = [@{} mutableCopy];

    //table view style
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.backgroundColor = [UIColor whiteColor];

}

#pragma mark - Cell

- (void)setCellClass:(Class)cellClass {
    _cellClass = cellClass;
    if (cellClass) {
        [_tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    }
}

- (void)setCellClassArray:(NSArray<Class> *)cellClassArray {
    NSMutableArray *cellIdentifierArray = [NSMutableArray array];
    [cellClassArray enumerateObjectsUsingBlock:^(Class _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self setCellClass:obj];
        [cellIdentifierArray addObject:NSStringFromClass(obj)];
    }];
    _cellClassArray = cellClassArray;
    _cellIdentifierArray = cellIdentifierArray;
}

- (void)setSection:(NSArray *)section {
    _section = section;
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = self.section.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<YCItemProtocol> item = [self objectAtIndexPath:indexPath];
    if ([item respondsToSelector:@selector(height)]) {
        return item.height > 0 ? item.height : _cellHeight;
    }
    return _cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.section.count <= section) {
        return 0;
    }
    return self.dataSource[self.section[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    id<YCItemProtocol> data = [self objectAtIndexPath:indexPath];
    if ([data respondsToSelector:@selector(identifier)] && [data identifier]) {
        identifier = [data identifier];
    } else {
        identifier = NSStringFromClass(self.cellClass);
    }
    if (!data) {
        return [UITableViewCell new];
    }
    UITableViewCell<YCActionCallbackProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //NSParameterAssert(cell);
    return cell ?: [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell<YCActionCallbackProtocol> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self action:nil atIndexPath:indexPath];
}

- (void)reloadIndexPath:(NSIndexPath *)indexPath {
    [self reloadIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

- (void)silentReloadIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<YCActionCallbackProtocol> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell reloadWithData:[self objectAtIndexPath:indexPath]];
}

- (void)reloadIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)removeIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    if (self.section.count <= indexPath.section) {
        return;
    }
    NSString *key = self.section[indexPath.section];
    NSMutableArray *cellArray = (NSMutableArray *)self.dataSource[key];
    if (cellArray.count <= indexPath.row) {
        return;
    }
    if ([cellArray isKindOfClass:[NSMutableArray class]]) {
        [cellArray removeObjectAtIndex:indexPath.row];
    } else if ([cellArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableCellArray = [cellArray mutableCopy];
        [mutableCellArray removeObjectAtIndex:indexPath.row];
        self.dataSource[key] = mutableCellArray;
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
}

- (void)reloadDataAndKeepOffset {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    CGSize beforeContentSize = self.tableView.contentSize;
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    CGSize afterContentSize = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    CGPoint newOffset = CGPointMake(contentOffset.x + (afterContentSize.width - beforeContentSize.width), contentOffset.y + (afterContentSize.height - beforeContentSize.height));
    [self.tableView setContentOffset:newOffset animated:NO];
}

#pragma mark - Did Set

#pragma mark - Lazy Load

- (UITableView *)tableView {
    if (!self.viewLoaded) {
        return nil;
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.style];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        if (_style == UITableViewStyleGrouped) {
            _tableView.sectionFooterHeight = 0;
            _tableView.sectionHeaderHeight = 0;
        }
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
#ifdef __IPHONE_15_0
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
#endif
        if (self.cellClassArray) {
            self.cellClassArray = self.cellClassArray;
        } else if (self.cellClass) {
            self.cellClass = self.cellClass;
        }
    }
    return _tableView;
}

@end
