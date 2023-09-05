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
//  ESLocalPhotoSelectVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLocalPhotoSelectVC.h"
#import "ESUploadLocalPhotoSelectVC.h"
#import "ESEmptyView.h"

@interface ESFileSelectPhotoListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *photoArray;
@property (nonatomic, strong) NSMutableArray *photoTitleArray;
@property (nonatomic, strong) NSMutableArray *photoDataArray;
@property (nonatomic, strong) NSMutableArray *photoClassImageArray;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *listView;

/// 相册数组
@property (nonatomic, strong) NSMutableArray<ESPhotoModel *> *assetCollectionList;
/// 当前相册
@property (nonatomic, strong) ESPhotoModel *albumModel;

@property (nonatomic, strong) ESEmptyView *emptyView;

@end

@interface ESLocalPhotoSelectVC ()

@end

@implementation ESLocalPhotoSelectVC

- (void)viewDidLoad {
    self.category = @"video|picture";
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Select Album", @"选择相册");
}

#pragma mark - 获得所有的自定义相簿
- (void)getThumbnailImages {
    self.assetCollectionList = [NSMutableArray array];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 获得个人收藏相册
        PHFetchResult<PHAssetCollection *> *favoritesCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
        // 获得相机胶卷
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        // 获得全部相片
        PHFetchResult<PHAssetCollection *> *cameraRolls = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];

        for (PHAssetCollection *collection in cameraRolls) {
            ESPhotoModel *model = [[ESPhotoModel alloc] init];
            model.category = self.category;
            model.collection = collection;

            if (![model.collectionNumber isEqualToString:@"0"]) {
                [weakSelf.assetCollectionList addObject:model];
            }
        }

        for (PHAssetCollection *collection in favoritesCollection) {
            ESPhotoModel *model = [[ESPhotoModel alloc] init];
            model.category = self.category;
            model.collection = collection;
            if (![model.collectionNumber isEqualToString:@"0"]) {
                [weakSelf.assetCollectionList addObject:model];
            }
        }
        for (PHAssetCollection *collection in assetCollections) {
            ESPhotoModel *model = [[ESPhotoModel alloc] init];
            model.category = self.category;
            model.collection = collection;

            if (![model.collectionNumber isEqualToString:@"0"]) {
                [weakSelf.assetCollectionList addObject:model];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.albumModel = weakSelf.assetCollectionList.firstObject;
            if (weakSelf.assetCollectionList.count > 0) {
                self.emptyView.hidden = YES;
            } else {
                self.emptyView.hidden = NO;
            }
            [self.listView reloadData];
        });
    });
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESFileSelectPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                 @"ESFileSelectPhotoListCellID"];
    if (cell == nil) {
        cell = [[ESFileSelectPhotoCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESFileSelectPhotoListCellID"];
    }
    cell.row = indexPath.row;
    cell.albumModel = self.assetCollectionList[indexPath.row];
    [cell loadImage:indexPath];
    return cell;
}



//已经选中了某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESUploadLocalPhotoSelectVC *vc = [[ESUploadLocalPhotoSelectVC alloc] init];
    [vc updateAlbumModel:self.assetCollectionList[indexPath.row]];
    vc.category = self.category;
    vc.uploadAlbumModel = self.uploadAlbumModel;
    vc.photoNumer = @(indexPath.row);
    [self.navigationController pushViewController:vc animated:YES];
}

@end

