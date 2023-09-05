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
//  ESSecurityPasswordInputViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordInputViewController.h"
#import "ESBindResultViewController.h"
#import "ESToast.h"
#import "NSString+ESTool.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"
#import "ESAccountInfoStorage.h"
#import "ESAuthenticationTypeController.h"
#import "ESSpaceGatewayAdminAuthingServiceApi.h"
#import "ESBoxManager.h"
#import "ESRSACenter.h"
#import "ESCache.h"
#import "ESSecurityEmailMamager.h"
#import "ESAuthenticationApplyForNewDeviceController.h"
#import "ESVerifySecurityEmailForNewDeviceController.h"
#import "ESSecurityPasswordResetByEmailController.h"
#import "ESHardwareVerificationController.h"
#import "ESGatewayClient.h"
#import "ESSapceWelcomeVC.h"
#import "ESCommonToolManager.h"
#import "ESDiskInitProgressPage.h"
#import "ESDiskEmptyPage.h"
#import "ESDiskInitStartPage.h"
#import "ESDIDDocManager.h"
#import "NSError+ESTool.h"
#import "ESLocalPath.h"
#import "ESHardwareVerificationForDockerBoxController.h"

@interface ESSecurityPasswordInputViewController () <UITextFieldDelegate, ESBoxBindViewModelDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSTimeInterval failTimer;
@property (nonatomic, assign) NSInteger failCount;

@property (nonatomic, assign) BOOL isReceivedEmailInfo;
@property (nonatomic, strong) ESSecurityEmailModel * emailInfo;
@property (nonatomic, strong) ESDIDModel *didModel;

@end

@implementation ESSecurityPasswordInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_BOX_BIND_UNBIND;
    self.view.backgroundColor = UIColor.whiteColor;
    [self.pinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(26);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(50);
        make.height.mas_equalTo(56);
    }];
    [self.showPromptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pinCodeTextField.mas_bottom).inset(22);
        make.left.mas_equalTo(self.view).inset(44);
        make.height.width.mas_equalTo(14);
    }];
    if (self.type == ESSecurityPasswordTypeUnbind) {
        //解绑设备    base.unbindingDevices
        self.navigationItem.title = TEXT_BOX_BIND;
    }
    
    if (self.viewModel.boxStatus.infoResult.newBindProcessSupport) {
        self.navigationItem.title = NSLocalizedString(@"Secure Password Authentication", @"安全密码验证");
        self.titleLabel.text = NSLocalizedString(@"security_password_placeholder", @"请输入安全密码");
    }
    
    // 绑定端与授权端都可以忘记密码
    // 解绑后，手机就属于新手机了，再次绑定走新手机流程，可以显示这个入口 这个是第3阶段，但只能通过【密保邮箱】来重置
    if ([ESAccountInfoStorage isAdminOrAuthAccount] || self.viewModel.boxStatus.infoResult.oldBox) {
        [self.forgetPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view).offset(-42);
            make.centerY.mas_equalTo(self.showPromptButton);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.delegate = self;
    [self.pinCodeTextField becomeFirstResponder];
}

- (void)editingChanged:(UITextField *)sender {
    if (sender.text.length < 6) {
        return;
    }
    //解绑时, 直接调用解绑
    [self.view endEditing:YES];
    if (self.type == ESSecurityPasswordTypeUnbind) {
        if (self.viewModel.boxStatus.infoResult.newBindProcessSupport) {
            ESToast.info(TEXT_WAIT).delay(30).show();
            [self.viewModel newRevokeWithSecurityPassword:sender.text];
            self.viewModel.securityPassword = sender.text;
            sender.text = nil;
            sender.userInteractionEnabled = NO;
            return;
        }
        //老流程
        ESToast.info(TEXT_WAIT).delay(30).show();
        [self.viewModel revokeWithSecurityPassword:sender.text];
        sender.text = nil;
        sender.userInteractionEnabled = NO;
        return;
    }

    if (self.inputDone) {
        self.inputDone(sender.text);
    }
    
    if (self.type == ESSecurityPasswordTypeUnbindBox) {
        [self verifyUnbindPassword:sender.text];
        return;
    }
    [self goBack];
}

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response {
    if (command == ESBCCommandTypeBindSpaceCreateReq) {
        [ESToast dismiss];
        if ([response[@"code"] isEqualToString:@"AG-200"]) {
            NSString * btid = [self.viewModel getBtid];
            ESBoxItem *box = [ESBoxManager onJustParing:self.viewModel.boxInfo
                                              spaceName:self.viewModel.spaceName
                                   enableInternetAccess:self.viewModel.enableInternetAccess
                                              localHost:self.viewModel.localHost
                                                   btid:btid
                                             diskStatus:self.viewModel.diskInitialCode
                                                   init:self.viewModel.boxStatus.infoResult];
            self.viewModel.paringBoxItem = box;
            [[ESDIDDocManager shareInstance] saveClientKey:self.didModel
                                                  password:self.viewModel.securityPassword
                                             paringBoxUUID:box.boxUUID
                                                paringType:ESBoxTypePairing];
            ESDLog(@"[ESSecurityPasswordInputViewController] [ESBCCommandTypeBindSpaceCreateReq] %@", [self.viewModel.boxStatus.infoResult yy_modelToJSONString]);
            if ([response[@"results"] isKindOfClass:[NSDictionary class]]) {
                NSString *base64DiDDoc = response[@"results"][@"didDoc"];
                [[ESDIDDocManager shareInstance] saveOrUpdateDIDDocBase64Str:base64DiDDoc
                                                        encryptedPriKeyBytes:response[@"results"][@"encryptedPriKeyBytes"]
                                                                         box:box];
            }
       
            {
                if ( (self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport &&
                    self.viewModel.diskInitialCode == ESDiskInitStatusNormal) ||
                    (!self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport)   ) {
                    ESSapceWelcomeVC * ctl = [[ESSapceWelcomeVC alloc] init];
                    ctl.paringBoxItem = box;
                    [self.navigationController pushViewController:ctl animated:YES];
                } else {
                    ESToast.info(TEXT_WAIT).delay(30).show();
                    [self.viewModel sendSpaceReadyCheck];
                }
            }
            return;
        }
        [self.pinCodeTextField clearText];
        if ([response[@"code"] isEqualToString:@"AG-460"]) {
            [ESToast toastError:@"不要重复绑定"];
            return;
        }
        [ESToast toastError:@"绑定失败"];
    }
    
    if (command == ESBCCommandTypeBindRevokeReq) {
        if (![response isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *res = (NSDictionary *)response;
        if (![res.allKeys containsObject:@"results"] ||
            ![res[@"results"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
        if ([res[@"code"] isEqualToString:@"AG-200"]) {
            NSString *resultCode = res[@"results"][@"code"];
            if ([resultCode isEqualToString:@"ACC-463"]) {
                [ESToast dismiss];
                [self passwordError];
                return;
            }
            
            if ([resultCode isEqualToString:@"ACC-200"]) {
                self.viewModel.agentToken = res[@"results"][@"agentToken"];
                self.didModel = [[ESDIDDocManager shareInstance] getCacheClientDIDModelWithBoxUUId:self.viewModel.boxStatus.infoResult.boxUuid paringType:ESBoxTypePairing];
                ESDLog(@"[ESBCCommandTypeBindRevokeReq] self.didModel:%@", [self.didModel yy_modelToJSONString]);
                if (self.didModel == nil) {
                    self.didModel = [[ESDIDDocManager shareInstance] createClientRSADID];
                }
                NSString *idtTemp = [[NSString alloc] initWithFormat:@"%@?clientUUID=%@&credentialType=binder", ESSafeString(self.didModel.clientDid), ESBoxManager.clientUUID.URLEncode];

                NSDictionary *req = @{@"clientPhoneModel" : ESSafeString([ESCommonToolManager judgeIphoneType:@""]),
                                      @"clientUuid" : ESSafeString(ESBoxManager.clientUUID),
//                                      @"enableInternetAccess" : @(self.isInternetOn),
                                      @"password" : ESSafeString(self.viewModel.securityPassword),
//                                      @"spaceName" : ESSafeString(self.viewModel.spaceName),
                                      @"verificationMethod" : @[ @{@"id" : ESSafeString(idtTemp),
                                                                   @"type" : @"RsaVerificationKey2018",
                                                                   @"publicKeyPem": ESSafeString(self.didModel.clientPublicKey)                              }],
                };
                [self.viewModel sendSpaceCreate:req];
                return;
            }
            [ESToast dismiss];
            [ESToast toastError:@"绑定失败"];
        }
      }
}

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    ESDLog(@"[ESSecurityPasswordInputViewController] [ESSpaceReadyCheckResp] response:%@", [response yy_modelToJSONString]);

    if ([response isOK]) {
        ESSpaceReadyCheckResultModel * model = response.results;
        self.viewModel.diskInited = model.diskInitialCode == ESDiskInitStatusNormal;
        self.viewModel.diskInitialCode = model.diskInitialCode;
    } else {
        self.viewModel.diskInited = NO;
        self.viewModel.diskInitialCode = ESDiskInitStatusError;
    }
    [self.viewModel sendDiskRecognition];
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response {
    ESDLog(@"[ESSecurityPasswordInputViewController] [viewModelDiskRecognition] response:%@", [response yy_modelToJSONString]);

    [ESToast dismiss];
    if (![response isOK]) {
        NSString * text = NSLocalizedString(@"enter disk init failed", @"进入磁盘初始化流程失败");
        [ESToast toastError:text];
    }
        
    if (self.viewModel.diskInitialCode == ESDiskInitStatusNormal) {
        ESSapceWelcomeVC * ctl = [[ESSapceWelcomeVC alloc] init];
        ctl.paringBoxItem = self.viewModel.paringBoxItem;
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (self.viewModel.diskInitialCode == ESDiskInitStatusFormatting
               || self.viewModel.diskInitialCode == ESDiskInitStatusSynchronizingData) {
        ESDiskInitProgressPage * ctl = [[ESDiskInitProgressPage alloc] init];
        ctl.status = ESDeviceStartupStatusDiskIniting;
        ctl.viewModel = self.viewModel;
        ctl.diskListModel = response.results;
        [self.navigationController pushViewController:ctl animated:NO];
    } else {
        ESDiskListModel *diskModel = response.results;
        // 空磁盘
        if ([diskModel hasDisk:ESDiskStorage_Disk1] == NO &&
            [diskModel hasDisk:ESDiskStorage_Disk2] == NO &&
            [diskModel hasDisk:ESDiskStorage_SSD] == NO) {
            ESDiskEmptyPage * ctl = [[ESDiskEmptyPage alloc] init];
            ctl.viewModel = self.viewModel;
            ctl.diskListModel = response.results;
            [self.navigationController pushViewController:ctl animated:NO];
            return;
        }
        
        ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
        ctl.viewModel = self.viewModel;
        ctl.diskListModel = response.results;
        [self.navigationController pushViewController:ctl animated:NO];
    }
}

- (void)passwordError {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    self.errorLabel.hidden = NO;
    self.failCount++;
    if (self.failCount >= 3 &&
        self.failTimer > 0 &&
        (currentTime - self.failTimer) < 60) {
        self.failTimer = currentTime;
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        [self goBack];
        return;
    }
    self.errorLabel.text = [NSString stringWithFormat:@"密码错误，还剩下%lu次机会", MAX(3 - self.failCount, 1)];
    if (self.failCount == 1) {
        self.failTimer = [[NSDate date] timeIntervalSince1970];
    }
    
    [self.pinCodeTextField clearText];
    self.pinCodeTextField.userInteractionEnabled = YES;
    [self.pinCodeTextField becomeFirstResponder];
}

- (void)verifyUnbindPassword:(NSString *)password {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if ( self.failTimer > 0 &&
        (currentTime - self.failTimer) > 60 ) {
        self.failTimer = 0;
        self.failCount = 0;
    }
    
    ESBoxItem *box = ESBoxManager.activeBox;
    ESRSAPair *pair = [ESRSACenter boxPair:box.boxUUID];
    
    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
    apiClient.timeoutInterval = 120;
    
    ESSpaceGatewayAdminAuthingServiceApi *api = [[ESSpaceGatewayAdminAuthingServiceApi alloc] initWithApiClient:apiClient];

    [api setDefaultHeaderValue:@"clientUuid" forKey:ESBoxManager.clientUUID];
    ESRevokeClientInfo *info = [ESRevokeClientInfo new];
    info.encryptedAuthKey = [pair publicEncrypt:box.info.authKey];
    info.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    info.encryptedPasscode = [pair publicEncrypt:password];
    
    ESToast.showLoading(TEXT_WAIT, self.view);
    [api spaceV1ApiGatewayAuthRevokePostWithBody:info
                               completionHandler:^(ESResponseBaseRevokeClientResult *output, NSError *error) {
                       [ESToast dismiss];
   
        ESBindResultViewController *vc = [ESBindResultViewController new];
        if (error == nil && [output.code isEqual:@"GW-200"]) {
            vc.success = YES;
            vc.type = ESBindResultTypeRevokeViaGateway;
            [self.navigationController pushViewController:vc animated:YES];
            self.errorLabel.hidden = YES;
            self.failTimer = 0;
            self.failCount = 0;
            return;
        }
        
        if ([output.code isEqual:@"GW-406"]) {
            self.errorLabel.hidden = NO;
            self.failCount++;
            if (self.failCount >= 3 &&
                self.failTimer > 0 &&
                (currentTime - self.failTimer) < 60) {
                self.failTimer = currentTime;
                ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
                [self goBack];
                return;
            }
            self.errorLabel.text = [NSString stringWithFormat:@"密码错误，还剩下%lu次机会", MAX(3 - self.failCount, 1)];
            if (self.failCount == 1) {
                self.failTimer = [[NSDate date] timeIntervalSince1970];
            }
            
            [self.pinCodeTextField clearText];
        } else if ([output.code isEqualToString:@"GW-5005"]) {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        }else {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

- (void)onForgetPasswordBtn {
    NSString * key = [[NSString alloc] initWithFormat:@"ESNewDeviceApplyResetPs"];
    if ([[ESReTransmissionManager Instance] failedEventIsResume:key distance:60] == NO) {
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        return;
    }
    
    
    if (self.authType == ESAuthenticationTypeBinderResetPassword) {
        if (self.viewModel == nil) {
            self.viewModel = [[ESBoxBindViewModel alloc] init];
            self.viewModel.delegate = self;
        }
        
//        [self reqBtid];
        weakfy(self)
        ESHardwareVerificationForDockerBoxController * ctl = [[ESHardwareVerificationForDockerBoxController alloc] init];
        ctl.authType = self.authType;
//        ctl.applyRsp = self.applyRsp;
        ctl.searchedBlock = ^(ESAuthenticationType authType, ESBoxBindViewModel * _Nonnull viewModel, ESAuthApplyRsp * _Nonnull applyRsp) {
            [weak_self.navigationController popToViewController:weak_self animated:NO];

            ESSecurityPasswordResetController * ctl = [[ESSecurityPasswordResetController alloc] init];
            ctl.viewModel = viewModel;
            ctl.authType = self.authType;
            ctl.applyRsp = applyRsp;
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.navigationController pushViewController:ctl animated:YES];
        return;
    }
    
    if (self.isReceivedEmailInfo) {
        [self gotoApply];
        return;
    }
    
    
    if (self.authType == ESAuthenticationTypeNewDeviceResetPassword) {
        [self sendEmailInfoReq];
        return;
    }
}


- (void)reqBtid {
    weakfy(self);
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [ESNetworkRequestManager sendCallRequest:@{ServiceName : eulixspaceAccountService,
                                               ApiName : device_hardware_info
                                             } queryParams:nil header:nil body:nil modelName:@"ESBtidModel" successBlock:^(NSInteger requestId, ESBtidModel * response) {
        [ESToast dismiss];
        if (response.btid.length > 0) {
            ESHardwareVerificationController * ctl = [[ESHardwareVerificationController alloc] init];
//            ctl.applyRsp = weak_self.applyRsp;
            ctl.authType = weak_self.authType;
            ctl.btid = response.btid;
            [weak_self.navigationController pushViewController:ctl animated:YES];

            
            ctl.searchedBlock = ^(ESAuthenticationType authType, ESBoxBindViewModel * _Nonnull viewModel, ESAuthApplyRsp * _Nonnull applyRsp) {
                [weak_self.navigationController popToViewController:weak_self animated:NO];
                
                if (self.authType == ESAuthenticationTypeBinderResetPassword
                    || self.authType == ESAuthenticationTypeAutherResetPassword) {
                    ESSecurityPasswordResetController * ctl = [[ESSecurityPasswordResetController alloc] init];
                    ctl.authType = authType;
                    ctl.viewModel = viewModel;
                    ctl.applyRsp = applyRsp;
                    [weak_self.navigationController pushViewController:ctl animated:YES];
                }
//                else if (self.authType == ESAuthenticationTypeBinderSetEmail
//                           || self.authType == ESAuthenticationTypeBinderModifyEmail
//                           || self.authType == ESAuthenticationTypeAutherModifyEmail
//                           || self.authType == ESAuthenticationTypeAutherSetEmail) {
//                    ESBindSecurityEmailByHardwareController * ctl = [[ESBindSecurityEmailByHardwareController alloc] init];
//                    ctl.viewModel = viewModel;
//                    ctl.authType = authType;
//                    [weak_self.navigationController pushViewController:ctl animated:YES];
//                }
            };
            return;
        }

         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    }];
}

- (void)sendEmailInfoReq {
    ESPassthroughReq * req = [[ESPassthroughReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_email_setting_local;
    req.apiPath = api_security_email_setting_local;

    ESDLog(@"[安保功能] 通过硬件方式请求密保邮箱信息");
    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESDLog(@"[安保功能] 收到密保邮箱的回调:%@", rspDict);

    if (self.isReceivedEmailInfo) {
        return;
    }
    self.isReceivedEmailInfo = YES;
    
    if (rspDict && rspDict[@"results"] && [rspDict[@"results"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary * item = rspDict[@"results"];
        if (item && [item[@"results"] isKindOfClass:NSDictionary.class]) {
            NSDictionary * emailInfo = item[@"results"];
            self.emailInfo = [ESSecurityEmailModel.class yy_modelWithJSON:emailInfo];
        }
    }
    [self gotoApply];
}

- (void)gotoApply {
    weakfy(self);
    [ESAuthenticationApplyForNewDeviceController showAuthApplyView:self type:self.authType viewModel:self.viewModel email:self.emailInfo block:^(ESAuthApplyRsp * _Nonnull applyRsp) {
        if (applyRsp.accept) {
            [weak_self.navigationController popToViewController:weak_self animated:NO];
            [weak_self gotoVerifySecurityEmailForNewDevice:applyRsp email:self.emailInfo.emailAccount];
        }
    } cancel:^{
        
    }];
}

- (void)gotoVerifySecurityEmailForNewDevice:(ESAuthApplyRsp *)applyRsp email:(NSString *)email {
    weakfy(self);
    ESVerifySecurityEmailForNewDeviceController * ctl = [[ESVerifySecurityEmailForNewDeviceController alloc] init];
    ctl.oldEmailAccount = email;
    ctl.viewModel = self.viewModel;
    ctl.verifySecurityEmailBlock = ^(int code, NSString * _Nonnull expiredAt, NSString * _Nonnull securityToken) {
        [weak_self.navigationController popToViewController:weak_self animated:NO];
        if (code == 0) {
            ESSecurityPasswordResetByEmailController * ctl = [[ESSecurityPasswordResetByEmailController alloc] init];
            ctl.securityToken = securityToken;
            ctl.viewModel = weak_self.viewModel;
            ctl.authType = weak_self.authType;
            ctl.applyRsp = applyRsp;
            [weak_self.navigationController pushViewController:ctl animated:YES];
        } else if (code == 1) {
            ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        }
    };
    [weak_self.navigationController pushViewController:ctl animated:YES];
}


- (void)showPrompt {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_SECURITY_PASSWORD_PROMPT_TITLE
                                                                   message:TEXT_SECURITY_PASSWORD_PROMPT_DETAIL
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attributedMessage = [TEXT_SECURITY_PASSWORD_PROMPT_DETAIL es_toAttr:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName: ESColor.labelColor,
        NSParagraphStyleAttributeName: paragraphStyle,

    }];
    [alert setValue:attributedMessage forKey:@"attributedMessage"];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_GOT_IT
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus {
    self.pinCodeTextField.userInteractionEnabled = YES;
    [ESToast dismiss];
    ESPasswdTryInfo *results = boxStatus.revokeResult.results;
    ///解绑成功, 跳转设置 wifi 页面
    if (boxStatus.revokeResult.success) {
        [self nextStep];
        return;
    }
    if (results.leftTryTimes.integerValue == 0) {
        self.killWhenPushed = YES;
        ESBindResultViewController *next = [ESBindResultViewController new];
        next.type = ESBindResultTypeUnbind;
        next.success = NO;
        next.prompt = TEXT_SECURITY_PASSWORD_ERROR_AND_RETRY_LATER_PROMPT;
        next.viewModel = self.viewModel;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }
    self.errorLabel.hidden = NO;
    self.errorLabel.text = [NSString stringWithFormat:TEXT_BOX_UNBIND_PASSWORD_ERROR_PROMPT, boxStatus.revokeResult.results.leftTryTimes];
}

- (void)nextStep {
    
}

#pragma -mark viewmodel jump delegate
- (int)viewModelJump {
    return 1;
}

#pragma mark - Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ESViewBuilder.label(TEXT_SECURITY_PASSWORD_INPUT).fontSize(16).fontWeight(UIFontWeightMedium).textColor(ESColor.labelColor).build(self.view);
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).inset(66);
            make.left.right.mas_equalTo(self.view).inset(44);
            make.height.mas_equalTo(22);
        }];
    }
    return _titleLabel;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = ESViewBuilder.label(nil).fontSize(12).textColor(ESColor.redColor).build(self.view);
        [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(10);
            make.left.right.mas_equalTo(self.view).inset(44);
            make.height.mas_equalTo(17);
        }];
    }
    return _errorLabel;
}

- (ESPinCodeTextField *)pinCodeTextField {
    if (!_pinCodeTextField) {
        _pinCodeTextField = [ESPinCodeTextField new];
        _pinCodeTextField.digitsCount = 6;
        _pinCodeTextField.font = [UIFont systemFontOfSize:40 weight:(UIFontWeightMedium)];
        _pinCodeTextField.bordersSpacing = 18;
        _pinCodeTextField.borderHeight = 1;
        _pinCodeTextField.emptyDigitBorderColor = ESColor.labelColor;
        _pinCodeTextField.filledDigitBorderColor = ESColor.labelColor;
        _pinCodeTextField.secureTextEntry = YES;
        _pinCodeTextField.keyboardType = UIKeyboardTypePhonePad;
        [_pinCodeTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_pinCodeTextField];
    }
    return _pinCodeTextField;
}

- (UIButton *)showPromptButton {
    if (!_showPromptButton) {
        _showPromptButton = [UIButton new];
        [_showPromptButton setImage:IMAGE_FILE_BOTTOM_DETAILS forState:UIControlStateNormal];
        [_showPromptButton addTarget:self action:@selector(showPrompt) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_showPromptButton];
        UILabel *prompt = ESViewBuilder.label(TEXT_SECURITY_PASSWORD_INPUT_PROMPT).fontSize(14).textColor(ESColor.secondaryLabelColor).build(self.view);
        [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.pinCodeTextField.mas_bottom).inset(20);
            make.left.mas_equalTo(_showPromptButton.mas_right).inset(4);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(self.view.mas_right).inset(44);
        }];
    }
    return _showPromptButton;
}

- (UIButton *)forgetPasswordBtn {
    if (!_forgetPasswordBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setTitle:NSLocalizedString(@"Forgot password", @"忘记密码") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangRegular(14);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(onForgetPasswordBtn) forControlEvents:UIControlEventTouchUpInside];
        _forgetPasswordBtn = btn;
    }
    return _forgetPasswordBtn;
}

- (NSTimeInterval)failTimer {
   NSNumber *failTimerNumber = [[ESCache defaultCache] objectForKey:@"ESFailTimer"];
    if (failTimerNumber == nil) {
        return 0;
    }
    return [failTimerNumber doubleValue];
}

- (void)setFailTimer:(NSTimeInterval)failTimer {
    [[ESCache defaultCache] setObject:@(failTimer) forKey:@"ESFailTimer"];
}

- (NSInteger)failCount {
    NSNumber *failCount_ = [[ESCache defaultCache] objectForKey:@"ESFailCount"];
     if (failCount_ == nil) {
         return 0;
     }
     return [failCount_ intValue];
}

- (void)setFailCount:(NSInteger)failCount {
    if (failCount == 1) {
        weakfy(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            strongfy(self)
            if (self.isViewLoaded && self.view.window != nil) {
                self.errorLabel.hidden = YES;
            }
        });
    }
    [[ESCache defaultCache] setObject:@(failCount) forKey:@"ESFailCount"];
}

@end
