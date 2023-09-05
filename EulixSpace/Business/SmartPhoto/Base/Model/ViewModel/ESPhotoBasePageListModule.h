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
//  ESPhotoBasePageListModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/24.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESSmartPhotoListModel.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, ESSmartPhotoPageShowStyle) {
    ESSmartPhotoPageShowStyleNormal,
    ESSmartPhotoPageShowStyleSelecte,
};

FOUNDATION_EXPORT NSString *const ESComeFromSmartPhotoPageTag;

@class ESPicModel;
@protocol ESSmartPhotoListModuleProtocol <NSObject>

- (void)didSelectPic:(ESPicModel *)pic indexPath:(NSIndexPath *)index;

@end

typedef void (^ESScrollActionUpdateBlock)(BOOL isScrollingUp); // YES 向上滑动 NO向下滑动

@class ESBaseCollectionCell;
@interface ESPhotoBasePageListModule : NSObject <UICollectionViewDataSource , UICollectionViewDelegate>

@property (nonatomic, weak) id<ESSmartPhotoListModuleProtocol> delegate;
@property (nonatomic, weak, readonly) UICollectionView *listView;
@property (nonatomic, readonly) ESSmartPhotoListModel *listModel;

@property (nonatomic, assign) ESSmartPhotoPageShowStyle showStyle;
@property (nonatomic, copy) dispatch_block_t selectedUpdateBlock;

@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSIndexPath *> *selectedMap;
@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, copy) ESScrollActionUpdateBlock scrollActionUpdateBlock;
@property (nonatomic, copy) dispatch_block_t scrollActionEndBlock;
@property (nonatomic, assign) NSInteger maxSelectCount;

- (instancetype)initWithListView:(UICollectionView *)listView;

- (void)reloadData:(ESSmartPhotoListModel *)listModel;

- (void)selectedAll;
- (void)cleanAllSeleted;

- (BOOL)isAllSelected;
- (NSUInteger)selectedCount;

- (NSInteger)countOfAllPic;

- (NSString * _Nullable)sectionSubTitleWithIndex:(NSInteger)sectionIndex;

- (ESPicModel * _Nullable)getPicWithIndexPath:(NSIndexPath *)indexPath;
//自定义
- (ESBaseCollectionCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                       indexPath:(NSIndexPath *)indexPath
                                    sectoionType:(ESSmartPhotoSectionType)sectionType;

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

- (BOOL)isCellItemSelectedWithIndex:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView touchItemAtIndexPath:(NSIndexPath *)indexPath didSelect:(BOOL)select;
//overwrite 是否支持长按编辑
- (BOOL)supportLongPressCellAction;
- (void)actionLongPressCellIndex:(NSIndexPath *)index;

@end

NS_ASSUME_NONNULL_END
