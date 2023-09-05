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
//  ESAutoUpdateOnOffVC.m
//  EulixSpace
//
//  Created by qu on 2021/11/15.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAutoUpdateOnOffVC.h"
#import "ESThemeDefine.h"
#import "ESUpgradeApi.h"
#import <Masonry/Masonry.h>

@interface ESAutoUpdateOnOffVC ()

@property (strong, nonatomic) UILabel *downTitleLabel;

@property (strong, nonatomic) UILabel *downTitlePointOutLabel;

@property (strong, nonatomic) UIView *downTitlePointOutView;

@property (strong, nonatomic) UISwitch *downSwitch;

@property (strong, nonatomic) UILabel *installTitleLabel;

@property (strong, nonatomic) UISwitch *installSwitch;

@property (strong, nonatomic) UILabel *installTitlePointOutLabel;

@property (strong, nonatomic) UIView *installTitlePointOutView;

@property (assign, nonatomic) BOOL isAllOffOn;

@property (assign, nonatomic) BOOL isDownOffOn;

@property (assign, nonatomic) BOOL isInstallOffOn;

@end

@implementation ESAutoUpdateOnOffVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Automatic_Upgrade", @"自动升级");
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self initUI];

    [self.downSwitch setOn:self.autoDownload.boolValue];
    [self.installSwitch setOn:self.autoInstall.boolValue];
}

- (void)initUI {
    [self.downTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(40.0);
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.height.equalTo(@(25.0f));
   
    }];

    [self.downSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(40.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        make.height.equalTo(@(30.0f));
        make.width.equalTo(@(50.0f));
    }];

    [self.installTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(146.0);
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.height.equalTo(@(25.0f));
   
    }];

    [self.installSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(146.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        make.height.equalTo(@(30.0f));
        make.width.equalTo(@(50.0f));
    }];

    [self installTitlePointOutLabel];

    [self downTitlePointOutLabel];
}

- (UILabel *)downTitleLabel {
    if (nil == _downTitleLabel) {
        _downTitleLabel = [UILabel new];
        _downTitleLabel.text = NSLocalizedString(@"Download_Updates", @"下载更新");
        _downTitleLabel.numberOfLines = 1;
        _downTitleLabel.textColor = ESColor.labelColor;
        _downTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        _downTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_downTitleLabel];
    }
    return _downTitleLabel;
}

- (UILabel *)downTitlePointOutLabel {
    if (nil == _downTitlePointOutLabel) {
        _downTitlePointOutLabel = [UILabel new];
        _downTitlePointOutLabel.text = NSLocalizedString(@"me_download_prompt", @"开启后，设备将通过网络自动下载更新。");
        _downTitlePointOutLabel.numberOfLines = 0;
        [_downTitlePointOutLabel sizeToFit]; // 让标签根据文本高度自适应大小

        CGFloat labelHeight = CGRectGetHeight(_downTitlePointOutLabel.frame);
        CGFloat padding = 10.0; // 设置标签与 bgView 上下边距的间距
        CGFloat bgViewHeight = labelHeight + padding * 2;
        _downTitlePointOutLabel.textColor = ESColor.secondaryLabelColor;
        _downTitlePointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _downTitlePointOutLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:_downTitlePointOutLabel];
        [_downTitlePointOutLabel sizeToFit];

        [self.view addSubview:bgView];
  
        [_downTitlePointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(bgView.mas_centerY).offset(0.0);
            make.left.mas_equalTo(self.view.mas_left).offset(26.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        }];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(86.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.height.equalTo(@(bgViewHeight));
        }];
        [bgView addSubview:_downTitlePointOutLabel];
    }
    return _downTitlePointOutLabel;
}

- (UILabel *)installTitleLabel {
    if (nil == _installTitleLabel) {
        _installTitleLabel = [UILabel new];
        _installTitleLabel.numberOfLines = 2;
        _installTitleLabel.text = NSLocalizedString(@"me_install", @"安装更新");
        _installTitleLabel.textColor = ESColor.labelColor;
        _installTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        _installTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_installTitleLabel];
    }
    return _installTitleLabel;
}

- (UILabel *)installTitlePointOutLabel {
    if (nil == _installTitlePointOutLabel) {
        _installTitlePointOutLabel = [UILabel new];
        _installTitlePointOutLabel.numberOfLines = 0;
        _installTitlePointOutLabel.textColor = ESColor.secondaryLabelColor;
        _installTitlePointOutLabel.text = NSLocalizedString(@"me_install_prompt", @"开启后，设备将在早上2:00-4:00处于空闲状态时自动安装并重启。");
        _installTitlePointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _installTitlePointOutLabel.textAlignment = NSTextAlignmentLeft;

    
        UIView *bgView = [UIView new];
        bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        [bgView addSubview:_installTitlePointOutLabel];
        [self.view addSubview:bgView];

        [_installTitlePointOutLabel sizeToFit]; // 让标签根据文本高度自适应大小

        CGFloat labelHeight = CGRectGetHeight(_installTitlePointOutLabel.frame);
        CGFloat padding = 10.0; // 设置标签与 bgView 上下边距的间距
        CGFloat bgViewHeight = labelHeight + padding * 2;

        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(192.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.height.equalTo(@(bgViewHeight));
        }];

        [_installTitlePointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(bgView.mas_centerY).offset(0);
            make.left.mas_equalTo(self.view.mas_left).offset(26.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        }];

    }
    return _installTitlePointOutLabel;
}

- (UISwitch *)downSwitch {
    if (nil == _downSwitch) {
        _downSwitch = [[UISwitch alloc] init];
        [self.view addSubview:_downSwitch];
        [_downSwitch addTarget:self
                        action:@selector(downSwitched:)
              forControlEvents:UIControlEventValueChanged];
        [_downSwitch setOn:self.autoDownload.boolValue];
    }
    return _downSwitch;
}

- (UISwitch *)installSwitch {
    if (nil == _installSwitch) {
        _installSwitch = [[UISwitch alloc] init];
        [self.view addSubview:_installSwitch];
        [_installSwitch addTarget:self
                           action:@selector(installSwitched:)
                 forControlEvents:UIControlEventValueChanged];
        [_installSwitch setOn:self.autoInstall.boolValue];
    }
    return _installSwitch;
}

- (void)downSwitched:(UISwitch *)sender {
    ESUpgradeApi *api = [ESUpgradeApi new];

    if (sender.on) {
        self.autoDownload = @(YES);
    } else {
        self.autoDownload = @(NO);
        self.autoInstall = @(NO);
        [_installSwitch setOn:self.autoInstall.boolValue];
    }

    ESUpgradeConfig *config = [ESUpgradeConfig new];
    if (!self.autoInstall) {
        self.autoInstall = @(NO);
    }

    config.autoInstall = self.autoInstall;
    config.autoDownload = self.autoDownload;

    [api agentV1ApiUpgradeConfigPostWithConfig:config
                             completionHandler:^(ESUpgradeConfig *output, NSError *error){

                             }];
}

- (void)installSwitched:(UISwitch *)sender {
    ESUpgradeApi *api = [ESUpgradeApi new];
    if (sender.on) {
        self.autoDownload = @(YES);
        self.autoInstall = @(YES);
        [_downSwitch setOn:self.autoDownload.boolValue];
    } else {
        self.autoInstall = @(NO);
    }

    ESUpgradeConfig *config = [ESUpgradeConfig new];
    if (!self.autoDownload) {
        self.autoDownload = @(NO);
    }
    config.autoInstall = self.autoInstall;

    config.autoDownload = self.autoDownload;

    [api agentV1ApiUpgradeConfigPostWithConfig:config
                             completionHandler:^(ESUpgradeConfig *output, NSError *error){

                             }];
}

@end
