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
//  ESTodayInHistoryPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTodayInHistoryPageVC.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESBaseViewController+Status.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESTodayInHistoryMoreActionVC.h"
#import "ESPicModel.h"

@interface ESTodayInHistoryPageVC () <ESActionSheetVCProtocol>

@property (nonatomic, strong) ESTodayInHistoryMoreActionVC *moreActionVC;

@end

@implementation ESTodayInHistoryPageVC

- (void)viewDidLoad {
    self.enterPic = [ESSmartPhotoDataBaseManager.shared getPicByUuid:self.enterPic.uuid];

    if (self.albumModel == nil && self.enterPic != nil) {
       ESPicModel *picModel = [ESSmartPhotoDataBaseManager.shared getPicByUuid:self.enterPic.uuid];
       NSArray *albumIdList = picModel.albumIdList;
       NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeTodayInHistory];

        if (albumIdList.count <= 0 && albums.count > 0) {
            self.albumModel = albums[0];
        } else if (albumIdList.count > 0 && albums.count > 0) {
            [albums enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *albumIdSql = [@"#" stringByAppendingString:ESSafeString(album.albumId)];
                albumIdSql = [albumIdSql stringByAppendingString:@"#"];
                if ([albumIdList containsObject:albumIdSql]) {
                    self.albumModel = album;
                    *stop = YES;
                }
            }];
        }
    }
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)setupSubViews {
    self.title = @"历史的今天";
    self.listView.backgroundColor = ESColor.systemBackgroundColor;
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
                [self showRightBarItem:NO];
            } else {
                [self showEmpty:NO];
                [self showRightBarItem:YES];
            }
            [self.listModule reloadData:mockModel];
            self.listModule.album = self.albumModel;
            self.title = [self.listModule countOfAllPic] > 0 ?
                         [NSString stringWithFormat:@"%@(%lu)", @"历史的今天", [self.listModule countOfAllPic]] : @"历史的今天";
            [self tryScrollToEnterPicSection];
        });
    });
}

- (void)showRightBarItem:(BOOL)show {
    if (show == NO) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"smart_photo_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(moreAction:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)moreAction:(id)sender {
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeTodayInHistory];
    if (albums.count <= 0) {
        return;
    }
    __block NSInteger topSectionIndex = NSNotFound;
    [albums enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.albumModel.albumId isEqualToString:album.albumId]){
            topSectionIndex = idx;
            *stop = YES;
        }
    }];
    if (topSectionIndex == NSNotFound) {
        return;
    }
    
    self.moreActionVC.canSelecte = self.listModule.listModel.sections.count > 0;
    self.moreActionVC.listModel = self.listModule.listModel;
    self.moreActionVC.currentTopShowingSection = topSectionIndex;
    [self.moreActionVC showFrom:self];
}

- (void)tryScrollToEnterPicSection {
    if (self.enterPic == nil || self.listModule.showStyle == ESSmartPhotoPageShowStyleSelecte) {
        return;
    }
    __block NSInteger matchSectionIndex = NSNotFound;
    NSString *matchKey = [NSString stringWithFormat:@"%lu年%lu月%lu日", self.enterPic.date_year, self.enterPic.date_month, self.enterPic.date_day];
    [self.listModule.listModel.sections enumerateObjectsUsingBlock:^(ESSmartPhotoListSectionModel * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section.sectionSubtitle containsString:matchKey]) {
            matchSectionIndex = idx;
            *stop = YES;
        }
    }];
    
    if (matchSectionIndex != NSNotFound) {
        UICollectionViewLayoutAttributes *attribs = [self.listView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:matchSectionIndex]];
        CGPoint topOffset = CGPointMake(0, attribs.frame.origin.y - self.listView.contentInset.top - 51);
        [self.listView setContentOffset:topOffset animated:YES];
        self.enterPic = nil;
        return;
    }
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet didMenuSelectItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    if (![self isChooseSelectMenuItem:item rowAtIndexPath:index]) {
        return;
    }
        
    if (index == ESTodayInHistoryMoreActionTypeSelecte) {
        self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
        [self updateShowStyle];
        return;
    }
    // 滚动到对应的时间节点
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeTodayInHistory];
    NSInteger indexSection = index - 1;
    if (indexSection < 0 || indexSection >= albums.count) {
        return;
    }
    self.albumModel = albums[indexSection];
    [self reloadDataByType];
    return;
}

- (BOOL)isChooseSelectMenuItem:(id<ESActionSheetCellModelProtocol>)item rowAtIndexPath:(NSInteger)index {
    return item.canSelectedType;
}

- (ESTodayInHistoryMoreActionVC *)moreActionVC {
    if (!_moreActionVC) {
        _moreActionVC = [[ESTodayInHistoryMoreActionVC alloc] init];
        _moreActionVC.delegate = self;
    }
    return _moreActionVC;
}
- (NSString *)titleForEmpty {
    return NSLocalizedString(@"no_data_history_today", @"暂无任何内容");
}

@end
