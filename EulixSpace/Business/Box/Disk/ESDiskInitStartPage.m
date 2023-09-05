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
//  ESDiskInitStartPage.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInitStartPage.h"
#import "ESDiskInitStartPageModule.h"
#import "ESCommListHeaderView.h"
#import "ESDiskInitProgressPage.h"
#import "UIView+Status.h"
#import "ESBoxManager.h"
#import "ESDiskInitSuccessPage.h"
#import "UIView+ESTool.h"
#import "ESToast.h"
#import "ESDiskEmptyPage.h"

@interface ESDiskInitStartPage ()

@property (nonatomic, strong) ESSpaceReadyCheckResultModel * spaceReadyCheckModel;
@property (nonatomic, strong) ESDiskImagesView * diskImageView;
@property (nonatomic, strong) UIButton * configBtn;
@property (nonatomic, strong) ESGradientButton * enterSpace;

@end

@implementation ESDiskInitStartPage

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = NSLocalizedString(@"disk init", @"磁盘初始化");
  
    self.viewModel.delegate = self;

    ESCommListHeaderView *headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, 198)];
    headerView.iconImageView.image = [UIImage imageNamed:@"cp"];
    headerView.titleLabel.text = NSLocalizedString(@"disk_initialization", @"磁盘初始化");
    headerView.detailLabel.text = NSLocalizedString(@"binding_recommendeddiskSettings",  @"以下是磁盘的推荐设置，你可以使用这些设置来进行\n磁盘初始化，也可以逐个自定义设置");
    self.listModule.listView.tableHeaderView = headerView;
    
    if (self.viewModel.paringBoxItem) {
        self.showBackBt = YES;
        [self.view showLoading:YES];
        [self.viewModel sendSpaceReadyCheck];
    } else if (self.diskListModel == nil) {
        self.showBackBt = NO;
        [self.view showLoading:YES];
        [self.viewModel sendSpaceReadyCheck];
    } else {
        self.showBackBt = NO;
        [self setAdviceRaidType];
        [(ESDiskInitStartPageModule *)self.listModule loadDataWithDiskModel:self.diskListModel];
    }
  
    [self setupViews];
}

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    if ([response isOK]) {
        ESSpaceReadyCheckResultModel * model = response.results;
        self.viewModel.diskInitialCode = model.diskInitialCode;
        
        [self.viewModel sendDiskRecognition];
    } else {
        [self.view showLoading:NO];
        NSString * text = NSLocalizedString(@"enter disk init failed", @"进入磁盘初始化流程失败");
        [ESToast toastError:text];
    }
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response {
    [self.view showLoading:NO];

    if ([response isOK]) {
        ESDiskListModel *diskModel = response.results;
        if (self.viewModel.diskInitialCode == ESDiskInitStatusNormal) {
            self.viewModel.paringBoxItem.diskInitStatus = ESDiskInitStatusNormal;
            [[ESBoxManager manager] saveBox:self.viewModel.paringBoxItem];
            
            // 如果已经初始化完成，则跳转到结果页面
            ESDiskInitSuccessPage * ctl = [[ESDiskInitSuccessPage alloc] init];
            ctl.viewModel = self.viewModel;
            ctl.diskListModel = response.results;
            [self.navigationController pushViewController:ctl animated:NO];
            return;
        } else if (self.viewModel.diskInitialCode == ESDiskInitStatusFormatting
                   || self.viewModel.diskInitialCode == ESDiskInitStatusSynchronizingData) {
            ESDiskInitProgressPage * ctl = [[ESDiskInitProgressPage alloc] init];
            ctl.status = ESDeviceStartupStatusDiskIniting;
            ctl.viewModel = self.viewModel;
            ctl.diskListModel = response.results;
            [self.navigationController pushViewController:ctl animated:NO];
            return;
        }  else if ([diskModel hasDisk:ESDiskStorage_Disk1] == NO &&
                [diskModel hasDisk:ESDiskStorage_Disk2] == NO &&
                [diskModel hasDisk:ESDiskStorage_SSD] == NO) {
                ESDiskEmptyPage * ctl = [[ESDiskEmptyPage alloc] init];
                ctl.viewModel = self.viewModel;
                ctl.diskListModel = response.results;
                [self.navigationController pushViewController:ctl animated:NO];
                return;
            }
        self.diskListModel = response.results;
        [self setAdviceRaidType];
        [(ESDiskInitStartPageModule *)self.listModule loadDataWithDiskModel:self.diskListModel];
    } else {
        NSString * text = NSLocalizedString(@"enter disk init failed", @"进入磁盘初始化流程失败");
        [ESToast toastError:text];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat tableHeight = self.listModule.listView.bounds.size.height;
    CGFloat contentHeight = self.listModule.listView.contentSize.height;
    if (tableHeight > contentHeight) {
        self.listModule.listView.contentInset = UIEdgeInsetsMake(0, 0, 198 + tableHeight - contentHeight, 0);
    } else {
        self.listModule.listView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)setAdviceRaidType {
    if ([self.diskListModel hasDisk:ESDiskStorage_Disk1] && [self.diskListModel hasDisk:ESDiskStorage_Disk2]) {
        self.diskListModel.raidType = ESDiskStorageModeType_Raid;
    } else {
        self.diskListModel.raidType = ESDiskStorageModeType_Normal;
    }
}

- (Class)listModuleClass {
    return [ESDiskInitStartPageModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 26, 116 + kBottomHeight, 26);
}

- (void)setupViews {
    [self.view addSubview:self.enterSpace];
    [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(60 + kBottomHeight);
    }];
    [self.view addSubview:self.configBtn];
    [_configBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(6 + kBottomHeight);
    }];
}

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"box_bind_step_next", @"继续") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_enterSpace addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSpace;
}

- (UIButton *)configBtn {
    if (!_configBtn) {
        _configBtn = [[UIButton alloc] init];
        _configBtn.backgroundColor = ESColor.clearColor;
        [_configBtn setTitle:NSLocalizedString(@"binding_customsettings", @"自定义设置") forState:UIControlStateNormal];
        [_configBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_configBtn addTarget:self action:@selector(configAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _configBtn;
}

- (void)configAction:(id)sender {
    ESDLog(@"[ESDiskInitStartPage][configAction]");
   
}

- (void)nextStep {
    ESDLog(@"[ESDiskInitStartPage][nextStep]");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"binding_formattingtips", @"格式化提示")
                                                                   message: NSLocalizedString(@"binding_diskinitializationtips", @"磁盘初始化操作包含格式化过程，磁\n盘内原有数据将全部清除")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle: NSLocalizedString(@"common_confirm", @"确定")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        ESDiskInitProgressPage * ctl = [[ESDiskInitProgressPage alloc] init];
        ctl.viewModel = self.viewModel;
        ctl.diskListModel = self.diskListModel;
        [self.navigationController pushViewController:ctl animated:NO];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common_cancel", @"取消")
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *_Nonnull action) {
    }];
    [alert addAction:conform];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (ESDiskImagesView *)diskImageView {
    if (!_diskImageView) {
        ESDiskImagesView * view = [[ESDiskImagesView alloc] init];
        _diskImageView = view;
    }
    return _diskImageView;
}

@end
