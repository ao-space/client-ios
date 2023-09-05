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
//  ESUpgradeVC.m
//  EulixSpace
//
//  Created by qu on 2021/10/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUpgradeVC.h"
#import "ESAutoUpdateOnOffVC.h"
#import "ESBoxUpdateDescLabel.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import "ESUpgradeApi.h"
#import <Masonry/Masonry.h>
#import "ESSpaceSystemInfoVC.h"
#import "UIButton+ESTouchArea.h"
#import "ESFileDefine.h"
#import "ESCommonToolManager.h"
#import "ESCache.h"
#import "ESHomeCoordinator.h"

@interface ESUpgradeVC ()


/// upgradeType == ESBoxUpgradeTypeForcexUpgrade 时
/// 1. 隐藏返回按钮
/// 2. 隐藏自动升级的开关
/// 3. 进到页面自动开始升级流程
/// 4. 升级完成, 退出APP
///

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *boxTitleLabel;
@property (strong, nonatomic) UILabel *boxSizeLabel;
@property (strong, nonatomic) UILabel *boolLabel;

@property (strong, nonatomic) ESGradientButton *downBtn;
@property (strong, nonatomic) UILabel *downBtnTitle;

@property (strong, nonatomic) UIButton *systemDetailInfoBt;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSNumber *autoDownload;
@property (nonatomic, strong) NSNumber *autoInstall;

@property (nonatomic, strong) UILabel *outPointLabel;
@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, strong) ESSapceUpgradeInfoModel *upgradeInfo;
@property (nonatomic, assign) BOOL needAutoInstall;

@property (nonatomic, strong) UIView *maskView;


@end

@implementation ESUpgradeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!(self.upgradeType == ESBoxUpgradeTypeForcexUpgrade)) {
        [self getUpgrade];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_needAutoInstall) {
        [self  autoInstallSpaceSystem];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_ME_SYSTEM_UPDATE;
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    if (self.upgradeInfo != nil) {
        [self setupViews];
        [self checkVersionServiceApi:YES];
        return;
    }
    self.isHaveInstall = NO;
    [self checkVersionServiceApi:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self timerStop];
}

- (void)checkVersionServiceApi:(BOOL)justShowToast {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                                 if (!error) {
                                                     ESDLog(@"[ESUpgradeVC] checkVersionServiceApi: %@", output);
                                                     if ([output.code isEqualToString:@"GW-5006"]) {
                                                         [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
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
                                                     upgradeInfo.needRestart = [self needRestartIfUpdate:output];
                                                     self.upgradeInfo = upgradeInfo;
                                                     
                                                     if (justShowToast) {
                                                         return;
                                                     }
                                                    
                                                     [self setupViews];
                                                     return;
                                                 }
                                                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                             }];
}

- (BOOL)needRestartIfUpdate:(ESResponseBasePackageCheckRes *)output {
    if (output.results.latestAppPkg.restart != nil && [output.results.latestAppPkg.restart boolValue] == YES) {
        return YES;
    }
    
    if (output.results.latestBoxPkg.restart != nil && [output.results.latestBoxPkg.restart boolValue] == YES) {
        return YES;
    }
    return NO;
}

- (void)setupViews {
    if (self.upgradeType == ESBoxUpgradeTypeForcexUpgrade) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }

    if (self.upgradeType == ESBoxUpgradeTypeForcexUpgrade) {
        [self updateUI];
    } else {
        [self initUI];
        // self.boxSizeLabel.text = FileSizeString(res.pkgSize.floatValue, YES);
    }

    if (self.isVarNewVersionExist) {
    
        self.downBtn.hidden = NO;
        self.systemDetailInfoBt.hidden = YES;

        self.boxSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"update_size_p", @"更新大小：%@"), self.pkgSize];
        [self getUpgradeStatus];
        if (self.pckVersion.length > 0) {
            self.boxTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ao_space_p", @"傲空间：%@"), self.upgradeInfo.pckVersion];
        } else {
            self.boxTitleLabel.text = NSLocalizedString(@"device_base_info_box_name_default", @"傲空间");
        }
    } else {
        self.downBtn.hidden = YES;
        self.systemDetailInfoBt.hidden = NO;
        self.boxSizeLabel.text = NSLocalizedString(@"me_latest_version_prompt", @"已是最新版本");
        NSString *name =  NSLocalizedString(@"device_base_info_box_name_default", @"傲空间");
        if (self.pckVersion.length > 0) {
            self.boxTitleLabel.text = [NSString stringWithFormat:@"%@ %@",name, self.pckVersion];
        } else {
            ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
            [clientResultApi spaceV1ApiGatewayVersionBoxCurrentGetWithCompletionHandler:^(ESResponseBaseString1 *output, NSError *error) {
                self.boxTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ao_space_p", @"傲空间：%@"), output.results];
            }];

        }
    }
    self.isUpdate = NO;
}

- (void)loadWithUpgradeInfo:(ESSapceUpgradeInfoModel *)info {
    _upgradeInfo = info;
}

- (void)updateUI {
    UILabel *newTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:newTitleLabel];
    newTitleLabel.text = NSLocalizedString(@"new_version", @"新版本");
    newTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    newTitleLabel.textColor = [ESColor disableTextColor];

    [newTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(self.view.mas_top).offset(40.0);
        make.height.equalTo(@(20.0f));
    }];

    UIImageView *boxImageView = [[UIImageView alloc] init];
    boxImageView.image = IMAGE_BOX_LOGO;
    [self.view addSubview:boxImageView];
    [boxImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(newTitleLabel.mas_bottom).offset(22.0);
        make.height.width.equalTo(@(40.0f));
    }];

    UILabel *boxTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:boxTitleLabel];
    self.boxTitleLabel = boxTitleLabel;
    boxTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    boxTitleLabel.textColor = [ESColor labelColor];
    boxTitleLabel.textAlignment = NSTextAlignmentLeft;

    UILabel *boxSizeLabel = [[UILabel alloc] init];
    [self.view addSubview:boxSizeLabel];
    self.boxSizeLabel = boxSizeLabel;
    boxSizeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    boxSizeLabel.textColor = [ESColor disableTextColor];
    boxSizeLabel.textAlignment = NSTextAlignmentLeft;

    [self.view addSubview:self.systemDetailInfoBt];
    [self.systemDetailInfoBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(boxImageView.mas_centerY);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        make.height.equalTo(@(22.0f));
    }];
    
    [self.view addSubview:self.downBtn];
    [self.downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(86.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        make.height.equalTo(@(36.0f));
    }];


    [boxTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(boxImageView.mas_right).offset(10.0);
        make.right.mas_equalTo(self.downBtn.mas_left).offset(-20.0);
        make.top.mas_equalTo(self.view.mas_top).offset(82.0);
        make.height.equalTo(@(22.0f));
    }];

    [boxSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(boxImageView.mas_right).offset(10.0);
        make.right.mas_equalTo(self.downBtn.mas_left).offset(-20.0);
        make.top.mas_equalTo(boxTitleLabel.mas_bottom).offset(4.0);
        make.height.equalTo(@(14.0f));
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ESColor.separatorColor;
    [self.view addSubview:lineView];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-20.0);
        make.top.mas_equalTo(boxSizeLabel.mas_bottom).offset(43.0);
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.height.equalTo(@(1.0f));
    }];

    ESBoxUpdateDescLabel *pointOutLabel = [[ESBoxUpdateDescLabel alloc] init];
    [self.view addSubview:pointOutLabel];
    self.pointOutLabel = pointOutLabel;
    pointOutLabel.text = self.desc;
    pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

    pointOutLabel.numberOfLines = 0; //表示label可以多行显示
    pointOutLabel.textColor = [ESColor labelColor];
    pointOutLabel.textAlignment = NSTextAlignmentLeft;
    [pointOutLabel setVerticalAlignment:VerticalAlignmentTop];
    [pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(19.0);
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.bottom.equalTo(self.view.mas_bottom).offset(60.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
    }];
    UILabel *outPointLabel = [[UILabel alloc] init];
    [self.view addSubview:outPointLabel];
    outPointLabel.text = NSLocalizedString(@"upgrading_notice", @"温馨提示：系统正在升级，请勿切断设备电源");
    outPointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    outPointLabel.textColor = [ESColor primaryColor];
    outPointLabel.hidden = YES;
    outPointLabel.numberOfLines = 0; //表示label可以多行显示
    [outPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(boxImageView.mas_bottom).offset(10.0);
        make.width.equalTo(@(200.0f));
    }];
    self.outPointLabel = outPointLabel;
}

- (void)initUI {
    UIView *cellView = [self cellViewWithTitle:NSLocalizedString(@"Automatic_Upgrade", @"自动升级") titleText:@""];
    [self.view addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(0.0);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.top.mas_equalTo(self.view.mas_top).offset(30.0);
        make.height.equalTo(@(65.0f));
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoUpdateView)];
    [cellView addGestureRecognizer:tap];

    UIView *gradView = [[UIView alloc] init];
    gradView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    [self.view addSubview:gradView];
    [gradView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(0.0);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.top.mas_equalTo(cellView.mas_bottom).offset(0.0);
        make.height.equalTo(@(10.0f));
    }];

    UILabel *newTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:newTitleLabel];
    newTitleLabel.text = NSLocalizedString(@"new_version", @"新版本");
    newTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    newTitleLabel.textColor = [ESColor disableTextColor];
    [newTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(gradView.mas_bottom).offset(20.0);
        make.height.equalTo(@(20.0f));
    }];

    UIImageView *boxImageView = [[UIImageView alloc] init];
    boxImageView.image = IMAGE_APP_LOGO;
    [self.view addSubview:boxImageView];
    [boxImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(newTitleLabel.mas_bottom).offset(22.0);
        make.height.width.equalTo(@(40.0f));
    }];

    UILabel *outPointLabel = [[UILabel alloc] init];
    [self.view addSubview:outPointLabel];
    outPointLabel.text = NSLocalizedString(@"upgrading_notice", @"温馨提示：系统正在升级，请勿切断设备电源");
    outPointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    outPointLabel.textColor = [ESColor primaryColor];
    outPointLabel.hidden = YES;
    outPointLabel.numberOfLines = 0; //表示label可以多行显示
    [outPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(boxImageView.mas_bottom).offset(10.0);
        make.height.equalTo(@(28.0f));
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
    }];
    self.outPointLabel = outPointLabel;

    UILabel *boxTitleLabel = [[UILabel alloc] init];
    [self.view addSubview:boxTitleLabel];
    self.boxTitleLabel = boxTitleLabel;
    boxTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    boxTitleLabel.textColor = [ESColor labelColor];
    boxTitleLabel.textAlignment = NSTextAlignmentLeft;

    UILabel *boxSizeLabel = [[UILabel alloc] init];
    [self.view addSubview:boxSizeLabel];
    boxSizeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    boxSizeLabel.textColor = [ESColor disableTextColor];
    boxSizeLabel.textAlignment = NSTextAlignmentLeft;
    self.boxSizeLabel = boxSizeLabel;
    
    [self.view addSubview:self.systemDetailInfoBt];
    [self.systemDetailInfoBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(boxImageView.mas_centerY);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        make.height.equalTo(@(22.0f));
    }];
    
    [self.view addSubview:self.downBtn];
    [self.downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(gradView.mas_bottom).offset(66.0);
        make.right.mas_equalTo(cellView.mas_right).offset(-26.0);
        make.height.equalTo(@(36.0f));
        make.width.equalTo(@(110.0f));
    }];

    [boxTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(boxImageView.mas_right).offset(10.0);
        make.right.mas_equalTo(self.downBtn.mas_left).offset(-20.0);
        make.top.mas_equalTo(gradView.mas_bottom).offset(62.0);
        make.height.equalTo(@(22.0f));
    }];

    [boxSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(boxImageView.mas_right).offset(10.0);
        make.right.mas_equalTo(self.downBtn.mas_left).offset(-20.0);
        make.top.mas_equalTo(gradView.mas_bottom).offset(88.0);
        make.height.equalTo(@(14.0f));
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ESColor.separatorColor;
    [self.view addSubview:lineView];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-20.0);
        make.top.mas_equalTo(gradView.mas_bottom).offset(145.0);
        make.left.mas_equalTo(cellView.mas_left).offset(26.0);
        make.height.equalTo(@(1.0f));
    }];

    ESBoxUpdateDescLabel *pointOutLabel = [[ESBoxUpdateDescLabel alloc] init];
    [self.view addSubview:pointOutLabel];
    self.pointOutLabel = pointOutLabel;
    pointOutLabel.text = self.desc;
    pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    pointOutLabel.numberOfLines = 0; //表示label可以多行显示
    pointOutLabel.textColor = [ESColor labelColor];
    pointOutLabel.textAlignment = NSTextAlignmentLeft;
    [pointOutLabel setVerticalAlignment:VerticalAlignmentTop];
    [pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(19.0);
        make.left.mas_equalTo(cellView.mas_left).offset(26.0);
        make.right.mas_equalTo(cellView.mas_right).offset(-26.0);
        make.bottom.equalTo(self.view.mas_bottom).offset(60.0);

    }];
}

- (UIView *)cellViewWithTitle:(NSString *)title titleText:(NSString *)titleText {
    UIView *cellView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    titleLabel.textColor = [ESColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = title;
    [cellView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellView.mas_left).offset(16.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-20.0);
        make.height.equalTo(@(25.0f));
    }];

    UILabel *titleTextLabel = [[UILabel alloc] init];
    titleTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    titleTextLabel.textColor = [ESColor primaryColor];
    titleTextLabel.textAlignment = NSTextAlignmentRight;
    titleTextLabel.text = titleText;
    [cellView addSubview:titleTextLabel];
    self.downBtnTitle = titleTextLabel;
    [titleTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-52.0);
        make.left.mas_equalTo(titleLabel.mas_right).offset(20.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-20.0);
        make.height.equalTo(@(22.0f));
    }];
    [cellView addSubview:titleTextLabel];

    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = IMAGE_FILE_COPYBACK;
    [cellView addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-29.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-24.0);
        make.height.equalTo(@(16.0f));
        make.width.equalTo(@(16.0f));
    }];

    if ([title isEqual:NSLocalizedString(@"Automatic_Upgrade", @"自动升级")]) {
        self.boolLabel = titleTextLabel;
        NSString * text = [ESCache.defaultCache objectForKey:@"ESUpgradeVCAutoKey"];
        self.boolLabel.text = text;
    }
    return cellView;
}

- (void)getUpgrade {
    ESDLog(@"[ESUpgradeVC] getUpgrade");

    ESUpgradeApi *api = [ESUpgradeApi new];
    [api agentV1ApiUpgradeConfigGetWithCompletionHandler:^(ESUpgradeConfig *output, NSError *error) {
        if (!error) {
            self.autoDownload = output.autoDownload;
            self.autoInstall = output.autoInstall;
            if (!output.autoDownload.boolValue && !output.autoInstall.boolValue) {
                self.boolLabel.text = NSLocalizedString(@"common_close", @"关闭");
            } else {
                self.boolLabel.text = NSLocalizedString(@"upgrade_open", @"开启");
            }
            
            [ESCache.defaultCache setObject:self.boolLabel.text forKey:@"ESUpgradeVCAutoKey"];
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

- (void)installAndUpdateAction {
    ESDLog(@"[ESUpgradeVC] installAndUpdateAction");

    [ESCommonToolManager isBackupInComple];
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"backupInProgress"];
    if([str isEqual:@"YES"]){
        [ESToast toastSuccess:NSLocalizedString(@"Executing backup task", @"正在执行备份任务，暂不支持此操作")];
        return;
    }
    NSString *reStoreInProgress = [[NSUserDefaults standardUserDefaults] objectForKey:@"reStoreInProgress"];
    if([reStoreInProgress isEqual:@"YES"]){
        [ESToast toastSuccess:NSLocalizedString(@"Performing recovery task, this operation is not currently supported", @"正在执行恢复任务，暂不支持此操作")];
        return;
    }
    if ([self.status isEqual:@"downloaded"]) {
        [self installAction];
        return;
    }
    
    [self updateAction];
    return;
}

- (void)updateAction {
    ESDLog(@"[ESUpgradeVC] updateAction");

    self.isHaveInstall = NO;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"system_dialog_install_title",  @"系统升级")
                                                                             message:NSLocalizedString(@"system_update_alert", @"系统升级大约需要5分钟，在此期间设备将无法访问，是否继续？") preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){

                                                   }];
    NSString *actionTitle = self.upgradeInfo.needRestart ? NSLocalizedString(@"me_kernelupdate", @"升级并重启"):
                             NSLocalizedString(@"applet_update_dialog_update_bt_title", @"立即更新");
    
    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:actionTitle
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       if ([self.status isEqual:@"downloaded"]) {
                                                           [self installVersion];
                                                       } else {
                                                           [self downVersion];
                                                       }
                                                       self.downBtn.hidden = NO;
                                                       [self.downBtn startLoading:NSLocalizedString(@"state_downloading", @"正在下载")];
                                                       [self.downBtn userEnable:NO];
                                                       [self.downBtn setUserInteractionEnabled:NO];
                                                       self.outPointLabel.hidden = NO;
        
                                                        __weak typeof(self) weakSelf = self;
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           __strong typeof(weakSelf) self = weakSelf;
                                                           [self creatTimer];
                                                       });
                                                   }];

    [alertController addAction:cancel];
    [alertController addAction:turnOn];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)installAction {
    ESDLog(@"[ESUpgradeVC] installAction");

    self.isHaveInstall = NO;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"system_dialog_install_title",  @"系统升级")
                                                                             message:NSLocalizedString(@"system_dialog_install_message", @"系统升级大约需要5分钟，在此期间 设备将无法访问，是否继续？")
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){

                                                   }];

    
    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:NSLocalizedString(@"applet_update_dialog_update_bt_title", @"立即安装")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       if ([self.status isEqual:@"downloaded"]) {
                                                           [self installVersion];
                                                       }
                                                       self.downBtn.hidden = NO;
                                                       [self.downBtn startLoading:NSLocalizedString(@"state_installing", @"正在安装")];
                                                       [self.downBtn userEnable:NO];
        
                                                       [self.downBtn setUserInteractionEnabled:NO];
                                                       self.outPointLabel.hidden = NO;
                                                       __weak typeof(self) weakSelf = self;
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           __strong typeof(weakSelf) self = weakSelf;
                                                           [self creatTimer];
                                                       });
                                                   }];

    [alertController addAction:cancel];
    [alertController addAction:turnOn];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)downVersion {
    ESUpgradeApi *api = [ESUpgradeApi new];
    ESStartDownRes *res = [ESStartDownRes new];
    res.versionId = self.pckVersion;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.pckVersion];
    [api upgradeV1ApiStartDownPostWithDown:res
                         completionHandler:^(ESTask *output, NSError *error){
                         }];
}

- (void)installVersion {
    if(self.isHaveInstall){
        return;
    }
    
    ESDLog(@"[ESUpgradeVC] installVersion");

    self.isHaveInstall = YES;
    ESUpgradeApi *api = [ESUpgradeApi new];
    ESStartUpgradeRes *res = [ESStartUpgradeRes new];
    res.versionId = self.pckVersion;

    [self showLoadingViewWithTitle:NSLocalizedString(@"backup_install", @"正在安装系统更新")];
    [api upgradeV1ApiStartUpgradePostWithUpgrade:res
                               completionHandler:^(ESTask *output, NSError *error) {
                                   if (!error) {
           [self getStatus];
        }
    }];
}

- (void)showRestartBoxProcessing {
    ESDLog(@"[ESUpgradeVC] showRestartBoxProcessing");
    [self hiddenLoadingView];
    [self showLoadingViewWithTitle:NSLocalizedString(@"me_restarting", @"正在重启设备")];
}

- (void)showUpdateSuccessAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UpgradeCompleted", @"升级完成")
                                                                   message:NSLocalizedString(@"me_updated_prompt", @"系统升级已完成，请您在退出应用后重新打开并使用")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:TEXT_COMMON_GOT_IT
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *_Nonnull action){
        exit(0);
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)getUpgradeStatus {
    ESUpgradeApi *api = [ESUpgradeApi new];
    
    [api upgradeV1ApiStatusGetWithCompletionHandler:^(ESTask *output, NSError *error) {
        self.status = output.status;
        [self updateViewStatus:output];
    }];
}


- (void)getStatus {
    ESUpgradeApi *api = [ESUpgradeApi new];
    [api upgradeV1ApiStatusGetWithCompletionHandler:^(ESTask *output, NSError *error) {
        ESDLog(@"[ESUpgradeVC] getStatus: %@", output);

        self.status = output.status;
        [self updateViewStatus:output];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpgradeStatus"];
        if ([output.status isEqual:@"installed"]) {
            if (output.versionId == self.pckVersion) {
                self.downBtn.hidden = YES;
                self.outPointLabel.hidden = YES;
                self.pointOutLabel.hidden = YES;
                self.boxSizeLabel.text = NSLocalizedString(@"me_latest_version_prompt", @"已是最新版本");
                self.systemDetailInfoBt.hidden = NO;
                [self hiddenLoadingView];
                if (self.isUpdate) {
                    self.needAutoInstall = NO;
                    [self timerStop];
                    if(self.upgradeType == ESBoxUpgradeTypeForcexUpgrade) {
                        [self showUpdateSuccessAlert];
                    } else {
                        if (output.versionId.length > 0) {
                            self.boxTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ao_space_p", @"傲空间：%@"), output.versionId];
                        }
                        [ESToast toastSuccess:NSLocalizedString(@"update_success", @"升级成功")];
                    }
                }
            }
        } else if ([output.status isEqual:@"downloading"] || [output.status isEqual:@"installing"]) {
            self.isUpdate = YES;
            [self creatTimer];
        } else if ([output.status isEqual:@"downloaded"]) {
            [self installVersion];
            self.isUpdate = YES;
            [self creatTimer];
        } else if ([output.status isEqual:@"download-err"]) {
            [ESToast toastError:NSLocalizedString(@"update_failed", @"升级失败")];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUpgradeStatus"];
            [self timerStop];
        } else if([output.status isEqual:@"install-err"]) {
            [self hiddenLoadingView];
            [ESToast toastError:NSLocalizedString(@"update_failed", @"升级失败")];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUpgradeStatus"];
            [self timerStop];
        } else if ([output.status isEqual:@""] || output.status == nil) {
        } else {
            [self timerStop];
        }
    }];
}

- (void)showLoadingViewWithTitle:(NSString *)title {
    UIWindow *window = [ESHomeCoordinator sharedInstance].window;
    if (_maskView) {
        [_maskView removeFromSuperview];
    }
    _maskView = [[UIView alloc] initWithFrame:window.bounds];
    _maskView.backgroundColor = ESColor.systemBackgroundColor;
    _maskView.alpha = 0.06;
    if (window.subviews.count > 0) {
        [window insertSubview:_maskView atIndex:1];
    }
    ESToast.showLoading(title, self.view);
    
}

- (void)hiddenLoadingView {
    [self.maskView removeFromSuperview];
    [ESToast dismiss];
}

- (void)updateViewStatus:(ESTask *)output {
    ESDLog(@"[ESUpgradeVC] updateViewStatus: %@", output);

    if ([output.status isEqual:@"installed"]) {
//        if (output.versionId == self.pckVersion) {
//            self.downBtn.hidden = YES;
//            self.outPointLabel.hidden = YES;
//            self.pointOutLabel.hidden = YES;
//
//            self.boxSizeLabel.text = @"已是最新版本";
//            self.systemDetailInfoBt.hidden = NO;
//        }
//        return;
    }
    if ([output.status isEqual:@"downloading"]) {
        self.downBtn.hidden = NO;
        [self.downBtn userEnable:NO];
        self.systemDetailInfoBt.hidden = YES;
        [self.downBtn startLoading:NSLocalizedString(@"state_downloading", @"正在下载")];
        self.outPointLabel.hidden = NO;
        [self.downBtn setUserInteractionEnabled:NO];
        return;
    }
    if ([output.status isEqual:@"installing"]) {
        self.downBtn.hidden = NO;
        [self.downBtn userEnable:NO];
        self.systemDetailInfoBt.hidden = YES;
        [self.downBtn startLoading:NSLocalizedString(@"state_installing", @"正在安装")];
        self.outPointLabel.hidden = NO;
        [self.downBtn setUserInteractionEnabled:NO];
        return;
    }
    

    if ([output.status isEqual:@"downloaded"]) {
        self.downBtn.hidden = NO;
        self.systemDetailInfoBt.hidden = YES;
        [self.downBtn userEnable:YES];
        [self.downBtn stopLoading:NSLocalizedString(@"update_dialog_bt_install_now", @"现在安装")];
        self.outPointLabel.hidden = YES;
        [self.downBtn setUserInteractionEnabled:YES];
        return;
    }
    if ([output.status isEqual:@"download-err"]) {
        self.downBtn.hidden = NO;
        [self.downBtn userEnable:YES];
        [self.downBtn stopLoading:NSLocalizedString(@"me_download_and_install", @"下载并安装")];
        [self.downBtn setUserInteractionEnabled:YES];
        self.systemDetailInfoBt.hidden = YES;
        self.outPointLabel.hidden = YES;
        return;
    }
    if ([output.status isEqual:@"install-err"]) {
        self.downBtn.hidden = NO;
        [self.downBtn userEnable:YES];
        [self.downBtn stopLoading:NSLocalizedString(@"update_dialog_bt_install_now", @"现在安装")];
        [self.downBtn setUserInteractionEnabled:YES];
        self.systemDetailInfoBt.hidden = YES;
        self.outPointLabel.hidden = YES;
        return;
    }
    if ([output.status isEqual:@""] || output.status == nil) {
        return;
    }
    
    self.downBtn.hidden = NO;
    self.systemDetailInfoBt.hidden = YES;
    [self.downBtn stopLoading:NSLocalizedString(@"me_download_and_install", @"下载并安装")];
    [self.downBtn userEnable:YES];
    [self.downBtn setUserInteractionEnabled:YES];
    self.outPointLabel.hidden = YES;
    return;
}

- (void)autoUpdateView {
    ESAutoUpdateOnOffVC *vc = [ESAutoUpdateOnOffVC new];
    vc.autoDownload = self.autoDownload;
    vc.autoInstall = self.autoInstall;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)creatTimer {
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    //0.创建队列
    if (!self.timer) {
        dispatch_queue_t queue = dispatch_get_main_queue();

        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

        //3.要调用的任务
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(timer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self getStatus];
        });

        //4.开始执行
        dispatch_resume(timer);
        self.timer = timer;
    }
}

- (void)timerStop {
    if (self.timer) {
        dispatch_source_cancel(self->_timer);
        self.timer = nil;
    }
}

- (ESGradientButton *)downBtn {
    if (!_downBtn) {
        _downBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
        [_downBtn setCornerRadius:10];
        [_downBtn setTitle:NSLocalizedString(@"me_download_and_install", @"下载并安装") forState:UIControlStateNormal];
        _downBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [_downBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(installAndUpdateAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_downBtn];
    }
    return _downBtn;
}

- (UIButton *)systemDetailInfoBt {
    if (!_systemDetailInfoBt) {
        _systemDetailInfoBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_systemDetailInfoBt setTitle:NSLocalizedString(@"view_details", @"查看详情") forState:UIControlStateNormal];
        _systemDetailInfoBt.titleLabel.font = ESFontPingFangMedium(16);
        [_systemDetailInfoBt setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_systemDetailInfoBt addTarget:self action:@selector(showSystemDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_systemDetailInfoBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _systemDetailInfoBt;
}

- (void)showSystemDetailInfo:(id)sender {
    ESSpaceSystemInfoVC *vc = [[ESSpaceSystemInfoVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)autoInstallSpaceSystem {
    ESDLog(@"[ESUpgradeVC] autoInstallSpaceSystem");
    _needAutoInstall = YES;
    
    if ( !(self.isViewLoaded && self.view.window)) {
        return;
    }
    self.isHaveInstall = NO;
    [self installVersion];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
          [self creatTimer];
    });
}

- (void)dealloc {
    [self timerStop];
}

- (ESBoxUpgradeType)upgradeType {
    return _upgradeInfo.upgradeType;
}

- (NSString *)appVersion {
    return _upgradeInfo.appVersion;
}

- (NSString *)pkgSize {
    return _upgradeInfo.pkgSize;
}

- (NSString *)desc {
    return _upgradeInfo.desc;
}

- (NSString *)packName {
    return _upgradeInfo.packName;
}

- (NSString *)pckVersion {
    return _upgradeInfo.pckVersion;
}

- (BOOL)haveNew {
    return _upgradeInfo.haveNew;
}

- (BOOL)isVarNewVersionExist {
    return _upgradeInfo.isVarNewVersionExist;
}


@end
