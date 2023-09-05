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
//  ESSecretVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecretVC.h"
#import "ESMeSettingCell2.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "ESCacheCleanTools.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESLocalizableDefine.h"
#import "ESPushNewsSettingVC.h"
#import "ESAboutViewController.h"
#import "ESSecuritySettimgController.h"
#import "ESAccountInfoStorage.h"
#import "ESSettingCacheManagerVC.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESSecurityEmailMamager.h"
#import "ESV2PowerVC.h"

#import "ESBindSecurityEmailBySecurityCodeController.h"

@interface ESSecretVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) ESCellMoelKFZ * cacheModel;
@property (nonatomic, strong) ESCellMoelKFZ * securitySettingModel;

@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;
@end

@implementation ESSecretVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"privacy", @"隐私");
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"android_permission_manager", @"iOS权限管理");
        model.hasArrow = YES;
        model.lastCell = YES;
        model.onClick = ^{
            ESV2PowerVC *next = [ESV2PowerVC new];
            [weak_self.navigationController pushViewController:next animated:YES];
        };
        [self.dataArr addObject:model];
    }
}

- (void)clearCache {
    weakfy(self);
    [ESCacheCleanTools clearAllCache];
    [ESToast toastSuccess:TEXT_ME_ALREADY_CLEARED_CACHE];
    [ESCacheCleanTools cacheSizeWithCompletion:^(NSString *size) {
        [weak_self initData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESMeSettingCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell"];
    ESCellMoelKFZ * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellMoelKFZ * model = [self.dataArr getObject:indexPath.row];
    if (model.onClick) {
        model.onClick();
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESMeSettingCell2 class] forCellReuseIdentifier:@"ESMeSettingCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _tableView;
}

- (void)dealloc {
    
}

@end
