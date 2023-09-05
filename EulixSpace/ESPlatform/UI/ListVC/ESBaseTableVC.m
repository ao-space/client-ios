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
//  ESBaseTableVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseTableVC.h"
#import "ESBaseTableListModule.h"
#import "MJRefresh.h"
#import "ESMJHeader.h"
@interface ESBaseTableVC ()

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) ESBaseTableListModule *listModule;

@end

@implementation ESBaseTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.listModule.listView = self.listView;
    
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self es_setupViews];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [self loadViewIfNeeded];
//}

- (void)es_setupViews {
    [self.view addSubview:self.listView];
   
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(self.navigationController.isNavigationBarHidden ? (0 + self.listEdgeInsets.top) : (kTopHeight + self.listEdgeInsets.top));
        make.left.mas_equalTo(self.view.mas_left).inset(self.listEdgeInsets.left);
        make.right.mas_equalTo(self.view.mas_right).inset(self.listEdgeInsets.right);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(self.listEdgeInsets.bottom);
    }];
    
    if ([self haveHeaderPullRefresh]) {
        [self setupPullRefresh];
    }
}

- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero];
        _listView.delegate = self.listModule;
        _listView.dataSource = self.listModule;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.scrollEnabled = YES;
        _listView.bounces = [self haveHeaderPullRefresh];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.estimatedRowHeight = 60;
        
        _listView.backgroundColor = ESColor.systemBackgroundColor;
    
        _listView.estimatedSectionHeaderHeight = 0;
        _listView.estimatedSectionFooterHeight = 0;
      
        _listView.tableFooterView = [UIView new];
        if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_listView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_listView setLayoutMargins:UIEdgeInsetsZero];
        }
        if (@available(iOS 15.0, *)) {
            _listView.sectionHeaderTopPadding = 0;
        }
    }
    return _listView;
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (void)pullRefreshData {

}

- (void)setupPullRefresh {
    weakfy(self);
    self.listView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        strongfy(self);
        [self pullRefreshData];
    }];
}

- (void)finishPullRefresh {
    [self.listView.mj_header endRefreshing];
}

- (ESBaseTableListModule *)listModule {
    if (!_listModule) {
        _listModule = (ESBaseTableListModule *)[[[self listModuleClass] alloc] init];
        _listModule.tableVC = self;
        _listModule.listView = self.listView;
    }
    return _listModule;
}

- (Class)listModuleClass {
    return [ESBaseTableListModule class];
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsZero;
}

@end
