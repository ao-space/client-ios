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
//  ESPhotoBasePageListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/24.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoBasePageListModule.h"

#import "ESBannerCell.h"
#import "ESAlbumCategoryCell.h"
#import "ESPicCell.h"
#import "ESSectionHeader.h"
#import "ESSmartPhotoListModel.h"
#import "ESPicModel.h"
#import "ESFilePreviewViewController.h"
#import "ESFileDefine.h"
#import "ESFileInfoPub.h"
#import "ESFileLoadingViewController.h"
#import "ESMoreOperateComponentItem.h"
#import "ESToast.h"
#import "ESPhotoBasePageVC.h"
#import "UIView+ESTool.h"

NSString *const ESComeFromSmartPhotoPageTag = @"ESComeFromSmartPhotoPageTag";

@interface ESPhotoBasePageListModule ()

@property (nonatomic, weak) UICollectionView *listView;
@property (nonatomic, strong) ESSmartPhotoListModel *listModel;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSIndexPath *> *selectedMap;
@property (nonatomic, assign) NSUInteger canSeletedCount;
@property (nonatomic, assign) BOOL isDraging;
@property (nonatomic, assign) CGFloat scrollOffsetY;

@end

@implementation ESPhotoBasePageListModule

- (instancetype)initWithListView:(UICollectionView *)listView {
    if (self = [super init]) {
        self.listView = listView;
        self.listView.backgroundColor = self.customBackgroudColor;
        [listView registerClass:[ESBannerCell class] forCellWithReuseIdentifier:NSStringFromClass(ESBannerCell.class)];
        [listView registerClass:[ESAlbumCategoryCell class] forCellWithReuseIdentifier:NSStringFromClass(ESAlbumCategoryCell.class)];
        [listView registerClass:[ESPicCell class] forCellWithReuseIdentifier:NSStringFromClass(ESPicCell.class)];
        [listView registerClass:[ESSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ESSectionHeader class])];
        [listView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];

        self.scrollOffsetY = 0;
        [self cleanAllSeleted];
    }
    return self;
}

- (void)reloadData:(ESSmartPhotoListModel *)listModel {
    self.listModel = listModel;
    self.canSeletedCount = [self countOfCanSelectAllPic];
    [self.listView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.listModel.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getSectionCount:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section >= self.listModel.sections.count) {
        return [UICollectionViewCell new];
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    ESBaseCollectionCell *cell = [self cellWithCollectionView:collectionView indexPath:indexPath sectoionType:sectionModel.sectionType];
    
    if ([cell isKindOfClass:[ESPicCell class]]) {
        ((ESPicCell *)cell).listViewIsDraging = self.isDraging;
        
        weakfy(self)
        ((ESPicCell *)cell).longPressActionBlock = ^() {
            strongfy(self)
            if (self.showStyle == ESSmartPhotoPageShowStyleNormal &&
                [self supportLongPressCellAction]) {
                self.showStyle = ESSmartPhotoPageShowStyleSelecte;
                [(ESPhotoBasePageVC *)self.parentVC updateShowStyle];
                [self actionLongPressCellIndex:indexPath];
            }
        };
    }
    if (indexPath.row < sectionModel.blocks.count) {
        ESSmartPhotoListBlockModel *blockModel = sectionModel.blocks[indexPath.row];
        if (blockModel.blockType != ESSmartPhotoBlockTypeAlbum  &&
            blockModel.blockType != ESSmartPhotoBlockTypeBanner &&
            blockModel.items.count == 1) {
            [cell bindData:[blockModel.items firstObject]];
        } else {
            [cell bindData:blockModel.items];
        }
    }
    if ([cell isKindOfClass:[ESPicCell class]]) {
        if (_showStyle == ESSmartPhotoPageShowStyleNormal) {
            [(ESPicCell *)cell setShowStyle:ESPicCellShowStyleNormal];
        } else {
            ESPicModel *pic = [self getPicWithIndexPath:indexPath];
            BOOL isSelected = [self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)];
            [(ESPicCell *)cell setShowStyle:isSelected ? ESPicCellShowStyleSelected : ESPicCellShowStyleUnSelecte];
        }
    }
    
    return cell;
}

- (BOOL)isCellItemSelectedWithIndex:(NSIndexPath *)indexPath {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    return [self.selectedMap.allKeys containsObject:ESSafeString(pic.uuid)];
}

- (void)collectionView:(UICollectionView *)collectionView touchItemAtIndexPath:(NSIndexPath *)indexPath didSelect:(BOOL)isSelected  {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    if (!pic) {
        ESDLog(@"[ESSmartPhotoListModule] [touchItemAtIndexPath] no pic!");
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
    ESSectionHeader *sectionHeader = (ESSectionHeader *)[self.listView supplementaryViewForElementKind:UICollectionElementKindSectionHeader
                                                                                           atIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    [self updateSectionHeader:sectionHeader forIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(didSelectPic:indexPath:)]) {
        [self.delegate didSelectPic:pic indexPath:indexPath];
    }
}

- (ESBaseCollectionCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                       indexPath:(NSIndexPath *)indexPath
                                    sectoionType:(ESSmartPhotoSectionType)sectionType {
    if (sectionType == ESSmartPhotoSectionTypeBanner) {
        ESBannerCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESBannerCell.class) forIndexPath:indexPath];
        return cell;
    }
    
    if (sectionType == ESSmartPhotoSectionTypeAlbums) {
        ESAlbumCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESAlbumCategoryCell.class) forIndexPath:indexPath];
        return cell;
    }
    
    ESPicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESPicCell.class) forIndexPath:indexPath];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDraging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    BOOL scrollToScrollStop = !decelerate;
    if (scrollToScrollStop) {
        self.isDraging = NO;
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.isDraging = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging &&  !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndScroll {
    if (self.scrollActionEndBlock) {
        self.scrollActionEndBlock();
    }
    NSArray *indexPaths = [self.listView indexPathsForVisibleItems];
    NSMutableArray *needReloadList = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath  *_Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        ESPicCell *cell = (ESPicCell *)[self.listView cellForItemAtIndexPath:indexPaths.firstObject];
        if([cell respondsToSelector:@selector(needRefresh)] &&
           cell.needRefresh) {
            [needReloadList addObject:indexPath];
        }
    }];
    
    [self.listView reloadItemsAtIndexPaths:needReloadList];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffestY = scrollView.contentOffset.y;
    BOOL isUp = currentOffestY > self.scrollOffsetY && currentOffestY > 10;
    if (self.scrollActionUpdateBlock) {
        self.scrollActionUpdateBlock(isUp);
    }
    self.scrollOffsetY = currentOffestY;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    if (!pic) {
        ESDLog(@"[ESSmartPhotoListModule] [didSelectItemAtIndexPath] no pic!");
        return;
    }
    if (_showStyle == ESSmartPhotoPageShowStyleNormal) {
        ESFileInfoPub *file = [[ESFileInfoPub alloc] init];
        file.name = pic.name;
        file.size = @(pic.size);
        file.uuid = pic.uuid;
        file.path = pic.path;
        file.category = pic.category;
        file.operationAt = @(pic.shootAt);
        if (LocalFileExist(file) || IsImageForFile(file) || UnsupportFileForPreview(file)) {
            ESFilePreviewWithTag(self.parentVC, file, ESComeFromSmartPhotoPageTag);
            return;
        }
        ///视频 要先下载
        if (IsVideoForFile(file)) {
            ESFileShowLoading(self.parentVC, file, NO, ^(void) {
                ESFilePreviewWithTag(self.parentVC, file, ESComeFromSmartPhotoPageTag);
            });
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
    ESSectionHeader *sectionHeader = (ESSectionHeader *)[self.listView supplementaryViewForElementKind:UICollectionElementKindSectionHeader
                                                                                           atIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    [self updateSectionHeader:sectionHeader forIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(didSelectPic:indexPath:)]) {
        [self.delegate didSelectPic:pic indexPath:indexPath];
    }
}

- (ESPicModel * _Nullable)getPicWithIndexPath:(NSIndexPath *)indexPath {
    if (self.listModel.sections.count > indexPath.section &&
        self.listModel.sections[indexPath.section].blocks.count > indexPath.row) {
        ESSmartPhotoListBlockModel *block = self.listModel.sections[indexPath.section].blocks[indexPath.row];
        if (block.items.count > 0 &&
            block.blockType == ESSmartPhotoBlockTypeSinglePic &&
            [block.items[0] isKindOfClass:[ESPicModel class]]) {
            ESPicModel *pic = block.items[0];
            return pic;
        }
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    float width = self.listView.bounds.size.width;
    
    if (section >= self.listModel.sections.count) {
        return CGSizeMake(0, 0);
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeBanner) {
        return CGSizeMake(width , 176);
    }
    
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeAlbums) {
        return CGSizeMake(width , 134);
    }
    
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeTimelines) {
        return CGSizeMake(90, 90);
    }
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    float width = self.listView.bounds.size.width;
    
    if (section >= self.listModel.sections.count) {
        return CGSizeMake(0, 0);
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeBanner ||
        sectionModel.sectionType == ESSmartPhotoSectionTypeAlbums) {
        return CGSizeMake(width, 54);
    }
    
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeTimelines) {
        if (sectionModel.sectionTitle.length > 0 && sectionModel.sectionSubtitle.length > 0) {
            return CGSizeMake(width, 20 + 22 + 52);
        } else if (sectionModel.sectionSubtitle.length > 0) {
            return CGSizeMake(width, 52);
        } else {
            return CGSizeMake(width, 54);
        }
    }
    
    return CGSizeMake(width, 52);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    float width = self.listView.bounds.size.width;
    
    if (section >= self.listModel.sections.count) {
        return CGSizeMake(0, 0);
    }
    
    if (section == self.listModel.sections.count - 1 &&
        self.listModel.sections.count >= 2 &&
        self.showStyle == ESSmartPhotoPageShowStyleNormal) {
        return CGSizeMake(width, 30);
    }
    return  CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ESSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                       UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ESSectionHeader.class) forIndexPath:indexPath];
        headerView.backgroundColor = self.customBackgroudColor;
        [self updateSectionHeader:headerView forIndexPath:indexPath];
        return headerView;
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *sloganView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                       UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        sloganView.backgroundColor = self.customBackgroudColor;
        sloganView.layer.masksToBounds = YES;
        sloganView.layer.cornerRadius = 10;

        UIView * view = [UIView es_sloganView:NSLocalizedString(@"common_encrypted_main", @"多重安全技术，保护数据隐私")];
        [sloganView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
          make.leading.mas_greaterThanOrEqualTo(sloganView).inset(20);
          make.trailing.mas_lessThanOrEqualTo(sloganView).inset(-20);
          make.top.mas_equalTo(sloganView);
          make.bottom.mas_equalTo(sloganView);
          make.centerX.mas_equalTo(sloganView);
        }];
        
        return sloganView;
    }
    
    return [UICollectionReusableView new];
}

- (void)updateSectionHeader:(ESSectionHeader *)header forIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section >= self.listModel.sections.count) {
        return;
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    header.titleLabel.text = sectionModel.sectionTitle;
    header.subtitleLabel.text = sectionModel.sectionSubtitle;
    if (self.showStyle == ESSmartPhotoPageShowStyleNormal) {
        header.showStyle = ESSectionHeaderShowStyleNormal;
    } else {
        header.showStyle =  [self getSelectedCountWithSectionIndex:section] == [self getSectionCount:section] ?
        ESSectionHeaderShowStyleSelected : ESSectionHeaderShowStyleUnSelecte;
        __weak typeof (header) weakHeader = header;
        __weak typeof (self) weakSelf = self;
        header.selectBlock = ^() {
            __strong typeof (weakHeader) strongHeader = weakHeader;
            __strong typeof (weakSelf) strongSelf = weakSelf;
            strongHeader.showStyle = strongHeader.showStyle == ESSectionHeaderShowStyleSelected ?
            ESSectionHeaderShowStyleUnSelecte : ESSectionHeaderShowStyleSelected;
            [strongSelf upSelecteSection:section selected:strongHeader.showStyle == ESSectionHeaderShowStyleSelected];
        };
    }
    
    return;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.listModel.sections.count < section) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeTimelines) {
        return  UIEdgeInsetsMake(0, 4, 0, 4);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
};

#pragma mark - selecte
- (NSInteger)getSelectedCountWithSectionIndex:(NSInteger)section {
    __block NSInteger sectionSelectedCount = 0;
    [self.selectedMap.allValues enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.section == section) {
            sectionSelectedCount++;
        }
    }];
    return sectionSelectedCount;
}

- (NSInteger)getSectionCount:(NSInteger)section {
    if (section < self.listModel.sections.count) {
        ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
        return sectionModel.blocks.count;
    }
    return 0;
}

- (void)upSelecteSection:(NSInteger)section selected:(BOOL)selected {
    if (self.listModel.sections.count < section) {
        return;
    }
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    NSMutableDictionary *setionModifyDic = [NSMutableDictionary dictionary];
    
    [sectionModel.blocks enumerateObjectsUsingBlock:^(ESSmartPhotoListBlockModel * _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block.blockType == ESSmartPhotoBlockTypeSinglePic  &&
            block.items.count > 0 &&
            [block.items[0] isKindOfClass:[ESPicModel class]]) {
            if ([self isReachLimitSelectedCount] && selected) {
                [ESToast toastError:NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件")];
                *stop = YES;
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
            ESPicModel *pic = [block.items firstObject];
            setionModifyDic[ESSafeString(pic.uuid)] = indexPath;
            self.selectedMap[ESSafeString(pic.uuid)] = indexPath;
        }
    }];
    
    if (selected) {
        [self.selectedMap addEntriesFromDictionary:setionModifyDic];
    } else {
        [self.selectedMap removeObjectsForKeys:setionModifyDic.allKeys];
    }
    
    [self.listView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    if (self.selectedUpdateBlock) {
        self.selectedUpdateBlock();
    }
}

- (void)setShowStyle:(ESSmartPhotoPageShowStyle)showStyle {
    if (_showStyle != showStyle) {
        _showStyle = showStyle;
        [self.listView reloadData];
    }
}

#pragma mark - Selecte

- (void)selectedAll {
    [self.listModel.sections enumerateObjectsUsingBlock:^(ESSmartPhotoListSectionModel * _Nonnull sectoion, NSUInteger setionIdx, BOOL * _Nonnull stop) {
        if(sectoion.sectionType == ESSmartPhotoSectionTypeTimelines) {
            [sectoion.blocks enumerateObjectsUsingBlock:^(ESSmartPhotoListBlockModel * _Nonnull block, NSUInteger blockIdx, BOOL * _Nonnull stop) {
                if (block.blockType == ESSmartPhotoBlockTypeSinglePic  &&
                    block.items.count > 0 &&
                    [block.items[0] isKindOfClass:[ESPicModel class]]) {
                    ESPicModel *pic = [block.items firstObject];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:blockIdx inSection:setionIdx];
                    if (!indexPath) return;
                    if ([self isReachLimitSelectedCount]) {
                        [ESToast toastError:NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件")];
                        *stop = YES;
                        return;
                    }
                    self.selectedMap[ESSafeString(pic.uuid)] = indexPath;
                }
            }];
        }
    }];
    [self.listView reloadData];
}

- (void)cleanAllSeleted {
    self.selectedMap = [NSMutableDictionary dictionary];
    [self.listView reloadData];
}

- (NSInteger)countOfCanSelectAllPic {
    __block NSUInteger count = 0;
    [self.listModel.sections enumerateObjectsUsingBlock:^(ESSmartPhotoListSectionModel * _Nonnull sectoion, NSUInteger idx, BOOL * _Nonnull stop) {
        if(sectoion.sectionType == ESSmartPhotoSectionTypeTimelines) {
            [sectoion.blocks enumerateObjectsUsingBlock:^(ESSmartPhotoListBlockModel * _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
                if (block.blockType == ESSmartPhotoBlockTypeSinglePic  &&
                    block.items.count > 0 &&
                    [block.items[0] isKindOfClass:[ESPicModel class]]) {
                    count++;
                }
            }];
        }
    }];
    return count < self.maxSelectCount ?  count : self.maxSelectCount;
}

- (NSInteger)countOfAllPic {
    __block NSUInteger count = 0;
    [self.listModel.sections enumerateObjectsUsingBlock:^(ESSmartPhotoListSectionModel * _Nonnull sectoion, NSUInteger idx, BOOL * _Nonnull stop) {
        if(sectoion.sectionType == ESSmartPhotoSectionTypeTimelines) {
            [sectoion.blocks enumerateObjectsUsingBlock:^(ESSmartPhotoListBlockModel * _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
                if (block.blockType == ESSmartPhotoBlockTypeSinglePic  &&
                    block.items.count > 0 &&
                    [block.items[0] isKindOfClass:[ESPicModel class]]) {
                    count++;
                }
            }];
        }
    }];
    return count;
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

- (NSString * _Nullable)sectionSubTitleWithIndex:(NSInteger)sectionIndex {
    if (self.listModel.sections.count > sectionIndex) {
        ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[sectionIndex];
        return sectionModel.sectionSubtitle;
    }
    return nil;
}

- (UIColor *)customBackgroudColor {
    return ESColor.systemBackgroundColor;
}

- (BOOL)supportLongPressCellAction {
    return YES;
}

- (void)actionLongPressCellIndex:(NSIndexPath *)indexPath {
    [self collectionView:self.listView didSelectItemAtIndexPath:indexPath];
}

@end
