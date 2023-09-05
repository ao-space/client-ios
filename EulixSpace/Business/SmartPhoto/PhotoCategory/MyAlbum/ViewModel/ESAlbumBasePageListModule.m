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
//  ESAlbumBasePageListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumBasePageListModule.h"
#import "ESAlbumModel.h"
#import "ESMyAlbumCell.h"
#import "ESAlbumPageVC.h"

@interface ESAlbumBasePageListModule ()

@property (nonatomic, copy) NSArray<ESAlbumModel *> *albumList;
@property (nonatomic, weak) UICollectionView *listView;

@end

@implementation ESAlbumBasePageListModule

- (instancetype)initWithListView:(UICollectionView *)listView {
    if (self = [super init]) {
        self.listView = listView;
        [self.listView registerClass:[ESMyAlbumCell class] forCellWithReuseIdentifier:NSStringFromClass(ESMyAlbumCell.class)];
    }
    return self;
}
- (void)reloadData:(NSArray<ESAlbumModel *> *)albumList {
    self.albumList = albumList;
    [self.listView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section >= self.albumList.count) {
        return [UICollectionViewCell new];
    }
    
    ESMyAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESMyAlbumCell.class) forIndexPath:indexPath];
    if (indexPath.row < self.albumList.count) {
        ESAlbumModel *albumModel = self.albumList[indexPath.row];
        [cell bindData:albumModel];
    }
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    return CGSizeMake((width - 56) / 2, (width - 56) / 2 + 68);
    
}


@end
