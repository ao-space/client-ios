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
//  ESMemoriesHomePageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesHomePageVC.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESMemoriesHomePageListModule.h"
#import "ESAlbumModifyModule.h"
#import "ESToast.h"
#import "ESAlbumModifyModule.h"
#import "ESMemoriesCollectionVC.h"

@implementation ESMemoriesHomePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];

    self.title = NSLocalizedString(@"album_memories", @"回忆");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAlbumDataFromDB];
    [self setupNavigationBar];
    [self loadAlbumData];
}

- (void)setupNavigationBar {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"album_collection", @"个人收藏")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(collectionAction:)];
    if (self.listModule.listData.count > 0) {
        [rightBarItem setTintColor:ESColor.primaryColor];
        rightBarItem.enabled = YES;
    } else {
        [rightBarItem setTintColor:ESColor.secondaryLabelColor];
        rightBarItem.enabled = NO;
    }
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (NSInteger)memoriesCollectionCount {
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getCollectionAlbumDataFromDBByType:ESAlbumTypeMemories];
    NSMutableArray *collectionList = [NSMutableArray array];
    [albumList enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        if(album.collection) {
            [collectionList addObject:album];
        }
    }];
    return collectionList.count;
}

- (void)collectionAction:(id)sender {
    if (self.listModule.listData.count <= 0)  {
        return;
    }
    ESMemoriesCollectionVC *vc = [[ESMemoriesCollectionVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (Class)listModuleClass {
    return [ESMemoriesHomePageListModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return YES;
}

- (void)pullRefreshData {
    ESDLog(@"[ESMemoriesHomePageVC] pullRefreshData");
    [self loadAlbumData];
}

- (void)loadAlbumData {
    weakfy(self)
    [ESSmartPhotoAsyncManager.shared loadAlbumsInfo:^{
        strongfy(self)
        [self reloadAlbumDataFromDB];
        [self setupNavigationBar];
        [self finishPullRefresh];
    }];
}

- (void)reloadAlbumDataFromDB {
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeMemories];

    [self.listModule reloadData:albumList];
}

- (void)likeAlbum:(ESAlbumModel *)albumModel {
    if (albumModel == nil) {
        return;
    }
    BOOL isCollection = !albumModel.collection;
    weakfy(self)
    [ESAlbumModifyModule collectionAlbum:isCollection
                                 albumId:[albumModel.albumId integerValue]
                              completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
        strongfy(self)
        if (success) {
            albumModel.collection = isCollection;
            [ESSmartPhotoDataBaseManager.shared insertOrUpdateAlbumsToDB:@[albumModel]];
            [self reloadAlbumDataFromDB];
            [self setupNavigationBar];
            return;
        }
        [ESToast toastSuccess:NSLocalizedString(@"album_collectionFail", @"收藏失败")];
    }];
}

- (void)showDeleteAlbumDialog:(ESAlbumModel *)albumModel {
    NSString *message = NSLocalizedString(@"album_memoriesDes", @"是否确定删除？回忆删除后将无法恢复，回忆里的文件不会被删除");
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:message
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc]initWithString:message
                                                                                  attributes:@{NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                                                                                               NSFontAttributeName:ESFontPingFangRegular(15),
                                                                                               NSParagraphStyleAttributeName : paraStyle,
                                                                                             }];
    [actionSheetController setValue:attMessage forKey:@"attributedMessage"];
    
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"album_delCollection", @"删除回忆") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showLoading:YES];
        NSNumber *deleteAlbumId = @([albumModel.albumId integerValue]);
        [ESAlbumModifyModule deleteAlbumIds: @[deleteAlbumId]
                                 completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
                });
                [ESSmartPhotoDataBaseManager.shared deletAlbumDBDataWithAlbumIds:@[albumModel.albumId]];
                [self reloadAlbumDataFromDB];
                [self setupNavigationBar];
                return;
            }
            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }];
    }];
    [cleanAction setValue:ESColor.redColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheetController addAction:cleanAction];
    [actionSheetController addAction:cancelAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_noMemories", @"您还没有任何回忆，请多多上传文件才会生成哦~");
}

@end
