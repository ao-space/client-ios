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
//  ESBindResultViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBindResultViewController.h"
#import "ESBCResult.h"
#import "ESBoxBindViewModel.h"
#import "ESBoxListViewController.h"
#import "ESBoxManager.h"
#import "ESEmptyView.h"
#import "ESGradientButton.h"
#import "ESHomeCoordinator.h"
#import "ESSecurityPasswordInputViewController.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>
#import "ESDiskRecognitionResp.h"

@interface ESBindResultViewController () <ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESGradientButton *actionButton;

@property (nonatomic, strong) ESEmptyView *emptyView;

@end

@implementation ESBindResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_BOX_BIND_RESULT;
    [self showResult];
 
    self.showBackBt = NO;
    // Do any additional setup after loading the view.
}

- (void)showResult {
    if (self.success) {
        [self showSuccess];
    } else {
        [self showFail];
    }
}

- (BOOL)isBind {
    return self.type == ESBindResultTypeBind;
}

- (void)showSuccess {
    ESEmptyItem *item = [ESEmptyItem new];
    item.title = self.isBind ? TEXT_BOX_BIND_SUCCESS : TEXT_BOX_UNBIND_SUCCESS;
    if (self.isBind) {
        NSString * content = NSLocalizedString(@"Disk is ready", @"您的空间已就绪");
        item.attributedContent = [content es_toAttr:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
        }];
    }
    
    item.backgroundImage = IMAGE_BOX_BIND_SUCCESS;
    [self.emptyView reloadWithData:item];
    self.actionButton.hidden = !self.isBind;

 
    if (self.isBind) {
        if (self.spaceReadyCheckModel.diskInitialCode == ESDiskInitStatusNotInit
            || self.spaceReadyCheckModel.diskInitialCode >= ESDiskInitStatusError) {
            // 磁盘未初始化化，或上次初始化错误，则再次显示【磁盘初始化】按钮
            
            NSString * btid = [self.viewModel getBtid];
            [ESBoxManager onParing:self.viewModel.boxInfo btid:btid diskStatus:ESDiskInitStatusNotInit init:self.viewModel.boxStatus.infoResult];
            
            NSString * text = NSLocalizedString(@"disk init", @"磁盘初始化");
            [self.actionButton setTitle:text forState:UIControlStateNormal];
            [self.actionButton addTarget:self action:@selector(onDiskInitBeginBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).offset(400);
                make.width.mas_equalTo(200);
                make.height.mas_equalTo(44);
            }];
        } else if (self.spaceReadyCheckModel.diskInitialCode == ESDiskInitStatusNormal
                   || self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport == NO)
        
        {
            // 磁盘正常，则显示【开始使用】按钮
            NSString * btid = [self.viewModel getBtid];
            [ESBoxManager onParing:self.viewModel.boxInfo btid:btid diskStatus:ESDiskInitStatusNormal init:self.viewModel.boxStatus.infoResult];
            
            [self.actionButton setTitle:TEXT_BOX_BIND_START_TO_USE forState:UIControlStateNormal];
            [self.actionButton addTarget:self action:@selector(onBeginUseForBind) forControlEvents:UIControlEventTouchUpInside];
        } else {
            NSString * text = [NSString stringWithFormat:@"空间状态不太对 %@, %ld", self.spaceReadyCheckModel, self.spaceReadyCheckModel.diskInitialCode];
            [ESToast toastError:text];
        }
    }
}

- (void)onBeginUseForBind {
//    [ESBoxManager onParing:self.viewModel.boxInfo];
    
    //到这里,都会有一个在使用的盒子
    //如果一开始是在登录页,则显示盒子首页
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:[ESBoxListViewController class]]) {
        [ESHomeCoordinator showHome];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loopChangeSwitchedNotification" object:nil userInfo:nil];
        });

        return;
    }
    ///从我的进来的,直接返回到我的首页
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onDiskInitBeginBtn {
    ESToast.waiting(TEXT_WAIT).delay(20).showFrom(self.view.window);
    [self.actionButton setEnabled:NO];
    self.viewModel.delegate = self;
    [self.viewModel sendDiskRecognition];
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response {
    [ESToast dismiss];
    [self.actionButton setEnabled:YES];
    
}

- (void)showFail {
    ESEmptyItem *item = [ESEmptyItem new];
    item.title = self.isBind ? TEXT_BOX_BIND_FAIL : TEXT_BOX_UNBIND_FAIL;
    NSString *content = self.isBind ? TEXT_BOX_BIND_FAIL_PROMPT : TEXT_BOX_UNBIND_FAIL_PROMPT;
    if (self.prompt) {
        content = self.prompt;
    }
    item.attributedContent = [content es_toAttr:@{
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
    }];
    item.backgroundImage = IMAGE_BOX_BIND_FAIL;
    [self.emptyView reloadWithData:item];
    ///解绑失败了
    if (!self.isBind) {
        self.actionButton.hidden = YES;
        return;
    }
    
    if (self.type == ESBindResultTypeBind) {
        // 绑定失败的场景下，不应该有下面的【解绑设备】按钮
        return;
    }

    ///解绑成功了
    self.actionButton.hidden = NO;
    [self.actionButton setTitle:TEXT_BOX_BIND_UNBIND forState:UIControlStateNormal];
    //解绑的下一步是输入安全密码
    [self.actionButton addTarget:self action:@selector(inputPassword) forControlEvents:UIControlEventTouchUpInside];
     
}

/// 操作成功后的下一步
- (void)nextStepWhenSuccess {
    if (self.type == ESBindResultTypeUnbind) {
       [ESHomeCoordinator showLogin];
        return;
    }
    if (!self.isBind) {
        ///解绑成功, 则需要删除配对信息
        //如果解绑的是当前盒子, 则要跳到登录(盒子列表)页面,`revoke`里会自动做这个操作
        [ESBoxManager revoke:ESBoxManager.activeBox];
        return;
    }
//    [ESBoxManager onParing:self.viewModel.boxInfo];
    
    NSString * btid = [self.viewModel getBtid];
    [ESBoxManager onParing:self.viewModel.boxInfo btid:btid diskStatus:ESDiskInitStatusNormal init:self.viewModel.boxStatus.infoResult];
    
    //到这里,都会有一个在使用的盒子
    //如果一开始是在登录页,则显示盒子首页
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:[ESBoxListViewController class]]) {
        [ESHomeCoordinator showHome];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loopChangeSwitchedNotification" object:nil userInfo:nil];
        });

        return;
    }
    ///从我的进来的,直接返回到我的首页
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)inputPassword {
    ESSecurityPasswordInputViewController *next = [ESSecurityPasswordInputViewController new];
    next.inputDone = ^(NSString *securityPassword) {
        [self unbindBox:securityPassword];
    };
    [self.navigationController pushViewController:next animated:YES];
}

- (void)unbindBox:(NSString *)securityPassword {
    [self.actionButton startLoading:TEXT_BOX_UNBIND];
    [self.viewModel revokeWithSecurityPassword:securityPassword];
}

#pragma mark - ESBluetoothCommunicationDelegate

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus {
    self.killWhenPushed = YES;
    [self.actionButton stopLoading:TEXT_BOX_UNBIND];
    [ESBoxManager.manager justRevoke:ESBoxManager.activeBox];
    
    ESBindResultViewController *next = [ESBindResultViewController new];
    next.type = ESBindResultTypeUnbind;
    next.success = boxStatus.revokeResult.success;
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Lazy Load

- (ESGradientButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_actionButton setCornerRadius:10];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_actionButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_actionButton];
        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 68);
        }];
    }
    return _actionButton;
}

- (ESEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[ESEmptyView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        //失败的有返回按钮
        //解绑一直有返回按钮
        if (!self.success || !self.isBind) {
            UIButton *back = [UIButton new];
            [back setTitle:TEXT_BACK forState:UIControlStateNormal];
            [back setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
            back.titleLabel.font = [UIFont systemFontOfSize:12];
            UIView *line = [back es_addline:0 offset:0];
            line.backgroundColor = ESColor.primaryColor;
            if (self.success) {
                [back addTarget:self action:@selector(nextStepWhenSuccess) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            }
            _emptyView.onLoad = ^(UIImageView *backgroundView) {
                [backgroundView.superview addSubview:back];
                [back mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(20);
                    make.centerX.mas_equalTo(backgroundView);
                    make.top.mas_equalTo(backgroundView.mas_bottom).inset(115);
                }];
            };
        }
    }
    return _emptyView;
}

@end
