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
//  ESAlbumCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumCategoryCell.h"
#import "ESESAlbumItemCell.h"
#import "ESAlbumCategoryModel.h"
#import "ESMyAlbumPageVC.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESFootPrintAlbumHomeVC.h"
#import "ESMemoriesHomePageVC.h"
#import "ESLikeAlbumPageVC.h"
#import "ESTodayInHistoryPageVC.h"
#import "ESVideoAlbumPageVC.h"
#import "ESScreenshotAlbumPageVC.h"
#import "ESGifAlbumPageVC.h"

@interface ESAlbumCategoryCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *listView;
@property (nonatomic, copy) NSArray *modelList;

@end

@implementation ESAlbumCategoryCell

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
    [self.listView registerClass:[ESESAlbumItemCell class] forCellWithReuseIdentifier:NSStringFromClass(ESESAlbumItemCell.class)];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESESAlbumItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESESAlbumItemCell.class) forIndexPath:indexPath];
    if (indexPath.row < self.modelList.count) {
        ESAlbumCategoryModel *albumModel = self.modelList[indexPath.row];
        [cell bindData:albumModel];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.modelList.count) {
        UIViewController *topVC = [UIWindow visibleViewController];

        ESAlbumCategoryModel *albumCategoryModel = self.modelList[indexPath.row];
        if(albumCategoryModel.type == ESAlbumCategoryTypeMyAlbum) {
            ESMyAlbumPageVC *myAlbumPageVC = [[ESMyAlbumPageVC alloc] init];
            myAlbumPageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:myAlbumPageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeAddress) {
            ESFootPrintAlbumHomeVC *footPrintAlbumHomeVC = [[ESFootPrintAlbumHomeVC alloc] init];
            footPrintAlbumHomeVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:footPrintAlbumHomeVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeMemories) {
            ESMemoriesHomePageVC *memoriesHomePageVC = [[ESMemoriesHomePageVC alloc] init];
            memoriesHomePageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:memoriesHomePageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeUserLike) {
            ESLikeAlbumPageVC *likeAlbumPageVC = [[ESLikeAlbumPageVC alloc] init];
            likeAlbumPageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:likeAlbumPageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeTodayInHistory) {
            ESTodayInHistoryPageVC *todayInHistoryPageVC = [[ESTodayInHistoryPageVC alloc] init];
            todayInHistoryPageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:todayInHistoryPageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeVideo) {
            ESVideoAlbumPageVC *pageVC = [[ESVideoAlbumPageVC alloc] init];
            pageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:pageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeScreenshot) {
            ESScreenshotAlbumPageVC *pageVC = [[ESScreenshotAlbumPageVC alloc] init];
            pageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:pageVC animated:YES];
            return;
        }
        
        if(albumCategoryModel.type == ESAlbumCategoryTypeGif) {
            ESGifAlbumPageVC *pageVC = [[ESGifAlbumPageVC alloc] init];
            pageVC.hidesBottomBarWhenPushed = YES;
            [topVC.navigationController pushViewController:pageVC animated:YES];
            return;
        }
    }
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
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(110, 110 + 24);
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
    return layout;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[NSArray class]] ||
        ( [(NSArray *)data count] > 0 &&
         ![[(NSArray *)data firstObject] isKindOfClass:[ESAlbumCategoryModel class]]) ) {
        return;
    }
    
    self.modelList = (NSArray *)data;
    [self.listView reloadData];
}

@end
