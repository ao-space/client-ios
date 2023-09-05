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
//  ESSpaceSystemInfoVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSpaceSystemInfoVC.h"
#import "ESSpaceSystemInfoModule.h"
#import "ESGradientButton.h"
#import "ESDeviceInfoModel.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import "ESAccountInfoStorage.h"
#import "ESSapceUpgradeInfoModel.h"
#import "ESFileDefine.h"
#import "ESUpgradeVC.h"
#import "ESToast.h"
#import "ESDeviceInfoServiceModule.h"
#import "ESCache.h"
#import "ESBoxManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@interface ESSpaceSystemInfoVC ()

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) ESSpaceSystemInfoModule *listModule;
@property (nonatomic, strong) ESGradientButton *checkUpdateBt;
@property (nonatomic, strong) ESDeviceInfoModel *deviceInfo;

@property (nonatomic, strong) ESSapceUpgradeInfoModel *upgradeInfo;

@end

@implementation ESSpaceSystemInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"System Specifications", @"系统规格");
    [self setupViews];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.listModule.listView = self.listView;
    
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = YES;
}

- (void)fetchDeviceInfo:(BOOL)showLoading {
    __weak typeof(self) weakSelf = self;
    if (showLoading) {
        ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(60).showFrom(self.view);
    }
    [ESDeviceInfoServiceModule getDeviceInfoWithCompletion:^(ESDeviceInfoResultModel * _Nullable deviceInfoResult, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [ESToast dismiss];
        if (!error && deviceInfoResult) {
            self.deviceInfo = [ESDeviceInfoModel new];
            [self.deviceInfo updateWithDeviceInfoResultModel:deviceInfoResult];
            [[ESCache defaultCache] setObject:self.deviceInfo forKey:ESBoxManager.activeBox.boxUUID];
            
            if(self.viewLoaded && self.view.window) {
                [self.listModule reloadDeviceInfo:self.deviceInfo];
            }
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

- (void)tryLoadCacheDeviceInfo {
    ESDeviceInfoModel *deviceInfoModel = [[ESCache defaultCache] objectForKey:ESBoxManager.activeBox.boxUUID];
    if (deviceInfoModel) {
        self.deviceInfo = deviceInfoModel;
        [self.listModule reloadDeviceInfo:deviceInfoModel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.deviceInfo && self.deviceInfo.systemInfo.serviceItems.count > 0) {
        [self.listModule reloadDeviceInfo:self.deviceInfo];
        [self fetchDeviceInfo:NO];
        return;
    }
    
    [self tryLoadCacheDeviceInfo];
    if (self.deviceInfo.systemInfo.serviceItems.count <= 0) {
        [self fetchDeviceInfo:YES];
        return;
    }
    
    [self fetchDeviceInfo:NO];
}

- (void)reloadDataWithDeviceInfo:(ESDeviceInfoModel *)deviceInfo {
    _deviceInfo = deviceInfo;
    
    if (self.viewLoaded && self.view.window) {
        [self.listModule reloadDeviceInfo:self.deviceInfo];
    }
}

- (void)setupViews {
    [self.view addSubview:self.listView];
   
//    if ([self isAdim] && ![ESBoxManager.activeBox.deviceAbilityModel isTrialBox]) {
    if ([self isAdim]) {
        [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-106.0f);
        }];
        
        [self.view addSubview:self.checkUpdateBt];
        [self.checkUpdateBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.listView.mas_bottom).inset(10.0f);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(200.0f, 44.0f));
        }];

        return;
    }
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view);
    }];
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
    
        _listView.estimatedSectionHeaderHeight = 0;
        _listView.estimatedSectionFooterHeight = 0;
      
        _listView.tableFooterView = [UIView new];
        if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_listView setSeparatorInset:UIEdgeInsetsMake(0, 26, 0, 26)];
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

- (ESSpaceSystemInfoModule *)listModule {
    if (!_listModule) {
        _listModule = [[ESSpaceSystemInfoModule alloc] init];
    }
    return _listModule;
}

- (ESGradientButton *)checkUpdateBt {
    if (!_checkUpdateBt) {
        _checkUpdateBt = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_checkUpdateBt setCornerRadius:10];
        [_checkUpdateBt setTitle:NSLocalizedString(@"me_version_update", @"检查更新") forState:UIControlStateNormal];
        _checkUpdateBt.titleLabel.font = ESFontPingFangMedium(16);
        [_checkUpdateBt setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_checkUpdateBt addTarget:self action:@selector(updateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkUpdateBt;
}

- (void)updateAction:(id)sender {
       [self.checkUpdateBt startLoading:NSLocalizedString(@"Checking", @"正在检查")];
       [self.checkUpdateBt setUserInteractionEnabled:NO];
       [self checkVersionServiceApi];
}

- (BOOL)isAdim {
    return [ESAccountInfoStorage isAdminAccount];
}

- (void)checkVersionServiceApi {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                                [self resetCheckUpgradeInfoButtonStatus];
                                                 if (!error) {
                                                     if ([output.code isEqualToString:@"GW-5006"]) {
                                                         [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
                                                         return;
                                                     }
                                                     ESPackageRes *res = output.results.latestBoxPkg;
                                                     
                                                     ESSapceUpgradeInfoModel *upgradeInfo = [ESSapceUpgradeInfoModel new];
                                                     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                     upgradeInfo.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                                                     upgradeInfo.pkgSize = FileSizeString(res.pkgSize.floatValue, YES);
                                                     upgradeInfo.packName = res.pkgName;
                                                     upgradeInfo.pckVersion = res.pkgVersion;
                                                     upgradeInfo.isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     upgradeInfo.desc = res.updateDesc;
                                                     self.upgradeInfo = upgradeInfo;
                                        
                                                     BOOL isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     if (isVarNewVersionExist) {
                                                         [self showUpgradePage];
                                                         return;
                                                     }
//                                                     [ESToast toastInfo:@"已是最新版本"];
                                                     [ESToast toastInfo:NSLocalizedString(@"already_the_latest_version", @"已经是最新版本")];
                                                     return;
                                                 }else{
                                                   
                                                          [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                       
                                                 }
                                                  
                                             }];
}


- (void)resetCheckUpgradeInfoButtonStatus {
    [self.checkUpdateBt stopLoading:NSLocalizedString(@"me_found_new_version", @"检查更新")];
    [self.checkUpdateBt setUserInteractionEnabled:YES];
}

- (void)showUpgradePage {
    ESUpgradeVC *vc = [ESUpgradeVC new];
    [vc loadWithUpgradeInfo:self.upgradeInfo];
    [self.navigationController pushViewController:vc animated:YES];
}

@end



