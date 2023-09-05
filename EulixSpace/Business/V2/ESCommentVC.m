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
//  ESCommentVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCommentVC.h"
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
#import "ESLanguageVC.h"
#import "ESAccount.h"
#import "ESAccountManager.h"

#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "ESCacheManagerListModule.h"

@interface ESCommentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) ESCellMoelKFZ * cacheModel;
@property (nonatomic, strong) ESCellMoelKFZ * securitySettingModel;

@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;
@property (nonatomic, strong) ESCacheManagerListModule * listModule;
@end

@implementation ESCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_GENERAL;
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    if ([ESAccountInfoStorage isAdminOrAuthAccount] || ESBoxManager.activeBox.boxType == ESBoxTypeMember) {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"language", @"多语言");

        NSNumber *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"language_setting"];
        if(type.intValue == 0){
            model.value = NSLocalizedString(@"follow_system", @"跟随系统");
        }else if(type.intValue == 1){
            model.value = @"简体中文";
        }else if(type.intValue == 2){
            model.value = @"English";
        }
        model.hasArrow = YES;
        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;

    }
    
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"me_clear_cache", @"清除缓存");
        model.hasArrow = YES;
        self.cacheModel = model;
        [ESCacheCleanTools businessCacheSizeWithCompletion:^(NSString * _Nonnull totalSize, NSArray<ESBusinessCacheInfoItem *> * _Nonnull cacheInfoList) {
            weak_self.cacheModel.value = totalSize;
            [weak_self.tableView reloadData];
        }];
        model.onClick = ^{
            [weak_self onClearCache];
        };
        [self.dataArr addObject:model];
    }
}

- (void)onClearCache {
    weakfy(self)
    self.listModule = [[ESCacheManagerListModule alloc] init];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"clear_cache_data_notice", @"预计可释放%@空间，清理缓存可能需要一点时间，请耐心等待"),
                         self.cacheModel.value];
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc]initWithString:message
                                                                                  attributes:@{NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                                                                                               NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                               NSParagraphStyleAttributeName : paraStyle,
                                                                                             }];
    [actionSheetController setValue:attMessage forKey:@"attributedMessage"];
    
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"box_list_clear_title", @"清除") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ESToast.showLoading(NSLocalizedString(@"wait", @"请稍后"), self.view);
        [ESCacheCleanTools businessCacheSizeWithCompletion:^(NSString * _Nonnull totalSize, NSArray<ESBusinessCacheInfoItem *> * _Nonnull cacheInfoList) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                strongfy(self)
                [(ESCacheManagerListModule *)weak_self.listModule loadCacheData:cacheInfoList totalSize:totalSize];
                [(ESCacheManagerListModule *)weak_self.listModule cleanAllCache:weak_self.cacheModel.value block:^(NSString * _Nonnull cleanSize) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ESToast dismiss];
                        [ESToast toastSuccess:[NSString stringWithFormat:NSLocalizedString(@"clear_cache_data_clear_short", @"已清理并释放%@空间"),cleanSize.length > 0 ? cleanSize : @"0"]];
                        [weak_self initData];
                        [weak_self.tableView reloadData];
                    });
                }];
            });
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
    ESMeSettingCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell2"];
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
        [tableView registerClass:[ESMeSettingCell2 class] forCellReuseIdentifier:@"ESMeSettingCell2"];
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
