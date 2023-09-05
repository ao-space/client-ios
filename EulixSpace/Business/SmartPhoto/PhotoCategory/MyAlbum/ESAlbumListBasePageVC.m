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
//  ESAlbumBasePageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumListBasePageVC.h"
#import "ESAlbumBasePageListModule.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"
#import "ESAlbumInfoEditeVC.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshStateHeader.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESMJHeader.h"

@interface ESAlbumListBasePageVC ()

@property (nonatomic, strong) UICollectionView *listView;

@end

@implementation ESAlbumListBasePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    [self setupViews];
    
    self.title = NSLocalizedString(@"album_my", @"我的相簿");
    [self reloadAlbumData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadMyAlbumData];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)setupPullRefresh {
    weakfy(self)
    self.listView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        strongfy(self)
        [self loadMyAlbumData];
        [self.listView.mj_header endRefreshing];
    }];
}

- (void)loadMyAlbumData {
    weakfy(self)
    [ESSmartPhotoAsyncManager.shared loadAlbumsInfo:^{
        strongfy(self)
        [self reloadAlbumData];
    }];
}

- (void)reloadAlbumData {
   
}

- (void)setupViews {
    [self.view addSubview:self.listView];
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(4.0f);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-4.0f);
    }];
    
    [self setupPullRefresh];
}

- (void)addAlbumAction:(id)sender {
    ESAlbumInfoEditeVC *vc = [[ESAlbumInfoEditeVC alloc] init];
    vc.editeType = ESAlbumInfoEditeTypeAddAlbum;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionView *)listView {
    if (!_listView) {
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.listViewLayout];
        _listView.dataSource = self.listModule;
        _listView.delegate = self.listModule;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.backgroundColor = ESColor.systemBackgroundColor;
    }
    return _listView;
}

- (ESAlbumBasePageListModule *)listModule {
    if (!_listModule) {
        _listModule = [[self.listModuleClass alloc] initWithListView:_listView];
        _listModule.parentVC = self;
    }
    return _listModule;
}

- (Class)listModuleClass {
    return ESAlbumBasePageListModule.class;
}

- (UICollectionViewFlowLayout *)listViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(20, 23, 20, 23);
    return layout;
}

#pragma mark - Empty

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

@end
