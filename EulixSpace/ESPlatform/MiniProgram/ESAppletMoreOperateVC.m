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
//  ESAppletMoreOperateVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletMoreOperateVC.h"
#import <Masonry/Masonry.h>
#import "ESAppletMoreOperateViewModel.h"
#import "ESAppletMoreOperateItemCell.h"
#import "ESAppletMoreOperateHeaderView.h"
#import "ESAppletMoreOperateFooterView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ESColor.h"
#import "UIImageView+ESWebImageView.h"
#import "UIViewController+ESPresent.h"

@interface ESAppletMoreOperateVC ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ESAppletMoreOperateHeaderView *headerView;
@property (nonatomic, strong) ESAppletMoreOperateFooterView *footerView;

@property (nonatomic, strong) ESAppletMoreOperateViewModel *listModel;
@property (nonatomic, strong) ESAppletInfoModel *appletInfo;
@property (nonatomic, weak)id<ESAppletMoreOperateProtocl> operateDelegate;

@end

@implementation ESAppletMoreOperateVC
- (instancetype)initWithAppletInfo:(ESAppletInfoModel *)appletInfo
                   operateDelegate:(id<ESAppletMoreOperateProtocl>)operateDelegate {
    if (self = [super init]) {
        _appletInfo = appletInfo;
        _operateDelegate = operateDelegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupListView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)haveNewVersionUpdate {
    [self.listModel newVersionUpdate];
}

- (void)setupListView {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-269.0f);
        make.height.mas_equalTo(54.0f);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(119.0f);
    }];
    
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.collectionView.mas_bottom);
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.listViewLayout];
        _collectionView.dataSource = self.listModel;
        _collectionView.delegate = self.listModel;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = ESColor.systemBackgroundColor;
        [_collectionView registerClass:[ESAppletMoreOperateItemCell class] forCellWithReuseIdentifier:gESAppletMoreOperateItemCellIdentifier];
    }
    return _collectionView;
}

- (ESAppletMoreOperateHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESAppletMoreOperateHeaderView alloc] initWithFrame:CGRectZero];
        _headerView.appletTitle.text = self.appletInfo.name;
        if (self.appletInfo.iconUrl.length > 0) {
            [self.headerView.appletIcon es_setImageWithURL:self.appletInfo.iconUrl placeholderImageName:nil];
        }
    }
    return _headerView;
}

- (ESAppletMoreOperateFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[ESAppletMoreOperateFooterView alloc] initWithFrame:CGRectZero];
        
        __weak typeof(self) weakSelf = self;
        _footerView.cancelBlock = ^(void) {
            __strong typeof(weakSelf) self = weakSelf;
            [self es_dismissViewControllerAnimated:YES completion:^{
            }];
        };
    }
    return _footerView;
}

- (ESAppletMoreOperateViewModel *)listModel {
    if (!_listModel) {
        _listModel = [[ESAppletMoreOperateViewModel alloc] initWithListView:_collectionView
                                                            operateDeleaget:self.operateDelegate
                                                                 appletInfo:self.appletInfo];
        _listModel.moreOperateVC = self;
    }
    return _listModel;
}

- (UICollectionViewFlowLayout *)listViewLayout {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 4;
    layout.itemSize = CGSizeMake(itemWidth, 99);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    return layout;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width / 4;
    CGFloat height = collectionView.bounds.size.height;
    return CGSizeMake(width, height);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   UIView *touchView = [touches anyObject].view;
    if ([touchView isEqual:self.collectionView] ||
        [touchView isEqual:self.headerView] ||
        [touchView isEqual:self.footerView]) {
        return;
    }
    [self es_dismissViewControllerAnimated:YES completion:nil];
}

@end
