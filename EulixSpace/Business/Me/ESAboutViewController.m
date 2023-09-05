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
//  ESAboutViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAboutViewController.h"
#import "ESAgreementWebVC.h"
#import "ESBoxManager.h"
#import "ESFormItem.h"
#import "ESMemberManager.h"
#import "ESFormView.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESVersionInfoView.h"
#import "ESVersionManager.h"
#import <Masonry/Masonry.h>
#import "ESSettingItemView.h"
#import "ESUpgradeVC.h"
#import "ESMemberManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "UIImage+ESTool.h"
#import "ESCommonToolManager.h"

#import "ESSpaceGatewayVersionCheckingServiceApi.h"

typedef NS_ENUM(NSUInteger, ESAboutViewType) {
 
    ESSettingCellTypeiOSV,
    ESSettingCellTypeSystemV,
    ESSettingCellTypeUser,
    ESSettingCellTypeConceal,
};

@interface ESAboutViewController ()

@property (nonatomic, strong) UIImageView *logo;

@property (nonatomic, strong) ESFormView *version;

@property (nonatomic, strong) ESFormView *conceal;

@property (nonatomic, strong) ESFormView *userAgreement;

@property (nonatomic, strong) ESVersionInfoView *versionInfo;

@property (nonatomic, strong) ESPackageCheckRes *info;


@property (nonatomic, strong) ESSettingItemView *versionView;

@property (nonatomic, strong) ESSettingItemView *agreementView;

@property (nonatomic, strong) NSString *appVersion;

@property (nonatomic, copy) NSString *pkgSize;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *packName;

@property (nonatomic, copy) NSString *pckVersion;

@property (nonatomic, copy) NSString *pckVersion1;

@property (nonatomic, assign) BOOL isVarNewVersionExist;

@property(nonatomic,assign) BOOL isHaveRedView;

@property (nonatomic, strong) UIImageView * openLogoIv;

@end

@implementation ESAboutViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hideNavigationBar = NO;

    [self checkVersionServiceApi];
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    [clientResultApi spaceV1ApiGatewayVersionBoxCurrentGetWithCompletionHandler:^(ESResponseBaseString1 *output, NSError *error) {
        self.pckVersion = output.results;
        
        [self reloadSetting];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_ME_ABOUT_US;
    self.view.backgroundColor = ESColor.newsListBg;
    self.navigationBarBackgroundColor = ESColor.newsListBg;
    self.isVarNewVersionExist = NO;
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).inset(60);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(135);
        make.width.mas_equalTo(90);
    }];

    [self.openLogoIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logo.mas_bottom).offset(6);
        make.centerX.mas_equalTo(self.view);
    }];
    
   [self.versionView mas_updateConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.openLogoIv.mas_bottom).offset(50.0f);
       make.left.equalTo(self.view.mas_left).offset(0.0f);
       make.right.equalTo(self.view.mas_right).offset(0.0f);
       make.height.equalTo(@(124.0f));
   }];

   [self.agreementView mas_updateConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.versionView.mas_bottom).offset(10.0f);
       make.left.equalTo(self.view.mas_left).offset(0.0f);
       make.right.equalTo(self.view.mas_right).offset(0.0f);
       make.height.equalTo(@(124.0f));
   }];
       
    [self loadData];
    [self reloadSetting];
    [self reloadAgreement];
//
    self.isHaveRedView = NO;
 
    [ESVersionManager checkAppVersion:^(ESPackageCheckRes *info) {
        if (info.varNewVersionExist.boolValue ) {
            self.isHaveRedView = YES;
            [self reloadSetting];
        }
    }];
 
    
}

- (void)loadData {
    [ESVersionManager checkAppVersion:^(ESPackageCheckRes *info) {
        if (info.varNewVersionExist.boolValue) {
            self.info = info;
        } else {
            self.info = nil;
        }
        [self showCurrentView:info.varNewVersionExist.boolValue];
    }];
}

- (void)checkVersion {
    //更新APP版本    mine.click.update
    if (!self.info) {
        [ESToast toastSuccess:NSLocalizedString(@"already_the_latest_version", @"已经是最新版本")];
        return;
    }
    [self showVersionInfo:self.info];
}

- (void)concealAction {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESConcealtAgreement;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userAgreementAction {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESUserAgreement;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCurrentView:(BOOL)dot {
    ESFormItem *item = [ESFormItem new];
    item.title = TEXT_ME_FOUND_NEW_VERSION;
    item.content = [NSString stringWithFormat:NSLocalizedString(@"common_version", @"V%@"), NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];

    item.hideLine = NO;
    item.dot = dot;
    [self.version reloadWithData:item];

    ESFormItem *itemConceal = [ESFormItem new];
    itemConceal.title = NSLocalizedString(@"Privacy Policy", @"隐私协议");
    itemConceal.hideLine = NO;
    [self.conceal reloadWithData:itemConceal];

    ESFormItem *itemUserAgreement = [ESFormItem new];
    itemUserAgreement.title = NSLocalizedString(@"User Agreement", @"用户协议");
    itemUserAgreement.hideLine = YES;
    [self.userAgreement reloadWithData:itemUserAgreement];
}

- (void)showVersionInfo:(ESPackageCheckRes *)info {
    self.versionInfo.hidden = NO;
    ESFormItem *item = [ESFormItem new];
    item.title = TEXT_ME_UPGRADE;
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:TEXT_ME_LATEST_VERSION, info.latestAppPkg.pkgVersion];
    [content appendString:@"\n"];
    [content appendFormat:TEXT_ME_VERSION_DESC, info.latestAppPkg.updateDesc];
    item.content = content;
    [self.versionInfo reloadWithData:item];
    weakfy(self);
    self.versionInfo.actionBlock = ^(id action) {
        strongfy(self);
        self.versionInfo.hidden = YES;
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:info.latestAppPkg.downloadUrl] options:@{} completionHandler:nil];
    };
}

#pragma mark - Lazy Load

- (UIImageView *)logo {
    if (!_logo) {
        _logo = [UIImageView new];
        [self.view addSubview:_logo];
        if ([ESCommonToolManager isEnglish]) {
            _logo.image = [UIImage imageNamed:@"logo_en"];
        }else{
            _logo.image = IMAGE_ME_LOGO;
        }

    }
    return _logo;
}


- (ESVersionInfoView *)versionInfo {
    if (!_versionInfo) {
        _versionInfo = [[ESVersionInfoView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:_versionInfo];
    }
    return _versionInfo;
}


- (ESSettingItemView *)versionView {
    if (!_versionView) {
        _versionView = [ESSettingItemView new];
        [self.view addSubview:_versionView];
        weakfy(self);
        _versionView.actionBlock = ^(ESFormItem *item, NSNumber *action) {
            strongfy(self);
            [self onSetting:item action:action.integerValue];
        };
    }
    return _versionView;
}

- (ESSettingItemView *)agreementView {
    if (!_agreementView) {
        _agreementView = [ESSettingItemView new];
        [self.view addSubview:_agreementView];
        weakfy(self);
        _agreementView.actionBlock = ^(ESFormItem *item, NSNumber *action) {
            strongfy(self);
            [self onSetting:item action:action.integerValue];
        };
    }
    return _agreementView;
}

- (void)onSetting:(ESFormItem *)item action:(ESAboutViewType)action {
    switch (item.row) {
        case ESSettingCellTypeiOSV:{
            [self checkVersion];
        }
            break;
        case ESSettingCellTypeSystemV: {
            if(![self needShowUpgrade]) {
                return;
            }
            if(![ESMemberManager isAdminAndPair]){
                return;
            }

            ESUpgradeVC *vc = [ESUpgradeVC new];
            
            ESSapceUpgradeInfoModel *upgradeInfo = [ESSapceUpgradeInfoModel new];
            upgradeInfo.appVersion = self.appVersion;
            upgradeInfo.pkgSize = self.pkgSize;
            upgradeInfo.packName = self.packName;
            upgradeInfo.pckVersion = self.pckVersion1;
            upgradeInfo.isVarNewVersionExist = self.isVarNewVersionExist;
            upgradeInfo.desc = self.desc;
            [self checkVersionServiceApi];
            upgradeInfo.isVarNewVersionExist = self.isVarNewVersionExist;
            [vc loadWithUpgradeInfo:upgradeInfo];
            
            [self.navigationController pushViewController:vc animated:YES];
        } break;

        case ESSettingCellTypeUser: {
            [self userAgreementAction];
            
        } break;

        case ESSettingCellTypeConceal: {
            [self concealAction];

        } break;
        default:
            break;
    }
}


- (void)reloadSetting {
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
    //设置
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeiOSV;
        item.title = NSLocalizedString(@"iOS Client Version", @"iOS 客户端版本");
        item.arrowRight = 16;
        item.content = [NSString stringWithFormat:NSLocalizedString(@"common_version", @"V%@"), NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
        if(self.isHaveRedView){
            item.dot = YES;
        }else{
            item.dot = NO;
        }
        [data addObject:item];
    }
 
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeSystemV;
        item.title = NSLocalizedString(@"System Version", @"系统版本");
    
        if(self.isVarNewVersionExist  && [ESMemberManager isAdminAndPair]){
            item.dot = YES;
        }else{
            item.dot = NO;
        }

        item.content = self.pckVersion;
        item.arrowRight = 16;
        if (![self needShowUpgrade]) {
            item.arrowHeight = 0;
            item.dot = NO;
        }
        
        if(![ESMemberManager isAdminAndPair]){
            item.isHiddenArrowBtn = YES;
        }

        [data addObject:item];
    }

    data.lastObject.hideLine = YES;
    [self.versionView reloadWithData:data];
}

- (BOOL)needShowUpgrade {
    return  ![ESBoxManager.activeBox.deviceAbilityModel isTrialBox] ||
    ([ESBoxManager.activeBox.deviceAbilityModel isTrialBox] && ESBoxManager.activeBox.deviceAbilityModel.upgradeApiSupport);
}

- (void)reloadAgreement{
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
    //设置
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeConceal;
        item.title = NSLocalizedString(@"Privacy Policy", @"隐私协议");
        item.arrowRight = 16;
        [data addObject:item];
    }
 
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeUser;
        item.title = NSLocalizedString(@"User Agreement", @"用户协议");
        item.arrowRight = 16;
        [data addObject:item];
    }

    data.lastObject.hideLine = YES;
    [self.agreementView reloadWithData:data];
}


- (void)checkVersionServiceApi {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    self.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    __weak typeof(self) weakSelf = self;
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:self.appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                                 __strong typeof(weakSelf) self = weakSelf;
                                                 if (!error) {
                                                     ESDLog(@"[ESDeviceManagerViewController] appVersion: %@ \n checkVersionServiceApi: %@",self.appVersion, output);
                                        
                                                     BOOL isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     ESPackageRes *res = output.results.latestBoxPkg;
                                                     self.packName = res.pkgName;
                                                     self.pckVersion1 = res.pkgVersion;
                                                     self.isVarNewVersionExist = isVarNewVersionExist;
                                                     self.desc = res.updateDesc;
                                                     self.pkgSize = res.pkgSize.stringValue;
                                                     if (isVarNewVersionExist == NO) {
                                                         [clientResultApi spaceV1ApiGatewayVersionBoxCurrentGetWithCompletionHandler:^(ESResponseBaseString1 *output, NSError *error) {
                                                             self.pckVersion = output.results;
                                                             [self reloadSetting];
                                                         }];
                                                     }else{
                                                         [self reloadSetting];
                                                     }
                                                 } else {
//                                                      [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                                 }
                                             }];
}

- (UIImageView *)openLogoIv {
    if (!_openLogoIv) {
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage es_imageNamed:@"about_open"]];
        [self.view addSubview:iv];
        _openLogoIv = iv;
    }
    return _openLogoIv;
}



@end
