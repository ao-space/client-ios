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
//  ESMemoriesDetailPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesDetailPageVC.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESBaseViewController+Status.h"
#import "ESMemoriesPicPlayer.h"
#import "ESPicModel.h"
#import "ESBottomSelectedOperateVC.h"
#import "ESSelectedTopToolVC.h"
#import "ESBoxManager.h"
#import "ESSmartPhotoAsyncManager.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshStateHeader.h"
#import "ESToast.h"
#import "ESMemoriesDetailMoreActionVC.h"
#import "ESAlbumModifyModule.h"
#import "ESMemoriesCustomNavigationBar.h"
#import "NSDate+Format.h"
#import "UIButton+ESTouchArea.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESMJHeader.h"

@interface ESMemoriesDetailPageVC () <ESSmartPhotoListModuleProtocol, ESActionSheetVCProtocol>

@property (nonatomic, strong) UICollectionView *listView;
@property (nonatomic, strong) ESMemoriesDetailListModule *listModule;

@property (nonatomic, strong) ESBottomSelectedOperateVC *bottomMoreToolVC;
@property (nonatomic, strong) ESSelectedTopToolVC *topSelecteToolVC;
@property (nonatomic, strong) ESMemoriesDetailMoreActionVC *moreActionVC;

@property (nonatomic, strong) UIButton *backBt;
@property (nonatomic, strong) UIButton *moreActionBt;

@property (nonatomic, strong) ESMemoriesCustomNavigationBar *customNavigationBar;

@property (nonatomic, strong) NSIndexPath *lastAccessed;
@property (nonatomic, assign) BOOL isSelectedPanSelectStartCell;
@property (nonatomic, assign) CGRect firstAccessedRect;
@property (nonatomic, strong) NSMutableArray *preSelectIndexList;

@end

@implementation ESMemoriesDetailPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self setupViews];
    [self setupListModule];
    [self setupPullRefresh];
    [self setupAsyncCallback];
    [self setupNavigationBar];
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[ESSmartPhotoAsyncManager shared] tryAsyncData];
    [self updateShowStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topSelecteToolVC hidden];
    [self.bottomMoreToolVC hidden];
}

- (BOOL)es_needShowNavigationBar {
    return NO;
}

- (void)setupNavigationBar {
    [self.view addSubview:self.backBt];
    [self.backBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).inset(26.0f);
        make.top.mas_equalTo(self.view).inset(62.0f);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [self.view addSubview:self.moreActionBt];
    [self.moreActionBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backBt.mas_centerY);
        make.right.equalTo(self.view).inset(14.0f);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.albumModel.createdAt];
    NSString *time = [date stringFromFormat:@"YYYY年MM月dd日"];
    NSString *titleText;
    if ([self.albumModel.albumName containsString:@","]) {
        NSArray *titleList = [self.albumModel.albumName componentsSeparatedByString:@","];
        titleText = titleList[0];
        if (titleList.count > 1) {
            time = titleList[1];
        }
    } else {
        titleText = self.albumModel.albumName;
    }
    self.customNavigationBar = [[ESMemoriesCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kStatusBarHeight + 53)
                                                                              title:titleText
                                                                           subTitle:time];
    weakfy(self)
    self.customNavigationBar.goActionBlock = ^() {
        strongfy(self)
        [self backAction];
    };
    
    self.customNavigationBar.moreActionBlock = ^() {
        strongfy(self)
        [self moreAction];
    };
    [self.view addSubview:self.customNavigationBar];
    if ([self.listModule needShowCover]) {
        self.customNavigationBar.alpha = 0;
    } else {
        self.customNavigationBar.alpha = 1;
    }
}

- (void)setupPullRefresh {
//    self.listView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//        [[ESSmartPhotoAsyncManager shared] tryAsyncData];
//    }];
}

- (void)removePullRefresh {
    self.listView.mj_header = nil;
}

- (void)setupAsyncCallback {
    [[ESSmartPhotoAsyncManager shared] addAsyncUpdateObserver:self];
}

- (void)asyncUpdate:(ESSmartPhotoAsyncType)type asyncFinish:(BOOL)asyncFinish hasNewContent:(BOOL)hasNewContent {
    if (hasNewContent) {
        [self reloadDataByType];
        [ESToast dismiss];
    }
    if (asyncFinish) {
        [self.listView.mj_header endRefreshing];
    }
}

- (void)setupListModule {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
    [self reloadDataByType];
}

- (void)setupViews {
    [self.view addSubview:self.listView];
    if ([self.listModule needShowCover]) {
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0f);
        }];
    } else {
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(kStatusBarHeight + 56);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0f);
        }];
    }
}

- (UICollectionView *)listView {
    if (!_listView) {
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.listViewLayout];
        _listView.dataSource = self.listModule;
        _listView.delegate = self.listModule;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.backgroundColor = ESColor.systemBackgroundColor;
        _listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _listView;
}

- (ESMemoriesDetailListModule *)listModule {
    if (!_listModule) {
        _listModule = [[ESMemoriesDetailListModule alloc] initWithListView:_listView];
        _listModule.delegate = self;
        _listModule.parentVC = self;
        _listModule.albumModel = self.albumModel;
        weakfy(self)
        _listModule.scrollUpdateBlock = ^(CGFloat offsetY) {
            strongfy(self)
            if(self.listModule.showStyle == ESSmartPhotoPageShowStyleSelecte || ![self.listModule needShowCover]) {
                return;
            }
            CGFloat alpha = 0;
            if(offsetY <= 80) {
                alpha = 1;
            }
            
            if(offsetY >= 200) {
                alpha = 0;
            }
            self.customNavigationBar.alpha = 1 - alpha;
            self.backBt.alpha = alpha;
            self.moreActionBt.alpha = alpha;
        };
    }
    return _listModule;
}

- (UICollectionViewFlowLayout *)listViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return layout;
}

- (ESBottomSelectedOperateVC *)bottomMoreToolVC {
    if (!_bottomMoreToolVC) {
        _bottomMoreToolVC = [[ESBottomSelectedOperateVC alloc] init];
    }
    return _bottomMoreToolVC;
}

- (ESSelectedTopToolVC *)topSelecteToolVC {
    if (!_topSelecteToolVC) {
        _topSelecteToolVC = [[ESSelectedTopToolVC alloc] init];
        _topSelecteToolVC.limitSelectStyle = YES;

        __weak typeof (self) weakSelf = self;
        _topSelecteToolVC.cancelActionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            [self.topSelecteToolVC hidden];
            [self.bottomMoreToolVC hidden];
            [self.listModule cleanAllSeleted];
            [self.listModule setShowStyle:ESSmartPhotoPageShowStyleNormal];
            [self updateShowStyle];
            [self topSelecteToolCancel];
        };
        
        _topSelecteToolVC.selecteAllActionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            if ([self.topSelecteToolVC isAllSelected]) {
                [self.listModule selectedAll];
                [self updateShowStyle];
            } else {
                [self.listModule cleanAllSeleted];
                [self updateShowStyle];
            }
        };
    }
    return _topSelecteToolVC;
}

- (void)topSelecteToolCancel {
    
}


- (void)reloadDataByType {
    NSArray<ESPicModel *> *picList = [ESSmartPhotoDataBaseManager.shared getPicsFromDBWithAlbumId:self.albumModel.albumId];
    [self showEmpty:picList.count <= 0];
    [self.listModule reloadData:picList];
}

- (void)tryAsyncData {
    [[ESSmartPhotoAsyncManager shared] tryAsyncData];
}

#pragma mark - showStyle
- (void)finishActionAndStaySelecteStyleWithCleanSelected {
    [self.listModule cleanAllSeleted];
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
}

- (void)finishActionAndStaySelecteStyle {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
}

- (void)finishActionShowNormalStyleWithCleanSelected {
    [self.listModule cleanAllSeleted];
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
    [self updateShowStyle];
}

- (void)tryAsyncDataWithRename:(NSString *)newName uuid:(NSString *)uuid {
    ESPicModel *pic = [[ESSmartPhotoDataBaseManager shared] getPicByUuid:uuid];
    if (!pic) {
        return;
    }
    NSString *oldPath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
    
    pic.name = newName;
    if ([[ESSmartPhotoDataBaseManager shared] insertOrUpdatePicsToDB:@[pic]]) {
        NSString *newPath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    }
}

- (void)showViewNormalStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    if ([self.listModule needShowCover]) {
        [_listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0f);
        }];
    } else {
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(kStatusBarHeight + 56);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0f);
        }];
    }
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
    self.customNavigationBar.hidden = NO;
    self.backBt.hidden = NO;
    self.moreActionBt.hidden = NO;
}

- (void)showSelectStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    [_listView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kStatusBarHeight + 56);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0f);
    }];

    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    self.customNavigationBar.hidden = YES;
    self.backBt.hidden = YES;
    self.moreActionBt.hidden = YES;
}

- (void)showSelectedStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    CGFloat toolHeight = 50 + kBottomHeight;
    [_listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(kStatusBarHeight + 56);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(toolHeight);
    }];
        
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    
    self.customNavigationBar.hidden = YES;
    self.backBt.hidden = YES;
    self.moreActionBt.hidden = YES;
}

- (void)showSelectToolView {
    [self.topSelecteToolVC showFrom:self];
    [self.topSelecteToolVC updateSelectdCount:0 isAllSelected:NO];
}

- (void)actionSheetDidSelectCancel:(ESBaseActionSheetVC *)actionSheet {
    
}

#pragma mark -
- (void)didSelectPic:(ESPicModel *)pic indexPath:(NSIndexPath *)index {
    [self updateShowStyle];
}

- (void)updateShowStyle {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        [self showViewNormalStyle];
        [self.listModule cleanAllSeleted];
        [self updateSelectedToolStatus];
        return;
    }
    NSInteger selectedCount = [self.listModule selectedCount];
    if (selectedCount > 0) {
        [self showSelectedStyle];
    } else {
        [self showSelectStyle];
    }
    [self updateSelectedToolStatus];
}

- (void)updateSelectedToolStatus {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        [self.topSelecteToolVC updateSelectdCount:0 isAllSelected:NO];
        [self.topSelecteToolVC hidden];
        [self.bottomMoreToolVC hidden];
        return;
    }
    
    NSInteger selectedCount = [self.listModule selectedCount];
    if (selectedCount > 0) {
        [self.topSelecteToolVC showFrom:self];
        [self.bottomMoreToolVC showFrom:self];
    } else {
        [self.topSelecteToolVC showFrom:self];
        [self.bottomMoreToolVC hidden];
    }
    
    [self updateTopSelectedStatus];
    [self updateBottomSeletedStatus];
}
- (void)updateTopSelectedStatus {
    BOOL isAllSelected = [self.listModule isAllSelected];
    [self.topSelecteToolVC updateSelectdCount:[self.listModule selectedCount] isAllSelected:isAllSelected];
}

- (void)updateBottomSeletedStatus {
    NSArray *uuidList = [self.listModule.selectedMap allKeys];
    NSArray<ESPicModel *> *picList = [[ESSmartPhotoDataBaseManager shared] getPicByUuids:uuidList];
    
    [self.bottomMoreToolVC updateSelectedList:picList];
}

#pragma mark - Empty

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"file_none_photos", @"您还没有任何图片哦");
}

- (void)didBecomeActive:(id _Nullable)sender {
    if (self.viewLoaded && self.view.window) {
        [self updateShowStyle];
    }
}

- (void)playAlbum {
    ESMemoriesPicPlayer *player = [[ESMemoriesPicPlayer alloc] init];
    NSArray<ESPicModel *> * pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBWithAlbumId: self.albumModel.albumId];
    
    NSMutableArray *picList = [NSMutableArray array];
    [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pic isPicture]) {
            [picList addObject:pic];
        }
    }];
    
    NSString *titleText;
    if ([self.albumModel.albumName containsString:@","]) {
        NSArray *titleList = [self.albumModel.albumName componentsSeparatedByString:@","];
        titleText = titleList[0];
    } else {
        titleText = self.albumModel.albumName;
    }
    
    [player updateTitleText:titleText
                    message:[NSString stringWithFormat:@"%lu年%lu月%lu日",pics[0].date_year,pics[0].date_month, pics[0].date_day]];
    player.picList = picList;

    [self.navigationController pushViewController:player animated:YES];
}

- (ESMemoriesDetailMoreActionVC *)moreActionVC {
    if (!_moreActionVC) {
        _moreActionVC = [[ESMemoriesDetailMoreActionVC alloc] init];
        _moreActionVC.delegate = self;
    }
    return _moreActionVC;
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet didMenuSelectItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    if (index == ESMemoriesDetailMoreActionTypeSelecte) {
        self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
        [self updateShowStyle];
        return;
    }
    
    if (index == ESMemoriesDetailMoreActionTypeCollection) {
        [self likeAlbum:self.albumModel];
        return;
    }
    
    if (index == ESMemoriesDetailMoreActionTypeDelete) {
        [self showDeleteAlbumDialog:self.albumModel];
        return;
    }
}

- (void)likeAlbum:(ESAlbumModel *)albumModel {
    if (albumModel == nil) {
        return;
    }
    BOOL isCollection = !albumModel.collection;
//    weakfy(self)
    [ESAlbumModifyModule collectionAlbum:isCollection
                                 albumId:[albumModel.albumId integerValue]
                              completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
//        strongfy(self)
        if (success) {
            albumModel.collection = isCollection;
            [ESSmartPhotoDataBaseManager.shared insertOrUpdateAlbumsToDB:@[albumModel]];
            [ESToast toastSuccess: isCollection ? @"收藏成功" : @"取消收藏成功"];
            return;
        }
        [ESToast toastSuccess:isCollection ? @"收藏失败" : @"取消收藏失败"];
    }];
}

- (void)showDeleteAlbumDialog:(ESAlbumModel *)albumModel {
    NSString *message = @"是否确定删除？回忆删除后将无法恢复，回忆里的文件不会被删除。";
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
    
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:@"删除回忆" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showLoading:YES];
        NSNumber *deleteAlbumId = @([albumModel.albumId integerValue]);
        [ESAlbumModifyModule deleteAlbumIds: @[deleteAlbumId]
                                 completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
                });
                [ESSmartPhotoDataBaseManager.shared deletAlbumDBDataWithAlbumIds:@[albumModel.albumId]];
                [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)isChooseSelectMenuItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    if ( !item.isSelectedTyple && index == 0) {
        return YES;
    }
    return NO;
}

- (UIButton *)backBt {
    if (!_backBt) {
        _backBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_backBt setImage:[UIImage imageNamed:@"memories_detail_back"] forState:UIControlStateNormal];
        [_backBt setTitle:nil forState:UIControlStateNormal];
        [_backBt addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _backBt;
}

- (UIButton *)moreActionBt {
    if (!_moreActionBt) {
        _moreActionBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_moreActionBt setImage:[UIImage imageNamed:@"memories_detail_more"] forState:UIControlStateNormal];
        [_moreActionBt setTitle:nil forState:UIControlStateNormal];
        [_moreActionBt addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        [_moreActionBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _moreActionBt;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)moreAction {
    self.moreActionVC.canSelecte = self.listModule.listModel.count > 0;
    self.moreActionVC.isCollection = self.albumModel.collection;
    [self.moreActionVC showFrom:self];
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
           CGPoint  panSelectStartPoint = [gestureRecognizer locationInView:self.listView];
           NSIndexPath *indexPath = [self.listView indexPathForItemAtPoint:panSelectStartPoint];
            _isSelectedPanSelectStartCell = [self.listModule isCellItemSelectedWithIndex:indexPath];
            _firstAccessedRect = [self.listView cellForItemAtIndexPath:indexPath].frame;
            _preSelectIndexList = [NSMutableArray array];
        return;

       }
    
    float pointerX = [gestureRecognizer locationInView:self.listView].x;
    float pointerY = [gestureRecognizer locationInView:self.listView].y;

    for (UICollectionViewCell *cell in self.listView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [self.listView indexPathForCell:cell];
            if (_lastAccessed != touchOver) {
                CGRect lastAccessedRect = [self.listView cellForItemAtIndexPath:touchOver].frame;
                
                float canAccessCellSX = MIN(CGRectGetMinX(lastAccessedRect), CGRectGetMinX(_firstAccessedRect)) - 1.0;
                float canAccessCellEX = MAX(CGRectGetMaxX(lastAccessedRect), CGRectGetMaxX(_firstAccessedRect)) + 1.0;
                float canAccessCellSY = MIN(CGRectGetMinY(lastAccessedRect), CGRectGetMinY(_firstAccessedRect)) - 1.0;
                float canAccessCellEY = MAX(CGRectGetMaxY(lastAccessedRect), CGRectGetMaxY(_firstAccessedRect)) + 1.0;
                
                NSMutableArray *newSelectIndexList = [NSMutableArray array];
                for (UICollectionViewCell *cell in self.listView.visibleCells) {
                    NSIndexPath *index = [self.listView indexPathForCell:cell];
                    if (CGRectGetMinX(cell.frame) >= canAccessCellSX &&
                        CGRectGetMaxX(cell.frame) <= canAccessCellEX &&
                        CGRectGetMinY(cell.frame) >= canAccessCellSY &&
                        CGRectGetMaxY(cell.frame) <= canAccessCellEY ) {
                        [self.listModule collectionView:self.listView touchItemAtIndexPath:index didSelect:!_isSelectedPanSelectStartCell];
                        
                        [newSelectIndexList addObject:index];
                    } else if ([_preSelectIndexList containsObject:index]) {
                        [self.listModule collectionView:self.listView touchItemAtIndexPath:index didSelect:_isSelectedPanSelectStartCell];
                    }
                }
                
                _preSelectIndexList = newSelectIndexList;
                _lastAccessed = touchOver;
            }
        }
    }
    
    if ( pointerY >= (self.listView.contentOffset.y + self.listView.frame.size.height - 100) &&
        pointerY <= self.listView.contentOffset.y + self.listView.frame.size.height &&
        pointerY < self.listView.contentSize.height) {
        weakfy(self)
        [UIView animateWithDuration:0.1 animations:^{
            strongfy(self)
            self.listView.contentOffset =  CGPointMake(self.listView.contentOffset.x, MIN(self.listView.contentOffset.y + 16, self.listView.contentSize.height - self.listView.frame.size.height));

        }];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _preSelectIndexList = nil;
        self.listView.scrollEnabled = YES;
    }
}

@end
