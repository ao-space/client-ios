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
//  ESAppletMoreOperateViewModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletMoreOperateViewModel.h"
#import "ESAppletMoreOperateItemCell.h"
#import "ESAppletMoreOperateItemViewModel.h"
#import "ESAppletManager.h"
#import "ESToast.h"
#import "ESAppletManager.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESAccountInfoStorage.h"


NSString * const gESAppletMoreOperateItemCellIdentifier = @"gESAppletMoreOperateItemCellIdentifier";

NSString *const ESMoreOperationNewVersionKey = @"newVersion";

@interface ESAppletMoreOperateViewModel ()

@property (nonatomic, copy) NSArray<ESAppletMoreOperateItemViewModel *> *appletOperateItemlList;
@property (nonatomic, weak) UICollectionView *listView;
@property (nonatomic, weak) id<ESAppletMoreOperateProtocl> delegate;
@property (nonatomic, weak) ESAppletInfoModel *appletInfo;

@end

@implementation ESAppletMoreOperateViewModel

- (instancetype)initWithListView:(UICollectionView *)listView
                 operateDeleaget:(id<ESAppletMoreOperateProtocl>)delegate
                      appletInfo:(ESAppletInfoModel *)appletInfo {
    if (self = [super init]) {
        _listView = listView;
        _delegate = delegate;
        _appletInfo = appletInfo;
        [self setupAppletOperateItemList];
    }
    return self;
}

- (void)setupAppletOperateItemList {
    if (![ESAccountInfoStorage currentAccountIsAdminType]) {
        ESAppletMoreOperateItemViewModel *itemViewModel3 = [[ESAppletMoreOperateItemViewModel alloc] init];
        itemViewModel3.name = NSLocalizedString(@"close_applet", @"退出应用") ;
        itemViewModel3.icon = @"applet_close";
        itemViewModel3.operateType = ESAppletOperateTypeClose;
 
        

        ESAppletMoreOperateItemViewModel *itemViewModel4 = [[ESAppletMoreOperateItemViewModel alloc] init];
        itemViewModel4.name = NSLocalizedString(@"set_applet", @"设置") ;
        itemViewModel4.icon = @"apple_setting";
        itemViewModel4.operateType = ESAppletOperateTypeSetting;
        
        self.appletOperateItemlList = @[itemViewModel3,itemViewModel4];
        return;
    }
    
    ESAppletMoreOperateItemViewModel *itemViewModel1 = [[ESAppletMoreOperateItemViewModel alloc] init];
    itemViewModel1.name = NSLocalizedString(@"update_applet", @"更新");
    itemViewModel1.icon = @"gengxin";
    itemViewModel1.operateType = ESAppletOperateTypeUpdate;
    itemViewModel1.operateInfo = @{ ESMoreOperationNewVersionKey : @([self.appletInfo hasNewVersion])};
    
    ESAppletMoreOperateItemViewModel *itemViewModel2 = [[ESAppletMoreOperateItemViewModel alloc] init];
    itemViewModel2.name = NSLocalizedString(@"uninstall_applet", @"卸载") ;
    itemViewModel2.icon = @"xiezai";
    itemViewModel2.operateType = ESAppletOperateTypeUninstall;
    
    
    ESAppletMoreOperateItemViewModel *itemViewModel3 = [[ESAppletMoreOperateItemViewModel alloc] init];
    itemViewModel3.name = NSLocalizedString(@"close_applet", @"退出") ;
    itemViewModel3.icon = @"applet_close";
    itemViewModel3.operateType = ESAppletOperateTypeClose;
    
    
    ESAppletMoreOperateItemViewModel *itemViewModel4 = [[ESAppletMoreOperateItemViewModel alloc] init];
    itemViewModel4.name = NSLocalizedString(@"set_applet", @"设置") ;
    itemViewModel4.icon = @"apple_setting";
    itemViewModel4.operateType = ESAppletOperateTypeSetting;
    
    
    self.appletOperateItemlList = @[itemViewModel1, itemViewModel2, itemViewModel3,itemViewModel4];
}

- (BOOL)isMemberAccount {
    return [ESAccountInfoStorage isMemberAccount];
}

- (void)newVersionUpdate {
    [self setupAppletOperateItemList];
    [self.listView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_appletOperateItemlList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESAppletMoreOperateItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:gESAppletMoreOperateItemCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row < self.appletOperateItemlList.count) {
        ESAppletMoreOperateItemViewModel *viewModel = self.appletOperateItemlList[indexPath.row];
        [cell bindViewModel:viewModel];
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.appletOperateItemlList.count) {
        return;
    }

    ESAppletMoreOperateItemViewModel *viewModel = self.appletOperateItemlList[indexPath.row];
    if (!viewModel) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(moreOperateVC:operateType:)]) {
        [self.delegate moreOperateVC:self.moreOperateVC operateType:viewModel.operateType];
    }
}

@end

