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
//  ESMemoriesDetailListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesDetailListModule.h"
#import "ESMemoriesHeaderCell.h"
#import "ESPicCell.h"
#import "ESPicModel.h"
#import "ESFileInfoPub.h"
#import "ESFilePreviewViewController.h"
#import "ESFileDefine.h"
#import "ESFileLoadingViewController.h"
#import "ESToast.h"
#import "ESMemoriesDetailPageVC.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESSmartPhotoPreviewVC.h"
#import "NSDate+Format.h"
#import "ESPhotoBasePageVC.h"

@interface ESMemoriesDetailPageVC ()

- (void)playAlbum;

@end

@interface ESMemoriesDetailListModule ()

@property (nonatomic, weak) UICollectionView *listView;
@property (nonatomic, strong) NSArray<ESPicModel *> *listModel;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSIndexPath *> *selectedMap;
@property (nonatomic, assign) NSUInteger canSeletedCount;
@property (nonatomic, assign) NSInteger maxSelectCount;

@end

@implementation ESMemoriesDetailListModule

- (instancetype)initWithListView:(UICollectionView *)listView {
    if (self = [super init]) {
        self.listView = listView;
        self.listView.backgroundColor = ESColor.systemBackgroundColor;
        [listView registerClass:[ESPicCell class] forCellWithReuseIdentifier:NSStringFromClass(ESPicCell.class)];
        [listView registerClass:[ESMemoriesHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass(ESMemoriesHeaderCell.class)];
    }
    return self;
}

- (void)reloadData:(NSArray<ESPicModel *> *)picList {
    self.listModel = picList;
    self.canSeletedCount = [self countOfCanSelectAllPic];
    [self.listView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.listModel.count > 0 && self.showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        return 2;
    }
    
    if (self.showStyle == ESSmartPhotoPageShowStyleSelecte) {
        return 1;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0 && self.showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        return 1;
    }
    return self.listModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row >= self.listModel.count) {
        return [UICollectionViewCell new];
    }

    ESBaseCollectionCell *cell = [self cellWithCollectionView:collectionView indexPath:indexPath];
    if (indexPath.section == 0 && _showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        [cell bindData:self.listModel[0]];
        return cell;
    }
    
    if ([cell isKindOfClass:[ESPicCell class]] && indexPath.row < self.listModel.count) {
        [cell bindData:self.listModel[indexPath.row]];
        if (_showStyle == ESSmartPhotoPageShowStyleNormal) {
            [(ESPicCell *)cell setShowStyle:ESPicCellShowStyleNormal];
        } else {
            ESPicModel *pic = self.listModel[indexPath.row];
            BOOL isSelected = [self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)];
            [(ESPicCell *)cell setShowStyle:isSelected ? ESPicCellShowStyleSelected : ESPicCellShowStyleUnSelecte];
        }
        
        weakfy(self)
        ((ESPicCell *)cell).longPressActionBlock = ^() {
            strongfy(self)
            if (self.showStyle == ESSmartPhotoPageShowStyleNormal) {
                self.showStyle = ESSmartPhotoPageShowStyleSelecte;
                [(ESPhotoBasePageVC *)self.parentVC updateShowStyle];
                [self collectionView:self.listView didSelectItemAtIndexPath:indexPath];
            }
        };
    }

    return cell;
}

- (BOOL)needShowCover {
    return [self picCount] >= 3;
}

- (NSInteger)picCount {
    NSArray<ESPicModel *> *pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBWithAlbumId:self.albumModel.albumId];
    __block NSInteger count = 0;
    [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pic isPicture]) {
            count += 1;
        }
    }];
    return count;
}

- (ESBaseCollectionCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                       indexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.section == 0 && self.showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        ESMemoriesHeaderCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESMemoriesHeaderCell.class) forIndexPath:indexPath];
        if ([self.albumModel.albumName containsString:@","]) {
            NSArray *titleList = [self.albumModel.albumName componentsSeparatedByString:@","];
            cell.titleText = titleList[0];
            if (titleList.count > 1) {
                cell.timeText = titleList[1];
            }
        } else {
            cell.titleText = self.albumModel.albumName;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.albumModel.createdAt];
            NSString *time = [date stringFromFormat:@"YYYY年MM月dd日"];
            cell.timeText = time;
        }
        weakfy(self)
        cell.playActionBlock = ^() {
            strongfy(self)
            [(ESMemoriesDetailPageVC *)self.parentVC playAlbum];
        };
        cell.showPlayerEnter = YES;
        
        return cell;
    }

    ESPicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESPicCell.class) forIndexPath:indexPath];
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffestY = scrollView.contentOffset.y;
    if (self.scrollUpdateBlock) {
        self.scrollUpdateBlock(currentOffestY);
    }
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    if (!pic) {
        ESDLog(@"[ESSmartPhotoListModule] [didSelectItemAtIndexPath] no pic!");
        return;
    }
 
    if (self.showStyle == ESSmartPhotoPageShowStyleNormal) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return;
        }
        ESAlbumModel *mainAlbum =  [ESSmartPhotoDataBaseManager.shared getMainAblum];
        if (self.albumModel != nil && ![self.albumModel.albumId isEqual:ESSafeString(mainAlbum.albumId)]) {
            NSArray<ESPicModel *> *picModels =  [self pciModlesFromDB];
            ESPhotoPreview(self.parentVC, picModels,  pic, self.albumModel.albumId, ESComeFromSmartPhotoPageTag);
            return;
        }
        return;
    }

    BOOL isSelected = NO;
    if (![self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)] &&
        [self isReachLimitSelectedCount]) {
        [ESToast toastError:NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件")];
        return;
    }

    if ([self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)]) {
        [self.selectedMap  removeObjectForKey:ESSafeString(pic.uuid)];
    } else {
        self.selectedMap[ESSafeString(pic.uuid)] = indexPath;

        isSelected = YES;
    }
    ESPicCell *cell = (ESPicCell *)[self.listView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ESPicCell class]]) {
        [cell setShowStyle:isSelected ? ESPicCellShowStyleSelected : ESPicCellShowStyleUnSelecte];
    }
   
    if ([self.delegate respondsToSelector:@selector(didSelectPic:indexPath:)]) {
        [self.delegate didSelectPic:pic indexPath:indexPath];
    }
}

- (NSArray<ESPicModel *> *)pciModlesFromDB {
    return [ESSmartPhotoDataBaseManager.shared getPicsFromDBWithAlbumId:ESSafeString(self.albumModel.albumId)];
}

- (ESPicModel * _Nullable)getPicWithIndexPath:(NSIndexPath *)indexPath {
    if (self.listModel.count > indexPath.row) {
        return self.listModel[indexPath.row];
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger section = indexPath.section;
    float width = self.listView.bounds.size.width;

    if (section >= 2) {
        return CGSizeMake(0, 0);
    }
    
    if (section == 0 && _showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        return CGSizeMake(width, 430);
    }

    return CGSizeMake((width - 16) / 4, (width - 16) / 4);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (2 <= section) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if (section == 0 && _showStyle == ESSmartPhotoPageShowStyleNormal && [self needShowCover]) {
        return  UIEdgeInsetsMake(0, 0, 20, 0);
    }
    return  UIEdgeInsetsMake(0, 4, 20, 4);
};

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section >= 2) {
        return 0;
    }
    
    return 2;
}

#pragma mark - selecte

- (void)setShowStyle:(ESSmartPhotoPageShowStyle)showStyle {
    if (_showStyle != showStyle) {
        _showStyle = showStyle;
        [self.listView reloadData];
    }
}

#pragma mark - Selecte

- (void)selectedAll {
    [self.listModel enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pic isKindOfClass:[ESPicModel class]] &&
            [self isReachLimitSelectedCount]) {
            [ESToast toastError:NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件")];
            *stop = YES;
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
        self.selectedMap[ESSafeString(pic.uuid)] = indexPath;
    }];
    
    [self.listView reloadData];
}

- (void)cleanAllSeleted {
    self.selectedMap = [NSMutableDictionary dictionary];
    [self.listView reloadData];
}

- (NSInteger)countOfCanSelectAllPic {
    NSUInteger count = [self countOfAllPic];
    
    return count < self.maxSelectCount ?  count : self.maxSelectCount;
}

- (NSInteger)countOfAllPic {
    return self.listModel.count;
}

- (BOOL)isReachLimitSelectedCount {
    return [self selectedCount] >= self.maxSelectCount;
}

- (NSInteger)maxSelectCount {
    if (_maxSelectCount > 0) {
        return _maxSelectCount;
    }
    return 500;
}

- (NSUInteger)selectedCount {
    return self.selectedMap.allKeys.count;
}

- (BOOL)isAllSelected {
    return self.selectedMap.allKeys.count == self.canSeletedCount && self.selectedMap.allKeys.count > 0;
}

- (BOOL)isCellItemSelectedWithIndex:(NSIndexPath *)indexPath {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    return [self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)];
}

- (void)collectionView:(UICollectionView *)collectionView touchItemAtIndexPath:(NSIndexPath *)indexPath didSelect:(BOOL)isSelected  {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    if (!pic) {
        ESDLog(@"[ESSmartPhotoListModule] [didSelectItemAtIndexPath] no pic!");
        return;
    }
 
    if (self.showStyle == ESSmartPhotoPageShowStyleNormal) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return;
        }
        ESAlbumModel *mainAlbum =  [ESSmartPhotoDataBaseManager.shared getMainAblum];
        if (self.albumModel != nil && ![self.albumModel.albumId isEqual:ESSafeString(mainAlbum.albumId)]) {
            NSArray<ESPicModel *> *picModels =  [self pciModlesFromDB];
            ESPhotoPreview(self.parentVC, picModels,  pic, self.albumModel.albumId, ESComeFromSmartPhotoPageTag);
            return;
        }
        return;
    }

    if (![self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)] &&
        isSelected &&
        [self isReachLimitSelectedCount]) {
        [ESToast toastError:NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件")];
        return;
    }

    if ([self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)] && !isSelected) {
        [self.selectedMap  removeObjectForKey:ESSafeString(pic.uuid)];
    } else if (isSelected) {
        self.selectedMap[ESSafeString(pic.uuid)] = indexPath;
    }
    ESPicCell *cell = (ESPicCell *)[self.listView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ESPicCell class]]) {
        [cell setShowStyle:isSelected ? ESPicCellShowStyleSelected : ESPicCellShowStyleUnSelecte];
    }
   
    if ([self.delegate respondsToSelector:@selector(didSelectPic:indexPath:)]) {
        [self.delegate didSelectPic:pic indexPath:indexPath];
    }
}

@end
