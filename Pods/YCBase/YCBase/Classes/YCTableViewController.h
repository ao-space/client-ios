//
//  YCTableViewController.h
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCViewController.h"
#import <UIKit/UIKit.h>

@interface YCTableViewController : YCViewController <UITableViewDelegate, UITableViewDataSource>

#pragma mark - Style

- (instancetype)initWithStyle:(UITableViewStyle)style;

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) BOOL pullToRefresh;

#pragma mark - Load More

@property (nonatomic, assign) BOOL pullToLoadMore;

- (void)loadMoreData;

@property (nonatomic, assign) BOOL autoLoadMore;

#pragma mark - Data Source

@property (nonatomic, strong) NSArray /* <NSString *> or <NSNumber *> */ *section;

@property (nonatomic, strong) NSMutableDictionary<id, NSArray *> *dataSource;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Reuse Identifier

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, copy) NSArray<Class> *cellClassArray;

@property (nonatomic, readonly) NSArray<NSString *> *cellIdentifierArray;

#pragma mark - Action

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Reload

- (void)reloadIndexPath:(NSIndexPath *)indexPath;

- (void)silentReloadIndexPath:(NSIndexPath *)indexPath;

- (void)reloadIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeIndexPath:(NSIndexPath *)indexPath;

- (void)reloadDataAndKeepOffset;

#pragma mark - Delete
- (BOOL)canEditingStyleDelete;
- (void)deleteSelectIndexPath:(NSIndexPath *)indexPath;


@end
