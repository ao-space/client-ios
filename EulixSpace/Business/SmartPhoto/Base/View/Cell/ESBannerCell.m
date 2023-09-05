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
//  ESBannerCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBannerCell.h"
#import "ESBannerItemCell.h"
#import "ESPicModel.h"
#import "UIWindow+ESVisibleVC.h"

@interface ESBannerCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *listView;
@property (nonatomic, copy) NSArray<ESPicModel *> *modelList;
@property (nonatomic, weak) NSTimer     *timer;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation ESBannerCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    [self.listView registerClass:[ESBannerItemCell class] forCellWithReuseIdentifier:NSStringFromClass(ESBannerItemCell.class)];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESBannerItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESBannerItemCell.class) forIndexPath:indexPath];
    if (indexPath.row < self.modelList.count) {
        ESPicModel *picModel = self.modelList[indexPath.row];
        [cell bindData:picModel];
    }
   
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.modelList.count) {
        return;
    }
//    ESPicModel *pic = self.modelList[indexPath.row];
//    ESTodayInHistoryPageVC *vc = [[ESTodayInHistoryPageVC alloc] init];
//    vc.enterPic = pic;
//    vc.hidesBottomBarWhenPushed = YES;
//    UIViewController *topVC = [UIWindow visibleViewController];
//    [topVC.navigationController pushViewController:vc animated:YES];
}

- (UICollectionView *)listView {
    if (!_listView) {
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.listViewLayout];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    }
    return _listView;
}

- (UICollectionViewFlowLayout *)listViewLayout {
    CGFloat leftRightInset = ([UIScreen mainScreen].bounds.size.width - 348) / 2.0f;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(348, 176);
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset);
    return layout;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[NSArray class]] ||
        ( [(NSArray *)data count] > 0 &&
         ![[(NSArray *)data firstObject] isKindOfClass:[ESPicModel class]]) ) {
        return;
    }
    
    NSArray *picList = (NSArray *)data;
    if (picList.count <= 1) {
        self.modelList = picList;
    } else {
        NSMutableArray *picTempList = [NSMutableArray arrayWithArray:picList];
        [picTempList insertObject:[picList lastObject] atIndex:0];
        [picTempList addObject:[picList firstObject]];
        self.modelList = [picTempList copy];
    }
    
    [self.listView reloadData];

    if (self.modelList.count > 1) {
        [self.listView layoutIfNeeded];
        self.currentPage = 0;
        self.listView.contentOffset = CGPointMake(348, 0);
        [self startTimer];
    }
}

- (void)startTimer {
    if (self.modelList.count > 1) {
        [self stopTimer];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.timer = timer;
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = 348;
    CGFloat leftRightInset = ([UIScreen mainScreen].bounds.size.width - 348) / 2.0f;
    
    NSInteger currentPage = scrollView.contentOffset.x / width;
    if (currentPage == 0) {
        if (scrollView.contentOffset.x < leftRightInset) {
        [self.listView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.modelList.count - 2 inSection:0]
                              atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                      animated:NO];
        self.currentPage = self.modelList.count - 2;
        return;
        }
    }
    
     if (currentPage == self.modelList.count - 1) {
        self.currentPage = 0;
        [self.listView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
         return;
    }
        
    self.currentPage = currentPage;
    return;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

- (void)timerUpdate {
    NSInteger page =  self.currentPage + 1;
    [self.listView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

@end
