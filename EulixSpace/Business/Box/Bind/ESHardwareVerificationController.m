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
//  ESHardwareVerificationController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/7.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESHardwareVerificationController.h"
#import "ESGradientButton.h"
#import "ESSecurityPasswordInputViewController.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "ESBoxBindViewModel.h"
#import "ESBoxSearchBlePromptView.h"
#import "UIFont+ESSize.h"
#import "ESBoxSearchWiredConnectionPromptView.h"
#import "ESBoxManager.h"
#import "ESSecurityPasswordResetController.h"
#import "NSError+ESTool.h"
#import "ESBindSecurityEmailByHardwareController.h"
#import "UIViewController+ESTool.h"
#import "ESPermissionController.h"
#import "ESBoxSearchingPromptView.h"
#import "ESBoxSearchingNotFoundView.h"

@interface ESHardwareVerificationController ()<ESBoxBindViewModelDelegate>
@property (nonatomic, strong) ESGradientButton *searchButton;
@property (nonatomic, strong) ESBoxBindViewModel *viewModel;

@property (nonatomic, strong) ESBoxSearchingPromptView *searchingPrompt;
@property (nonatomic, strong) ESBoxSearchingNotFoundView *searchingNotFoundPrompt;

@end

@implementation ESHardwareVerificationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Hardware device verification", @"硬件设备验证");
    ESDLog(@"[安保功能] 硬件设备验证 btid:%@", self.btid);

    if (self.btid.length == 0) {
        return;
    }

    if (!self.viewModel) {
        self.viewModel = [ESBoxBindViewModel viewModelWithDelegate:self];
        self.viewModel.mode = ESBoxBindModeBluetoothAndWiredConnection;
    }
    [self initUI];
    [self startBoxSearch];

}

- (void)initUI {
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 68);
    }];
    
    [self.searchingPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight);
    }];
    
    [self.searchingNotFoundPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight);
    }];
    
    self.searchingNotFoundPrompt.hidden = YES;
}

- (void)onSearchBtn {
    [self startBoxSearch];
}

- (void)startBoxSearch {
    [self reloadWithState:ESBoxBindStateScaning];
    [self.viewModel searchWithUniqueId:self.btid];
}


- (void)reloadWithState:(ESBoxBindState)state {
    if (state == ESBoxBindStateScaning) {
        self.searchingNotFoundPrompt.hidden = YES;
        self.searchingPrompt.hidden = NO;
        [self.searchingPrompt reloadWithState:ESBoxSearchingStateScaning];
    } else  {
        [self.searchingPrompt reloadWithState:ESBoxSearchingStateStop];
    }
    
    if (state == ESBoxBindStateNotFound) {
        self.searchingNotFoundPrompt.hidden = NO;
        self.searchingPrompt.hidden = YES;
    }
}

#pragma mark - ESBoxBindViewModelDelegate

- (void)viewModelOnClose:(NSError *)error {
    ESDLog(@"[安保功能] viewModelOnClose：%@", [error errorMessage]);
}

- (void)viewModelLocalNetServiceNotReachable:(NSError *)error {
    [self reloadWithState:ESBoxBindStateNotFound];
}

- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus {
    self.searchButton.hidden = YES;
    if (boxStatus && boxStatus.infoResult) {
        ESDLog(@"[安保功能] 搜索到设备");
        // 拿到盒子的信息
        [self reloadWithState:ESBoxBindStateFound];
        
        if (self.authType == ESAuthenticationTypeBinderResetPassword
            || self.authType == ESAuthenticationTypeAutherResetPassword
            || self.authType == ESAuthenticationTypeBinderSetEmail
            || self.authType == ESAuthenticationTypeBinderModifyEmail
            || self.authType == ESAuthenticationTypeAutherModifyEmail
            || self.authType == ESAuthenticationTypeAutherSetEmail) {
            
            if (self.searchedBlock) {
                self.searchedBlock(self.authType, self.viewModel, self.applyRsp);
            }
            return;
        }
        
        [ESToast toastInfo:@"搜索到了，但类型不对"];
        return;
    }

    [self reloadWithState:ESBoxBindStateNotFound];
    ESDLog(@"[安保功能] 没搜索到设备");
}

- (ESGradientButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_searchButton setCornerRadius:10];
        [_searchButton setTitle:NSLocalizedString(@"Start searching", @"开始搜索") forState:UIControlStateNormal];
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_searchButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_searchButton];
        [_searchButton addTarget:self action:@selector(onSearchBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (ESBoxSearchingPromptView *)searchingPrompt {
    if (!_searchingPrompt) {
        _searchingPrompt = [ESBoxSearchingPromptView new];
        [self.view addSubview:_searchingPrompt];
    }
    return _searchingPrompt;
}

- (ESBoxSearchingNotFoundView *)searchingNotFoundPrompt {
    if (!_searchingNotFoundPrompt) {
        _searchingNotFoundPrompt = [ESBoxSearchingNotFoundView new];
        [self.view addSubview:_searchingNotFoundPrompt];
        weakfy(self)
        _searchingNotFoundPrompt.searchAginBlock = ^() {
            strongfy(self)
            self.searchingNotFoundPrompt.hidden = YES;
            [self startBoxSearch];
        };
    }
    return _searchingNotFoundPrompt;
}

- (void)dealloc {
}

@end
