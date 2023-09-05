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
//  ESLanguageVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLanguageVC.h"
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
#import "ESLanguageManager.h"
#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "NSBundle+CLLanguage.h"
#import "ESHomeCoordinator.h"
#import "ESLanguageManager.h"


@interface ESLanguageVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) ESCellMoelKFZ * cacheModel;
@property (nonatomic, strong) ESCellMoelKFZ * securitySettingModel;
@property (nonatomic, strong) UIButton * confirmButton;
@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;

@property (nonatomic, strong) NSNumber * type;

@property (nonatomic, assign) ESLanguageType languageType;
@end

@implementation ESLanguageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Language Settings", @"语言设置");
    [self initData];
    [self.tableView reloadData];
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    self.navigationItem.rightBarButtonItem = confirmItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    
   // [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"language_setting"];
    NSNumber *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"language_setting"];
    self.languageType =type.intValue;
    if(self.languageType == ESLanguageType_Chinese){
        weakfy(self)
        if ([ESAccountInfoStorage isAdminOrAuthAccount] || ESBoxManager.activeBox.boxType == ESBoxTypeMember) {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = NSLocalizedString(@"Auto", @"跟随系统");
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                
            };
            [self.dataArr addObject:model];
            self.securitySettingModel = model;

        }
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"简体中文";
            model.hasArrow = YES;
            model.isSelected = YES;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
        
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"English";
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
    }else if(self.languageType == ESLanguageType_English){
        weakfy(self)
        if ([ESAccountInfoStorage isAdminOrAuthAccount] || ESBoxManager.activeBox.boxType == ESBoxTypeMember) {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = NSLocalizedString(@"Auto", @"跟随系统");
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                
            };
            [self.dataArr addObject:model];
            self.securitySettingModel = model;

        }
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"简体中文";
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
        
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"English";
            model.hasArrow = YES;
            model.isSelected = YES;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
    }else{
        weakfy(self)
        if ([ESAccountInfoStorage isAdminOrAuthAccount] || ESBoxManager.activeBox.boxType == ESBoxTypeMember) {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = NSLocalizedString(@"Auto", @"跟随系统");
            model.isSelected = YES;
            model.hasArrow = YES;
            model.onClick = ^{
                
            };
            [self.dataArr addObject:model];
            self.securitySettingModel = model;

        }
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"简体中文";
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
        
        {
            ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
            model.title = @"English";
            model.hasArrow = YES;
            model.isSelected = NO;
            model.onClick = ^{
                ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
                [weak_self.navigationController pushViewController:pushVC animated:YES];
            };
            [self.dataArr addObject:model];
        }
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
    ESMeSettingCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell2"];
    ESCellMoelKFZ * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    cell.arrowIv.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellMoelKFZ * modelSed = [self.dataArr getObject:indexPath.row];
    NSMutableArray *array = [NSMutableArray new];
    for (ESCellMoelKFZ * model in self.dataArr) {
        if(modelSed.title == model.title){
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
        [array addObject:model];
    }
    self.dataArr = array;

    self.languageType = indexPath.row;
    [self.tableView reloadData];

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

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.frame = CGRectMake(0, 0, 80, 45);
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmButton setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ESColor.grayColor forState:UIControlStateNormal];
        _confirmButton.enabled = NO;
        _confirmButton.userInteractionEnabled = NO;
    }
    return _confirmButton;
}
- (void)dealloc {
    
}

/// 完成
- (void)confirmAction:(UIButton *)button {

    [[NSUserDefaults standardUserDefaults] setObject:@(self.languageType) forKey:@"language_setting"];
    if (self.languageType == ESLanguageType_System) {
        [ESLanguageManager systemLanguage];

    } else if (self.languageType == ESLanguageType_Chinese) {
        [ESLanguageManager setUserLanguage:@"zh-Hans"];
    } else {
        [ESLanguageManager setUserLanguage:@"en"];
    }
    [ESHomeCoordinator showHome];
    [ESToast toastSuccess:NSLocalizedString(@"Switch Success", @"切换成功")];
}

-(void)setLanguageType:(ESLanguageType )languageType{
    _languageType = languageType;
    [_confirmButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    self.confirmButton.enabled = YES;
    _confirmButton.userInteractionEnabled = YES;
}
@end
