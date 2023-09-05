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
//  ESAuthenticationController.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationController.h"
#import "ESGradientButton.h"
#import "UIFont+ESFont.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import "ESNetworkRequestManager.h"
#import "ESSpaceGatewayNotificationServiceApi.h"
#import "ESNotifiResp.h"
#import <YYModel/YYModel.h>
#import "NSError+ESTool.h"
#import "ESToast.h"
#import "ESServiceNameHeader.h"
#import "ESOptTypeHeader.h"

@interface ESAuthenticationController ()

@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIImageView * hintIv;
@property (nonatomic, strong) UILabel * hintLabel;

@property (nonatomic, strong) ESGradientButton * sureBtn;
@property (nonatomic, strong) UIButton * cancelBtn;

@property (nonatomic, strong) ESNotifiSecurityTokenResp * securityTokenResp;

@end

@implementation ESAuthenticationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self setupView];
    [self reqNotifiMessage];
}

- (void)showHintText {
    //@"您正在终端 %@ 上进行安全密码相关操作，请确认是否为本人？"
    NSString * str = [NSString stringWithFormat:NSLocalizedString(@"es_auth_confirm_by_binder", @"") , self.securityTokenResp.authDeviceInfo];
    NSMutableAttributedString * attriString = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSDictionary * dict = @{
        NSForegroundColorAttributeName: [ESColor colorWithHex:0x337AFF]
    };
    
    NSRange range = [str rangeOfString:self.securityTokenResp.authDeviceInfo];
    [attriString addAttributes:dict range:range];
    self.hintLabel.attributedText = attriString;
}

- (void)reqNotifiMessage {
    if (self.messageId == nil || self.messageId.length == 0) {
        [ESToast toastError:@"messageId is nil"];
        return;
    }
    
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
//    [params setObject:self.messageId forKey:@"messageId"];
    params[@"messageId"] = self.messageId;

    weakfy(self);
    [ESNetworkRequestManager sendCallRequest:@{ServiceName: eulixspaceAccountService,
                                               ApiName : notification_get
                                             } queryParams:params header:nil body:nil modelName:@"ESNotifiResp" successBlock:^(NSInteger requestId, ESNotifiResp * response) {
        [ESToast dismiss];
        if ([response isOK]) {
            weak_self.securityTokenResp = [ESNotifiSecurityTokenResp yy_modelWithJSON:response.results.data];
            [weak_self showHintText];
        } else {
            [weak_self showAlert:response.message handle:^{
                [weak_self reqNotifiMessage];
            }];
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
        [weak_self showAlert:[error errorMessage] handle:^{
            [weak_self reqNotifiMessage];
        }];
    }];
}

- (void)showAlert:(NSString *)msg handle:(void (^ __nullable)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"retry again", "是否重试？")
                                                                   message:msg ?: NSLocalizedString(@"request failed", "请求失败")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * sure = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
        if (handler) {
            handler();
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onSureBtn {
    [self onSureOrDeny:YES];
}

- (void)onCancelBtn {
    [self onSureOrDeny:NO];
}

- (void)onSureOrDeny:(BOOL)sure  {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:@(sure) forKey:@"accept"];
    params[@"securityToken"] = self.securityTokenResp.securityToken;
    params[@"clientUuid"] = self.securityTokenResp.authClientUUid;
    params[@"applyId"] = self.securityTokenResp.applyId;

    NSString * apiName = @"";
    if ([self.optType isEqualToString:ESSecurityPasswordModifyApply]) {
        apiName = security_passwd_modify_binder_accept;
    } else if ([self.optType isEqualToString:ESSecurityPasswordResetApply]) {
        apiName = security_passwd_reset_binder_accept;
    } else {
        ESDLog(@"[安保功能] 收到的被授权类型不匹配");
    }
    [ESNetworkRequestManager sendCallRequest:@{ServiceName : eulixspaceAccountService,
                                               ApiName : apiName
                                             } queryParams:params header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, ESBaseResp * response) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        long code = [error errorCode];
        NSString * text = [error errorMessage];
        if (code == 403) {
            [self showTimeoutHint];
            return;
        }
        
        [self showAlert:text handle:^{
            [self onSureOrDeny:sure];
        }];
    }];
}

- (void)showTimeoutHint {
    [ESToast toastError:NSLocalizedString(@"Verification timeout", "验证超时")];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onBackBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight);
        make.height.mas_equalTo(kNavBarHeight);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(kNavBarHeight);
        make.left.mas_equalTo(self.view).offset(20);
    }];
    
    [self.hintIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(118);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(120);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(38);
        make.right.mas_equalTo(self.view).offset(-38);
        make.top.mas_equalTo(self.hintIv.mas_bottom).offset(46);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(88);
        make.right.mas_equalTo(self.view).offset(-88);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight - 20);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(88);
        make.right.mas_equalTo(self.view).offset(-88);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.cancelBtn.mas_top).offset(-15);
    }];
}

- (UIImageView *)hintIv {
    if (!_hintIv) {
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"auth_pc"]];
        [self.view addSubview:iv];
        _hintIv = iv;
    }
    return _hintIv;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel * l = [[UILabel alloc] init];
        [self.view addSubview:l];
        l.textAlignment = NSTextAlignmentCenter;
        l.font = [UIFont pfMedium:18];
        l.textColor = [ESColor colorWithHex:0x333333];
        l.text = NSLocalizedString(@"Authentication", "身份验证");
        _titleLabel = l;
    }
    return _titleLabel;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        UILabel * l = [[UILabel alloc] init];
        [self.view addSubview:l];
        l.numberOfLines = 0;
        l.textAlignment = NSTextAlignmentCenter;
        l.font = [UIFont pfMedium:16];
        l.textColor = [ESColor colorWithHex:0x333333];
        
        _hintLabel = l;
    }
    return _hintLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"photo_back"] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(onBackBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _backBtn = btn;
    }
    return _backBtn;
}

- (ESGradientButton *)sureBtn {
    if (!_sureBtn) {
        ESGradientButton * btn = [[ESGradientButton alloc] init];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 10;
        [self.view addSubview:btn];
        [btn setTitle:NSLocalizedString(@"es_confirm_myself_operation", @"确认是我本人操作") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont pfMedium:16];
        [btn addTarget:self action:@selector(onSureBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _sureBtn = btn;
    }
    return _sureBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [self.view addSubview:btn];
        [btn setTitle:NSLocalizedString(@"es_not_myself_operation", @"不是我本人操作") forState:UIControlStateNormal];
        [btn setTitleColor:[ESColor colorWithHex:0x85899C] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont pfMedium:16];
        [btn addTarget:self action:@selector(onCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

@end
