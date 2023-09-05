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
//  ESAlbumPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumPageVC.h"
#import "ESAlbumMoreActionVC.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESBaseViewController+Status.h"
#import "ESAlbumModifyModule.h"
#import "ESToast.h"
#import "ESAlbumInfoEditeVC.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESAddPhotoActionVC.h"
#import "ESLocalPhotoSelectVC.h"
#import "ESAoSpacePhotoSelectVC.h"
#import "ESBottomSelectedOperateVC.h"

@interface ESPhotoBasePageVC ()

@property (nonatomic, strong) ESBottomSelectedOperateVC *bottomMoreToolVC;

@end

@interface ESAlbumPageVC () <ESActionSheetVCProtocol>

@property (nonatomic, strong) ESAlbumMoreActionVC *moreActionVC;
@property (nonatomic, strong) ESAddPhotoActionVC *addActionVC;

@end

@implementation ESAlbumPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    
    ESAlbumModel *albumModel = [ESSmartPhotoDataBaseManager.shared getAlbumByid:self.albumModel.albumId];
    self.albumModel = albumModel;
    self.title = albumModel.albumName;
    self.listView.backgroundColor = ESColor.systemBackgroundColor;
    
    self.bottomMoreToolVC.albumId = self.albumModel.albumId;
    [self reloadDataByType];
}

- (void)setupSubViews {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"smart_photo_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(moreAction:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)reloadDataByType {
    weakfy(self)
    dispatch_async([ESSmartPhotoAsyncManager shared].requestHandleQueue, ^{
        self.listModule.timeLineType = ESTimelineFrameItemTypeDay;
        ESSmartPhotoListModel *mockModel = [ESSmartPhotoListModel reloadDataFromDBAlbumId:self.albumModel.albumId];
        dispatch_async(dispatch_get_main_queue(), ^{
            strongfy(self)
            if (mockModel.sections.count == 0) {
                [self showEmpty:YES];
            } else {
                [self showEmpty:NO];
            }
            [self.listModule reloadData:mockModel];
            self.listModule.album = self.albumModel;
            self.title = [self.listModule countOfAllPic] > 0 ?
                         [NSString stringWithFormat:@"%@(%lu)", self.albumModel.albumName, [self.listModule countOfAllPic]] : self.albumModel.albumName;
        });
    });
}

- (void)moreAction:(id)sender {
    self.moreActionVC.canSelecte = self.listModule.listModel.sections.count > 0;
    [self.moreActionVC showFrom:self];
}

- (ESAlbumMoreActionVC *)moreActionVC {
    if (!_moreActionVC) {
        _moreActionVC = [[ESAlbumMoreActionVC alloc] init];
        _moreActionVC.delegate = self;
    }
    return _moreActionVC;
}

- (ESAddPhotoActionVC *)addActionVC {
    if (!_addActionVC) {
        _addActionVC = [[ESAddPhotoActionVC alloc] init];
        _addActionVC.delegate = self;
    }
    return _addActionVC;
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet didMenuSelectItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    if (![self isChooseSelectMenuItem:item rowAtIndexPath:index]) {
        return;
    }
    
    if (actionSheet == self.addActionVC) {
        if (index == ESAddPhotoActionTypeLocal) {
            ESLocalPhotoSelectVC *vc = [[ESLocalPhotoSelectVC alloc] init];
            vc.category = @"photo";
            vc.uploadDir = @"";
            vc.uploadAlbumModel = self.albumModel;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        if (index == ESAddPhotoActionTypeAoSpace) {
            ESAoSpacePhotoSelectVC *aoSpaceSelectVC = [[ESAoSpacePhotoSelectVC alloc] init];
            aoSpaceSelectVC.uploadAlbumModel = self.albumModel;
            [self.navigationController pushViewController:aoSpaceSelectVC animated:YES];
            return;
        }
    }
    
    if (index == ESAlbumMoreActionTypeSelecte) {
        self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
        [self updateShowStyle];
        return;
    }
    
    if (index == ESAlbumMoreActionTypeAdd) {
        [self.addActionVC showFrom:self];
        return;
    }
    
    if (index == ESAlbumMoreActionTypeRename) {
        ESAlbumInfoEditeVC *vc = [[ESAlbumInfoEditeVC alloc] init];
        vc.value = self.albumModel.albumName;
        vc.editeType = ESAlbumInfoEditeTypeName;
        vc.albumModel = self.albumModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (index == ESAlbumMoreActionTypeDelete) {
        [self showDeleteAlbumDialog];
        return;
    }
}

- (void)showDeleteAlbumDialog {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"album_deleted", @"确定删除相簿“%@”吗？相册内的文件将不会被删除。"),
                         self.albumModel.albumName];
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
    
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"album_deleteAlbum", @"删除相簿") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showLoading:YES];
        NSNumber *deleteAlbumId = @([self.albumModel.albumId integerValue]);
        [ESAlbumModifyModule deleteAlbumIds: @[deleteAlbumId]
                                 completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
                });
                [ESSmartPhotoDataBaseManager.shared deletAlbumDBDataWithAlbumIds:@[self.albumModel.albumId]];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [ESToast dismiss];
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

- (void)actionSheetDidSelectCancel:(ESBaseActionSheetVC *)actionSheet {
    
}

- (BOOL)isChooseSelectMenuItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    return item.canSelectedType;
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"Precious_photos", @"珍贵照片，值得永久保存");
}

@end
