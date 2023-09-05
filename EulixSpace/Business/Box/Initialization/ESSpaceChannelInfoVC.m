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
//  ESSpaceTunInfoVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceChannelInfoVC.h"
#import "ESBindResultViewController.h"
#import "ESBoxBindViewModel.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <YYModel/YYModel.h>
#import "ESCommListHeaderView.h"
#import "ESSpaceChannelInfoListModule.h"
#import "ESTitleDetailSwitchCell.h"
#import "ESSpaceInternetChannelCloseConfirmVC.h"
#import "ESCommonToolManager.h"
#import "ESBoxManager.h"
#import "UIView+Status.h"
#import "ESToast.h"
#import "ESNetworkRequestManager.h"
#import "ESDiskInitStartPage.h"
#import "NSError+ESTool.h"
#import "ESSapceWelcomeVC.h"
#import "ESPersonalSpaceInfoVC.h"
#import "ESDIDDocManager.h"
#import "ESLocalPath.h"

@interface ESSpaceChannelInfoVC ()  <ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESGradientButton *enterSpace;
@property (nonatomic, strong) ESSpaceInternetChannelCloseConfirmVC *confirmVC;
@property (nonatomic, strong) NSString * inputPlatformUrl;
@property (nonatomic, strong) ESDIDModel *didModel;

@end

@implementation ESSpaceChannelInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    ESCommListHeaderView *headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, [ESCommonToolManager isEnglish] ? 200 : 174)];
    headerView.iconImageView.image = [UIImage imageNamed:@"kj"];
    headerView.titleLabel.text = NSLocalizedString(@"binding_accesschannel", "空间访问通道");
    headerView.detailLabel.text = NSLocalizedString(@"binding_accessmethods", "多种可选访问方式，随时随地极速访问");
    
    self.listModule.listView.tableHeaderView = headerView;
    if (self.viewModel != nil) {
        self.isInternetOn = NO;
        [self.enterSpace setTitle:NSLocalizedString(@"box_bind_step_next", @"继续") forState:UIControlStateNormal];
        ESSpaceChannelInfoListModule * listModule = (ESSpaceChannelInfoListModule *)self.listModule;
        listModule.isBind = YES;
    }
    
    if (self.boxItem != nil) {
        self.isInternetOn = self.boxItem.enableInternetAccess;
        [self.enterSpace setTitle:NSLocalizedString(@"binding_save", @"保存") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSwitchPlatformSuccess) name:@"esSwitchPlatformUrlSuccessNoti" object:nil];
    }

    self.showBackBt = YES;
    self.viewModel.delegate = self;
    
    [self.listModule reloadData:[(ESSpaceChannelInfoListModule *)self.listModule defaultListData]];
    [self updateActionBtStatus];
}

- (void)onSwitchPlatformSuccess {
    weakfy(self)
    [[ESBoxManager manager] loadCurrentBoxOnlineState:^(BOOL offline) {
        weak_self.platformUrl = ESBoxManager.activeBox.platformUrl;
        [weak_self.listModule reloadData:[(ESSpaceChannelInfoListModule *)weak_self.listModule defaultListData]];
    }];
}

- (Class)listModuleClass {
    return [ESSpaceChannelInfoListModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (BOOL)isValidPlatformUrl:(NSString *)url {
    if (url.length == 0) {
        [ESToast toastWarning:NSLocalizedString(@"es_input_platform_address_please", @"请输入平台地址")];
        return NO;
    }
    if (![url hasPrefix:@"https://"]) {
        [ESToast toastWarning:NSLocalizedString(@"es_only_support_https", @"仅支持 https 协议")];
        return NO;
    }
    if ([NSURL URLWithString:url] == nil) {
        [ESToast toastWarning:NSLocalizedString(@"es_platform_address_non-compliance", @"平台地址不合规")];
        return NO;
    }
    
    return YES;
}

- (void)nextStep {
    //{
    //  "clientPhoneModel": "string",
    //  "clientUuid": "string",
    //  "enableInternetAccess": true,
    //  "password": "string",
    //  "spaceName": "string"
    //}
//    if (self.boxItem != nil && self.isInternetOn == self.boxItem.enableInternetAccess) {
//        return;
//    }
    
    id<ESTitleDetailSwitchListItemProtocol> cellModel = self.listModule.listData[1];
    NSString * platformUrl = cellModel.platformAddress;
    if (cellModel.isOn && ![self isValidPlatformUrl:platformUrl]) {
        return;
    }
    self.inputPlatformUrl = platformUrl;
    if (self.viewModel != nil) {
//        上述接口中的 deviceName 字段改成如下的 clientUUID 字段，由 clientUUID 进行 url 编码得到。前端根据 clientUuid 来从网关原有的接口中获取设备名称。 没有 clientUUID 字段的凭证前端根据 credentialType 字段来区分设备。
//        clientUUID=urlcode(1234-5678-0000-0000)
       self.didModel = [[ESDIDDocManager shareInstance] createClientRSADID];
        
        NSString *idtTemp = [[NSString alloc] initWithFormat:@"%@?clientUUID=%@&credentialType=binder", ESSafeString(self.didModel.clientDid), ESBoxManager.clientUUID.URLEncode];
        NSDictionary *req = @{@"clientPhoneModel" : ESSafeString([ESCommonToolManager judgeIphoneType:@""]),
                              @"clientUuid" : ESSafeString(ESBoxManager.clientUUID),
                              @"enableInternetAccess" : @(self.isInternetOn),
                              @"password" : ESSafeString(self.viewModel.securityPassword),
                              @"spaceName" : ESSafeString(self.viewModel.spaceName),
                              @"platformApiBase" : ESSafeString(platformUrl),
                              @"verificationMethod" : @[ @{@"id" : ESSafeString(idtTemp),
                                                           @"type" : @"RsaVerificationKey2018",
                                                           @"publicKeyPem": ESSafeString(self.didModel.clientPublicKey)
                              }],

        };
        
        [self.view showLoading:YES];
        [self.viewModel sendSpaceCreate:req];
        return;
    }
    
    if (self.boxItem != nil) {
        weakfy(self)
        [self.view showLoading:YES];
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-agent-service"
                                                        apiName:@"internet_service_config"
                                                    queryParams:@{}
                                                         header:@{}
                                                           body:@{@"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
                                                                  @"enableInternetAccess" : @(self.isInternetOn)
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
            strongfy(self)
            ESBoxManager.activeBox.enableInternetAccess = self.isInternetOn;
            ESInternetServiceConfigModel *config = [ESInternetServiceConfigModel yy_modelWithDictionary:response];
            if (config && config.userDomain.length > 0) {
                ESDLog(@"[internet_service_config] domain: %@", config.userDomain);
                ESBoxManager.activeBox.info.userDomain = config.userDomain;
            }
            
            [ESBoxManager.manager saveBox:ESBoxManager.activeBox];
            
            if (ESBoxManager.activeBox.enableInternetAccess) {
                [ESBoxManager.manager setAllBoxCookie];
            }
            [self.listModule.listData[1] setIsOn:self.isInternetOn];
            [self.listModule reloadData:[(ESSpaceChannelInfoListModule *)self.listModule defaultListData]];
            [self.view showLoading:NO];
            [ESToast toastSuccess:NSLocalizedString(@"security_authensetsuccess", @"设置成功")];
            [self updateActionBtStatus];
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self.view showLoading:NO];
            [self updateActionBtStatus];

            if ([[error codeString] isEqualToString:@"AG-560"]) {
                [self showAlertAndResetInternetSwitch];
                return;
            }
            if ([[error codeString] isEqualToString:@"AG-577"]) {
                [ESToast toastWarning:NSLocalizedString(@"es_platform_address_unavailable", @"空间平台不可用，请正确安装后重试")];
                return;
            }
            [ESToast toastError: self.isInternetOn ? NSLocalizedString(@"on_fail", @"开启失败") : NSLocalizedString(@"off_fail", @"关闭失败")];
        }];
    }
}

- (void)onBindCommand:(ESBCCommandType)command resp:(NSDictionary *)response {
    if (command == ESBCCommandTypeBindSpaceCreateReq) {
        [self.view showLoading:NO];
        if ([response[@"code"] isEqualToString:@"AG-200"]) {
            [ESToast toastSuccess:NSLocalizedString(@"security_authensetsuccess", @"设置成功")];
            NSString * btid = [self.viewModel getBtid];
            ESBoxItem *box = [ESBoxManager onJustParing:self.viewModel.boxInfo
                                              spaceName:self.viewModel.spaceName
                                   enableInternetAccess:self.viewModel.enableInternetAccess
                                               localHost:self.viewModel.localHost
                                                   btid:btid
                                             diskStatus:ESDiskInitStatusNotInit
                                                   init:self.viewModel.boxStatus.infoResult];
            box.platformUrl = self.inputPlatformUrl;
            [[ESDIDDocManager shareInstance] saveClientKey:self.didModel
                                                  password:self.viewModel.securityPassword
                                             paringBoxUUID:box.boxUUID
                                                paringType:ESBoxTypePairing];
            self.viewModel.paringBoxItem = box;
            if ([response[@"results"] isKindOfClass:[NSDictionary class]]) {
                NSString *base64DiDDoc = response[@"results"][@"didDoc"];
                [[ESDIDDocManager shareInstance] saveOrUpdateDIDDocBase64Str:base64DiDDoc
                                                        encryptedPriKeyBytes:response[@"results"][@"encryptedPriKeyBytes"]
                                                                         box:box];
            }

            if (self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport) {
                ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
                ctl.viewModel = self.viewModel;
                [self.navigationController pushViewController:ctl animated:YES];
                return;
            }
            //兼容一代盒子
            ESSapceWelcomeVC* ctl = [[ESSapceWelcomeVC alloc] init];
            ctl.viewModel = self.viewModel;
            ctl.paringBoxItem = box;
            [self.navigationController pushViewController:ctl animated:YES];
            return;
            
        }
        if ([response[@"code"] isEqualToString:@"AG-460"]) {
            [ESToast toastError:@"不要重复绑定"];
            return;
        }
        if ([response[@"code"] isEqualToString:@"AG-560"]) {
            [self showAlertAndResetInternetSwitch];
            return;
        }
        if ([response[@"code"] isEqualToString:@"AG-577"]) {
            [ESToast toastWarning:NSLocalizedString(@"es_platform_address_unavailable", @"空间平台不可用，请正确安装后重试")];
            return;
        }
        
        [ESToast toastError:@"绑定失败"];
    }
}

- (void)showAlertAndResetInternetSwitch {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", @"提示")
                                                                   message:NSLocalizedString(@"binding_UnableInternetchannel",@"无法开通互联网通道，请将傲空间设备\n连接至互联网后重试")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common_got_it",@"我知道了")
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *_Nonnull action) {
        self.isInternetOn = NO;
        [self.listModule.listData[1] setIsOn:NO];
//        [self.listModule.listData[2] setIsOn:NO];
        [self.listModule.listView reloadData];
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}

- (void)updateActionBtStatus {
//    if (self.boxItem != nil) {
//        [self.enterSpace userEnable:self.isInternetOn != self.boxItem.enableInternetAccess];
//    }
    
    id<ESTitleDetailSwitchListItemProtocol> cellModel = self.listModule.listData[1];
    NSString * platformUrl = cellModel.platformAddress;
    if (cellModel.isOn && platformUrl.length == 0) {
        self.enterSpace.enabled = NO;
    } else {
        self.enterSpace.enabled = YES;
    }
}

- (void)trySwitchNetworkTun:(ESTitleDetailSwitchCell *)switchView newValue:(BOOL)value {
    if (value == YES) {
        self.isInternetOn = value;
        [self.listModule.listData[1] setIsOn:value];
        [self.listModule.listView reloadData];
        [self updateActionBtStatus];
        return;
    }
    _confirmVC = [[ESSpaceInternetChannelCloseConfirmVC alloc] init];
    weakfy(self)
    _confirmVC.closeBlock = ^() {
        strongfy(self)
        [switchView setSwitchOn:NO];
        self.isInternetOn = NO;
        [self.listModule.listData[1] setIsOn:NO];
        [self.listModule.listView reloadData];
        [self updateActionBtStatus];
    };
    _confirmVC.cancelBlock = ^() {
        strongfy(self)
        [switchView setSwitchOn:YES];
        self.isInternetOn = YES;
        [self.listModule.listData[1] setIsOn:YES];
        [self.listModule.listView reloadData];
        [self updateActionBtStatus];
    };
    [_confirmVC show];
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

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 26, 0, 26);
}

@end
