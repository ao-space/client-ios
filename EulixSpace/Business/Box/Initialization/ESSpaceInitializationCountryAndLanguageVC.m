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
//  ESSpaceInitializationContryAndLANGUAvc.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInitializationCountryAndLanguageVC.h"
#import "ESBoxBindViewModel.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <YYModel/YYModel.h>
#import "ESSpaceCountryAndLanguageListModule.h"
#import "ESCommListHeaderView.h"
#import "ESSpaceInitialzationProcessVC.h"
#import "UIView+Status.h"
#import "ESSapceWelcomeVC.h"
#import "ESSpaceInfoEditeVC.h"

@interface ESSpaceInitializationCountryAndLanguageVC () <ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESGradientButton *enterSpace;

@end

@implementation ESSpaceInitializationCountryAndLanguageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    ESCommListHeaderView *headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, 162)];
    headerView.iconImageView.image = [UIImage imageNamed:@"gj"];
    headerView.titleLabel.text = NSLocalizedString(@"binding_countryandlanguage" ,@"国家和语言");
    self.listModule.listView.tableHeaderView = headerView;
    
    [self.enterSpace setTitle:NSLocalizedString(@"box_bind_step_next", @"继续") forState:UIControlStateNormal];
    self.viewModel.delegate = self;
}

- (Class)listModuleClass {
    return [ESSpaceCountryAndLanguageListModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (void)nextStep {
    [self checkProcess];
}

- (void)checkProcess {
    //新绑定流程，从盒子初始化页过来
    if (self.viewModel.boxStatus.infoResult.paired == ESPairStatusUnpaired) {
        [self.view showLoading:YES];
        [self.viewModel sendBindComProgress];
        return;
    }
    
    //paired
    if (self.viewModel.boxStatus.infoResult.oldBox) {
        if (self.viewModel.diskInitialCode == ESDiskInitStatusNormal) {
            ESSapceWelcomeVC *next = [ESSapceWelcomeVC new];
            next.viewModel = self.viewModel;
            [self.navigationController pushViewController:next animated:YES];
            return;
        }
        [self.view showLoading:YES];
        [self.viewModel sendDiskRecognition];
    }
}

- (void)onBindCommand:(ESBCCommandType)command resp:(NSDictionary *)response {
    [self.view showLoading:YES];
    if (command == ESBCCommandTypeBindComProgressReq) {
        if (![response.allKeys containsObject:@"results"] ||
            ![response[@"results"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSInteger progress = [response[@"results"][@"progress"] intValue];
        if ( progress < 100) {
            ESSpaceInitialzationProcessVC *next = [ESSpaceInitialzationProcessVC new];
            next.viewModel = self.viewModel;
            [self.navigationController pushViewController:next animated:YES];
            return;
        }
        
        // >= 100
        ESSpaceInfoEditeVC *next = [ESSpaceInfoEditeVC new];
        next.viewModel = self.viewModel;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }
}


#pragma mark - Lazy Load

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"box_bind_step_next", @"继续") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [self.view addSubview:_enterSpace];
        [_enterSpace addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
        [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).inset(40 + kBottomHeight);
        }];
    }
    return _enterSpace;
}

@end
