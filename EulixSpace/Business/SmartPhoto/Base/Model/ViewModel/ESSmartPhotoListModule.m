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
//  ESSmartPhotoListModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoListModule.h"
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
#import "ESSmartPhotoPreviewVC.h"
#import "ESSmartPhotoDataBaseManager.h"
//#import "ESSmartPhotoHomeVC.h"

//@interface ESSmartPhotoHomeVC ()
//
//- (void)fliteAlbumData;
//- (void)removePullRefresh;
//
//@end


@interface ESSmartPhotoListModule ()

@end

@implementation ESSmartPhotoListModule

#pragma mark -

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showStyle == ESSmartPhotoPageShowStyleNormal && _timeLineType == ESTimelineFrameItemTypeYear) {
        //如果是年模式， 切换到月模式
        ESPicModel *pic = [self getPicWithIndexPath:indexPath];
        _timeLineType = ESTimelineFrameItemTypeMonth;
        
        if (!pic) {
            return;
        }
        if ([(id <ESParentVCDelegate>)self.parentVC respondsToSelector:@selector(reloadDataByTypeAndScrollToItem:)]) {
            [(id <ESParentVCDelegate>)self.parentVC reloadDataByTypeAndScrollToItem:pic];
        }
      
        return;
    }
    ESPicModel *pic = [self getPicWithIndexPath:indexPath];
    if (!pic) {
        ESDLog(@"[ESSmartPhotoListModule] [didSelectItemAtIndexPath] no pic!");
        return;
    }
    if (self.showStyle == ESSmartPhotoPageShowStyleNormal) {
        ESAlbumModel *mainAlbum =  [ESSmartPhotoDataBaseManager.shared getMainAblum];
        if (self.album != nil && ![self.album.albumId isEqual:ESSafeString(mainAlbum.albumId)]) {
            NSArray<ESPicModel *> *picModels =  [self pciModlesFromDB];
            ESPhotoPreview(self.parentVC, picModels,  pic, self.album.albumId, ESComeFromSmartPhotoPageTag);
            return;
        }
        
        //首页
        NSArray<ESPicModel *> *picModels =  [ESSmartPhotoDataBaseManager.shared getPicsFromDB];
        ESPhotoPreview(self.parentVC, picModels, pic, self.album.albumId, ESComeFromSmartPhotoPageTag);
        return;
    }
    
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (NSArray<ESPicModel *> *)pciModlesFromDB {
    return [ESSmartPhotoDataBaseManager.shared getPicsFromDBWithAlbumId:ESSafeString(self.album.albumId)];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    if (section >= self.listModel.sections.count) {
        return CGSizeMake(0, 0);
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeTimelines) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;

        if (_timeLineType == ESTimelineFrameItemTypeYear) {
            return CGSizeMake((width - 24) / 8, (width - 24) / 8);
        }
        
        return CGSizeMake((width - 16) / 4, (width - 16) / 4);
    }
    
    return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section >= self.listModel.sections.count) {
        return 0;
    }
    
    ESSmartPhotoListSectionModel *sectionModel = self.listModel.sections[section];
    if (sectionModel.sectionType == ESSmartPhotoSectionTypeTimelines) {
        return 2;
    }
    return 0;
}

- (UIColor *)customBackgroudColor {
    if ([self.parentVC respondsToSelector:@selector(customBackgroudColor)]) {
        return [(ESPhotoBasePageVC *)self.parentVC customBackgroudColor];
    }
    return ESColor.systemBackgroundColor;
}

- (BOOL)supportLongPressCellAction {
    if (self.timeLineType == ESTimelineFrameItemTypeYear ||
        self.timeLineType == ESTimelineFrameItemTypeUnkown ) {
        return NO;
    }
    return [super supportLongPressCellAction];
}

//  长按进入编辑状态， 需要隐藏相册分类， indexPath 跟后面选择的indexPath section 相差 1
- (void)actionLongPressCellIndex:(NSIndexPath *)indexPath {
//    if([self.parentVC isKindOfClass:[ESSmartPhotoHomeVC class]] && indexPath.section > 0) {
//        [(ESSmartPhotoHomeVC *)self.parentVC fliteAlbumData];
//        [(ESSmartPhotoHomeVC *)self.parentVC removePullRefresh];
//        [self collectionView:self.listView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]];
//        return;
//    }
    [self collectionView:self.listView didSelectItemAtIndexPath:indexPath];
}

@end
