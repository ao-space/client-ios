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
//  ESMemoriesDetailListModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoBasePageListModule.h"
#import "ESAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESListScrollUpdateBlock)(CGFloat contentOffsetY);

@interface ESMemoriesDetailListModule : NSObject <UICollectionViewDataSource , UICollectionViewDelegate>

@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSIndexPath *> *selectedMap;
@property (nonatomic, readonly) NSArray<ESPicModel *> *listModel;
@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, weak) id<ESSmartPhotoListModuleProtocol> delegate;
@property (nonatomic, assign) ESSmartPhotoPageShowStyle showStyle;
@property (nonatomic, strong) ESAlbumModel *albumModel;
@property (nonatomic, copy) ESListScrollUpdateBlock scrollUpdateBlock;

- (instancetype)initWithListView:(UICollectionView *)listView;
- (void)reloadData:(NSArray<ESPicModel *> *)picList;

- (void)selectedAll;
- (void)cleanAllSeleted;
- (NSUInteger)selectedCount;
- (BOOL)isAllSelected;
- (BOOL)needShowCover;

- (BOOL)isCellItemSelectedWithIndex:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView touchItemAtIndexPath:(NSIndexPath *)indexPath didSelect:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
