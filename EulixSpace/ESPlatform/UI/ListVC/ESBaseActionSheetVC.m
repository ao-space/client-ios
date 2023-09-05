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
//  ESActionSheetVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseActionSheetVC.h"
#import "ESSortSheetHeaderView.h"
#import "UIWindow+ESVisibleVC.h"
#import "UIViewController+ESPresent.h"
#import "ESBaseActionSheetListModule.h"

@interface ESBaseActionSheetVC ()

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) ESSortSheetHeaderView *headerView;
@property (nonatomic, strong) ESBaseActionSheetListModule *listModule;

@end

@implementation ESBaseActionSheetVC

- (void)showFrom:(UIViewController *)vc {
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0,  size.width, size.height - 330, 330);
    [vc es_presentViewController:self animated:YES completion:^{
    }];
}

- (void)hidden:(BOOL)immediately {
    [self es_dismissViewControllerAnimated:!immediately completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    self.headerView.layer.cornerRadius = 10.0f;
    self.headerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    self.view.backgroundColor = ESColor.clearColor;
    self.listModule.listView = self.listView;
    
    __weak typeof(self) weakSelf = self;
    self.headerView.cancelActionBlock = ^() {
        __strong typeof(weakSelf) self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(actionSheetDidSelectCancel:)]) {
            [self.delegate actionSheetDidSelectCancel:self];
         }
        [self hidden:NO];
    };
}

- (void)setupViews {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_bottom).offset(- [self contentHeight]);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(46.0f);
    }];
    
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (CGFloat)contentHeight {
    return 330.0f;
}

- (ESSortSheetHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESSortSheetHeaderView alloc] initWithFrame:CGRectZero];
    }
    return _headerView;
}

- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero];
        _listView.delegate = self.listModule;
        _listView.dataSource = self.listModule;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.scrollEnabled = YES;
        _listView.bounces = NO;
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

- (ESBaseActionSheetListModule *)listModule {
    if (!_listModule) {
        _listModule = [[[self listModuleClass] alloc] init];
        _listModule.actionSheetVC = self;
    }
    return _listModule;
}

- (Class)listModuleClass {
    return [ESBaseTableListModule class];
}

@end
