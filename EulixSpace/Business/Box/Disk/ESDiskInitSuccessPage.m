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
//  ESDiskInitSuccessPage.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInitSuccessPage.h"
#import "ESDiskInitSuccessModule.h"
#import "ESToast.h"
#import "ESSapceWelcomeVC.h"

@interface ESDiskInitSuccessPage () <ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESDiskImagesView * diskImageView;
@property (nonatomic, strong) ESGradientButton * enterSpace;
@property (nonatomic, strong) ESDiskManagementModel * model;
@property (nonatomic, strong) ESDiskInitSuccessView * successView;

@end

@implementation ESDiskInitSuccessPage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackBt = NO;

    [self setupViews];
    self.viewModel.delegate = self;
    ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(60).showFrom(self.view);
    [self.viewModel sendDiskManagementList];
}

- (void)viewModelDiskManagementList:(ESDiskManagementListResp *)response {
    [ESToast dismiss];
    if ([response isOK]) {
        self.model = response.results;
        [self.listModule.listView reloadData];
    } else {
        [ESToast toastError:NSLocalizedString(@"request failed", @"请求失败")];
    }
}

- (Class)listModuleClass {
    return [ESDiskInitSuccessModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 84 + 20 + kBottomHeight, 0);
}

- (void)setupViews {
    [self.view addSubview:self.enterSpace];
    [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(40 + kBottomHeight);
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

- (void)nextStep {
    ESSapceWelcomeVC *next = [ESSapceWelcomeVC new];
    next.viewModel = self.viewModel;
    next.paringBoxItem = self.viewModel.paringBoxItem;
    [self.navigationController pushViewController:next animated:YES];
    return;
}

- (ESDiskImagesView *)diskImageView {
    if (!_diskImageView) {
        ESDiskImagesView * view = [[ESDiskImagesView alloc] init];
        _diskImageView = view;
    }
    return _diskImageView;
}

- (ESDiskInitSuccessView *)successView {
    if (!_successView) {
        _successView = [[ESDiskInitSuccessView alloc] init];
    }
    return _successView;
}

@end
