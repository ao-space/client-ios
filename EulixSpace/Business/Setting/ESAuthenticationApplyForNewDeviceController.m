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
//  ESAuthenticationApplyForNewDeviceController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationApplyForNewDeviceController.h"
#import "ESGradientButton.h"
#import "ESServiceNameHeader.h"
#import "ESBoxManager.h"
#import "ESToast.h"

@interface ESAuthenticationApplyForNewDeviceController ()<ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESBoxBindViewModel * viewModel;
@property (nonatomic, strong) ESSecurityEmailModel * emailInfo;
@property (nonatomic, strong) UIView * binderUnavailableView;

@property (nonatomic, assign) BOOL sendApplySuccess;
@property (nonatomic, weak) UIViewController<ESBoxBindViewModelDelegate> * srcCtl;

@end

@implementation ESAuthenticationApplyForNewDeviceController


+ (void)showAuthApplyView:(UIViewController<ESBoxBindViewModelDelegate> *)srcCtl
                     type:(ESAuthenticationType)authType
                viewModel:(ESBoxBindViewModel * _Nullable)viewModel
                    email:(ESSecurityEmailModel * _Nullable)emailInfo
                    block:(void(^)(ESAuthApplyRsp * applyRsp))optBlock
                   cancel:(void(^)(void))cancelBlock {
    ESAuthenticationApplyForNewDeviceController * dstCtl = [[ESAuthenticationApplyForNewDeviceController alloc] init];
    dstCtl.optBlock = optBlock;
    dstCtl.cancelBlock = cancelBlock;
    dstCtl.authType = authType;
    dstCtl.emailInfo = emailInfo;
    dstCtl.viewModel = viewModel;
    dstCtl.srcCtl = srcCtl;
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);

    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.viewModel getPairStatus] == ESPairStatusPaired) {
        // 有绑定端，才会发起授权申请
        [self sendReqForNewDevice];
    } else {
        // 无绑定端时，直接跳过申请授权页面，到24小时后生效的页面
        [self onUnavailable];
    }
}

- (void)dealloc {
    self.viewModel.delegate = self.srcCtl;
}

- (void)sendReqForNewDevice {
    self.viewModel.delegate = self;
    
    ESNewDeviceApplyReq * req = [[ESNewDeviceApplyReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_passwd_reset_newdevice_apply_local;
    req.apiPath = api_security_passwd_reset_newdevice_apply_local;
    req.entity.deviceInfo = [UIDevice currentDevice].name ?: @"No device Info";;
    req.entity.clientUuid = ESBoxManager.clientUUID;
    req.entity.applyId = [NSString stringWithFormat:@"applyId_%f", [[NSDate date] timeIntervalSince1970]];;

    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESDLog(@"[安保功能] 收到的Passthrough：%@", rspDict);
    
    ESNewDeviceLocalRsp * model = [ESNewDeviceLocalRsp.class yy_modelWithJSON:rspDict];
    if (![model isOK]) {
        [ESToast toastError:model.message];
        return;
    }
    
    ESNewDeviceAuthApplyRsp * innerModel = model.results;
    if (![innerModel isOK]) {
        if ([innerModel.code isEqualToString:@"ACC-410"]) {
            [self showAlert:NSLocalizedString(@"request is too frequent. Try again in 10 minutes", @"原因：请求次数过多，请10分钟后重试！") handle:^{
                [self onCancelBtn];
            }];
            return;
        }
        
       [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        return;
    }
    
    if (!self.sendApplySuccess) {
        self.sendApplySuccess = YES;
        [self sendPollLocal];
        return;
    }
    
    if (innerModel.results == nil || innerModel.results.count == 0) {
        [self sendPollLocal];
        return;
    }
    
    ESAuthApplyRsp * applyRsp = innerModel.results.firstObject;
    if (applyRsp.accept) {
        // 收到授权的确认后，再判断是否有邮箱，这设计……
        if (self.emailInfo == nil || self.emailInfo.emailAccount.length <= 0) {
            [self showNotSetSecurityEmailHint];
            return;
        }
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (self.optBlock) {
                self.optBlock(applyRsp);
            }
        }];
    } else {
        [self showRefuseView];
    }
}


- (void)sendPollLocal {
    ESDLog(@"[安保功能] 发送 message_poll_local");
    ESSecurityMessagePollReq * req = [[ESSecurityMessagePollReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_message_poll_local;
    req.apiPath = api_security_message_poll_local;
    req.entity.clientUuid = ESBoxManager.clientUUID;

    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

- (void)onUnavailable {
    self.applyView.hidden = YES;
    // 无绑定端时，直接跳过申请授权页面
    [self.binderUnavailableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view).offset(53);
        make.trailing.mas_equalTo(self.view).offset(-53);
    }];
}

- (void)onSureFrom24HoursLaterView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    }];
    return;
    
    // 确认24小时后生效后再判断邮箱，这设计……
    if (self.emailInfo == nil || self.emailInfo.emailAccount.length <= 0) {
        [self showNotSetSecurityEmailHint];
        return;
    }

    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (self.optBlock) {
            ESAuthApplyRsp * rsp = [[ESAuthApplyRsp alloc] init];
            rsp.accept = YES;
            self.optBlock(rsp);
        }
    }];
}

- (void)showNotSetSecurityEmailHint {
    self.applyView.hidden = YES;
    [self.failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view).offset(53);
        make.trailing.mas_equalTo(self.view).offset(-53);
    }];
    
    self.failedHintImageView.image = [UIImage imageNamed:@"not_set_security_email"];
    self.reasonTitleLabel.text = NSLocalizedString(@"security email verify failed", @"密保邮箱验证失败");
    self.reasonLabel.text = NSLocalizedString(@"unset security email reason", @"原因：未绑定密保邮箱");
    /*
     您可以在原绑定或授权登录的终端上通过【硬件设备验证】或其他方式找回安全密码。
     */
    self.reasonHintLabel.text = NSLocalizedString(@"unset security email hint", @"");
}

- (UIView *)binderUnavailableView {
    if (!_binderUnavailableView) {
        UIView * containView = [[UIView alloc] init];
        containView.backgroundColor = [UIColor whiteColor];
        containView.layer.masksToBounds = YES;
        containView.layer.cornerRadius = 10;
        [self.view addSubview:containView];
        _binderUnavailableView = containView;
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_hint_image"]];
        [containView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.top.mas_equalTo(containView).offset(20);
        }];
        self.failedHintImageView = iv;
        
        UILabel * label = [[UILabel alloc] init];
        self.reasonTitleLabel = label;
        label.numberOfLines = 0;
        label.font = ESFontPingFangMedium(18);
        label.textColor = [UIColor es_colorWithHexString:@"#333333"];
        label.text = NSLocalizedString(@"Tips", @"提示");
        [containView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.leading.mas_greaterThanOrEqualTo(containView).offset(10);
            make.trailing.mas_lessThanOrEqualTo(containView).offset(-10);
            make.top.mas_equalTo(iv.mas_bottom).offset(10);
        }];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.numberOfLines = 0;
        [containView addSubview:label1];
        //管理员无法在原绑定端确认，本次修改内容将延迟24小时生效。在延迟生效期间若绑定端操作拒绝，本次修改将不生效。
        NSString * content = NSLocalizedString(@"admin unavailable, opt delay after 24 hours", @"管理员无法在原绑定端确认，本次修改内容将延迟24小时生效。在延迟生效期间若绑定端操作拒绝，本次修改将不生效。");
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:content
        attributes: @{NSFontAttributeName: ESFontPingFangRegular(14),
                      NSForegroundColorAttributeName: [UIColor es_colorWithHexString:@"#333333"]}];
        NSString * hint = NSLocalizedString(@"24 hours", @"24小时");
        NSRange range = [content rangeOfString:hint];
        if (range.location != NSNotFound) {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor es_colorWithHexString:@"#337AFF"] range:range];
        }
        label1.attributedText = string;
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(label.mas_bottom).offset(10);
            make.left.mas_equalTo(containView).offset(30);
            make.right.mas_equalTo(containView).offset(-30);
        }];
        
        ESGradientButton * btn = [[ESGradientButton alloc] init];
        [btn setCornerRadius:10];
        [btn addTarget:self action:@selector(onSureFrom24HoursLaterView) forControlEvents:UIControlEventTouchUpInside];
        [containView addSubview:btn];
        [btn setTitle:NSLocalizedString(@"ok", @"确定") forState:UIControlStateNormal];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(containView);
            make.top.mas_equalTo(label1.mas_bottom).offset(26);
        }];
        
        UIButton * cancelBtn = [[UIButton alloc] init];
        [cancelBtn addTarget:self action:@selector(onCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [containView addSubview:cancelBtn];
        [cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor es_colorWithHexString:@"#85899C"] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = ESFontPingFangMedium(16);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(containView);
            make.bottom.mas_equalTo(containView).offset(-20);
            make.top.mas_equalTo(btn.mas_bottom).offset(10);
        }];
    }
    return _binderUnavailableView;
}


@end
