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
//  ESFileSelectPhotoListVC.m
//  EulixSpace
//
//  Created by qu on 2021/9/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileSelectPhotoListVC.h"
#import "ESEmptyView.h"
#import "ESPhotoCollectionVC.h"
#import "ESPermissionController.h"

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

@implementation ESFileSelectPhotoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if ([self.category isEqual:@"video"]) {
        self.navigationItem.title = NSLocalizedString(@"Select Album", @"选择视频");
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            [self showMsg];
        }
    } else {
        self.navigationItem.title = NSLocalizedString(@"Select Album", @"选择相册");
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            [self showMsg];
        }
    }
    self.photoTitleArray = [[NSMutableArray alloc] init];
    self.photoClassImageArray = [[NSMutableArray alloc] init];
    [self getThumbnailImages];
    [self.listView registerClass:[ESFileSelectPhotoCell class] forCellReuseIdentifier:@"ESFileSelectPhotoListCellID"];
    self.emptyView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self getThumbnailImages];
    
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

- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 84) style:UITableViewStyleGrouped];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = nil;
        _listView.backgroundView = nil;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.scrollEnabled = YES;
        _listView.bounces = NO; //禁止弹性效果
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //解决tableview刷新某一行跳动的问题
        _listView.estimatedRowHeight = 0;
        _listView.estimatedSectionHeaderHeight = 0;
        _listView.estimatedSectionFooterHeight = 0;
        //这行代码必须加上，可以去除tableView的多余的线，否则会影响美观
        _listView.tableFooterView = [UIView new];
        if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_listView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_listView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self.view addSubview:_listView];
    }
    return _listView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollectionList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

//已经选中了某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESPhotoCollectionVC *vc = [[ESPhotoCollectionVC alloc] init];
    vc.albumModel = self.assetCollectionList[indexPath.row];
    vc.category = self.category;
    vc.photoNumer = @(indexPath.row);
    [self.navigationController pushViewController:vc animated:YES];
}

- (ESEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[ESEmptyView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_emptyView];
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = IMAGE_EMPTY_NO_OPERATION_RECORD;
        item.content = NSLocalizedString(@"file_no_data", @"暂无文件");
        [self.emptyView reloadWithData:item];
        [self.view addSubview:self.emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _emptyView;
}

- (void)openJurisdiction {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)showMsg {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"照片权限获取" message:TEXT_PHOTO_POWER_SETTING preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *conform = [UIAlertAction actionWithTitle:TEXT_TURN_ON_NOW
//                                                      style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction *_Nonnull action) {
//                                                        [self openJurisdiction];
//                                                    }];
//    //2.2 取消按钮
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
//                                                     style:UIAlertActionStyleCancel
//                                                   handler:^(UIAlertAction *_Nonnull action){
//                                                   }];
//
//    //3.将动作按钮 添加到控制器中
//    [alert addAction:conform];
//    [alert addAction:cancel];

    //4.显示弹框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self presentViewController:alert animated:YES completion:nil];
        [ESPermissionController showPermissionView:ESPermissionTypeAlbum];
    });
}


@end
