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
//  ESMeSettingController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMeSettingController.h"
#import "ESMeSettingCell.h"
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
#import "ESDeveloperVC.h"
#import "ESBindSecurityEmailBySecurityCodeController.h"

@interface ESMeSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) ESCellModel * cacheModel;
@property (nonatomic, strong) ESCellModel * securitySettingModel;

@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;
@end

@implementation ESMeSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"common_setting", @"设置");
   // self.view.backgroundColor = [UIColor s]
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    weakfy(self)
    __weak typeof(ESCellModel *) weakmodel = self.cacheModel;
    [ESCacheCleanTools businessCacheSizeWithCompletion:^(NSString * _Nonnull totalSize, NSArray<ESBusinessCacheInfoItem *> * _Nonnull cacheInfoList) {
        weakmodel.value = totalSize;
        [weak_self.tableView reloadData];
    }];
    if ([ESAccountInfoStorage isAdminOrAuthAccount]) {
        weakfy(self);
        [ESSecurityEmailMamager reqSecurityEmailInfo:^(ESSecurityEmailSetModel * _Nonnull model) {
            weak_self.securitySettingModel.value = @"";
            weak_self.emailInfo = model;
            [weak_self.tableView reloadData];
        } notSet:^{
            weak_self.emailInfo = nil;
            //weak_self.securitySettingModel.value = NSLocalizedString(@"Not set", @"未设置");
            weak_self.securitySettingModel.valueColor = [UIColor es_colorWithHexString:@"#F6222D"];
            [weak_self.tableView reloadData];
        }];
    }
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    if ([ESAccountInfoStorage isAdminOrAuthAccount] || ESBoxManager.activeBox.boxType == ESBoxTypeMember) {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"security setting", @"安全");
        model.hasArrow = YES;
        model.onClick = ^{
            ESSecuritySettimgController * ctl = [ESSecuritySettimgController new];
            ctl.emailInfo = weak_self.emailInfo;
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"message_notificcation", @"消息通知");
        model.hasArrow = YES;
        model.onClick = ^{
            ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
            [weak_self.navigationController pushViewController:pushVC animated:YES];
        };
        [self.dataArr addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"setting_clear_manager", @"缓存管理");
        model.hasArrow = YES;
        __weak typeof(ESCellModel *) weakmodel = model;
        [ESCacheCleanTools businessCacheSizeWithCompletion:^(NSString * _Nonnull totalSize, NSArray<ESBusinessCacheInfoItem *> * _Nonnull cacheInfoList) {
            weakmodel.value = totalSize;
            [weak_self.tableView reloadData];
        }];
    
        model.onClick = ^{
            ESSettingCacheManagerVC *cacheManagerVC = [[ESSettingCacheManagerVC alloc] init];
            [weak_self.navigationController pushViewController:cacheManagerVC animated:YES];
        };
        self.cacheModel = model;
        [self.dataArr addObject:model];
    }
    if (ESBoxManager.activeBox.boxType == ESBoxTypePairing) {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"me_developer", @"开发者选项");
        model.hasArrow = YES;
        model.onClick = ^{
            ESDeveloperVC *vc = [[ESDeveloperVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;
    }
    
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"me_about", @"关于");
        model.hasArrow = YES;
        model.lastCell = YES;
        model.onClick = ^{
            ESAboutViewController *next = [ESAboutViewController new];
            [weak_self.navigationController pushViewController:next animated:YES];
        };
        [self.dataArr addObject:model];
    }
 
}

//- (void)showClearCacheHint {
//    //清除缓存    mine.click.clearCache
//    weakfy(self);
//    [MobClick event:@"mine.click.clearCache"];
//    NSString *title = [NSString stringWithFormat:TEXT_ME_CONFIRM_THE_DELETION_TITLE, self.cacheModel.value];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
//                                                                   message:title
//                                                            preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *confirm = [UIAlertAction actionWithTitle:TEXT_CONFIRM_THE_DELETION
//                                                      style:UIAlertActionStyleDestructive
//                                                    handler:^(UIAlertAction *_Nonnull action) {
//                                                        [weak_self clearCache];
//                                                    }];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
//                                                     style:UIAlertActionStyleCancel
//                                                   handler:^(UIAlertAction *_Nonnull action){
//
//                                                   }];
//
//    [alert addAction:confirm];
//    [alert addAction:cancel];
//    [self presentViewController:alert animated:YES completion:nil];
//}

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
    ESMeSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell"];
    ESCellModel * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model = [self.dataArr getObject:indexPath.row];
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
        [tableView registerClass:[ESMeSettingCell class] forCellReuseIdentifier:@"ESMeSettingCell"];
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
