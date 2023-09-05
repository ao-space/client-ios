/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESFilePageContentView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//
#import "ESFilePageContentView.h"
#import "ESColor.h"

#define kCellID @"kCellID"
@interface ESFilePageContentView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *childVcs;

@property (nonatomic, weak) UIViewController *parentViewController;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) CGFloat startOffset;

@end
@implementation ESFilePageContentView
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = self.bounds.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = true;
        _collectionView.bounces = NO;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        // 创建 UIRefreshControl
          self.refreshControl = [[UIRefreshControl alloc] init];
          self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
          [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

          // 将 UIRefreshControl 添加到 UICollectionView
          [_collectionView addSubview:self.refreshControl];
        [_collectionView registerClass:UICollectionViewCell.self forCellWithReuseIdentifier:kCellID];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        
    }
    return _collectionView;
}

+ (instancetype)initWithFrame:(CGRect)frame ChildViewControllers:(NSMutableArray *)controllers parentViewController:(UIViewController *)parentVc {
    ESFilePageContentView *pageContentView = [[ESFilePageContentView alloc] initWithFrame:frame];
    pageContentView.childVcs = controllers;
    pageContentView.parentViewController = parentVc;
    pageContentView.startOffset = 0;
    [pageContentView setUpUI];
    return pageContentView;
}

- (void)childViewControllers:(NSMutableArray *)controllers parentViewController:(UIViewController *)parentVc {
    self.childVcs = controllers;
    self.parentViewController = parentVc;
    self.startOffset = 0;
    [self setUpUI];
}
#pragma mark -set up UI method

- (void)setUpUI {
    for (UIViewController *vc in self.childVcs) {
        [self.parentViewController addChildViewController:vc];
    }
    [self addSubview:self.collectionView];
    self.collectionView.frame = self.bounds;
    self.backgroundColor = ESColor.secondarySystemBackgroundColor;
}
#pragma mark - collectionView data source's method

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.childVcs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    UIViewController *childVc = self.childVcs[indexPath.item];

    if (self.vcFrame.size.height > 0) {
        childVc.view.frame = self.vcFrame;
    } else {
        childVc.view.frame = cell.bounds;
    }

    [cell.contentView addSubview:childVc.view];
    return cell;
}
#pragma mark - collection View delegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //获取数据

    CGFloat progress = 0;
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;

    //判断左右滑
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    if (currentOffsetX > self.startOffset) {
        //左滑
        progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        sourceIndex = (NSInteger)(currentOffsetX / scrollViewW);
        targetIndex = sourceIndex;
        if (targetIndex >= self.childVcs.count) {
            targetIndex = self.childVcs.count - 1;
        }
        if (currentOffsetX - self.startOffset == scrollViewW) {
            progress = 1;
            targetIndex = sourceIndex;
        }
    } else {
        //右滑
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        targetIndex = (NSInteger)(currentOffsetX / scrollViewW);
        sourceIndex = targetIndex + 1;
        if (sourceIndex >= self.childVcs.count) {
            sourceIndex = self.childVcs.count - 1;
        }
    }
    [self.delegate pageContentView:self progress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.startOffset = scrollView.contentOffset.x;
}
#pragma mark -set current index
- (void)setCurrentIndex:(NSInteger)index {
    CGFloat offsetX = index * self.collectionView.frame.size.width;
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0)];
}


- (void)refreshData {
    [self.refreshControl endRefreshing];
}

@end
