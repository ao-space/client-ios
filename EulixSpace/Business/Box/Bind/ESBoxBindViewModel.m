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
//  ESBoxBindViewModel.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindViewModel.h"
#import "ESAES.h"
#import "ESApiCode.h"
#import "ESBoxBindViewController.h"
#import "ESBoxManager.h"
#import "ESGatewayClient.h"
#import "ESNetServiceBrowser.h"
#import "ESRSACenter.h"
#import "ESThemeDefine.h"
#import "ESUtility.h"
#import "NSString+ESTool.h"
#import "ESCommonToolManager.h"
#import <YCEasyTool/YCProperty.h>
#import <YYModel/YYModel.h>
#import "ESNetworkRequestManager.h"
#import "NSError+ESTool.h"
#import "ESToast.h"
#import "ESServiceNameHeader.h"
#import "ESDiskRecognitionResp.h"
#import "ESToast.h"
#import "ESSetting8ackd00rItem.h"
#import "ESGatewayManager.h"
#import "ESBoxBindLocalNetworkModule.h"
#import "ESBoxBindBleModule.h"
#import "ESPairingBoxInfo.h"
#import "ESBoxIPModel.h"

static const CGFloat kESBoxBindSearchTimeout = 40;

@interface ESBoxStatusItem ()

@property (nonatomic, strong) ESBindInitResultModel *infoResult;

@property (nonatomic, strong) NSArray<ESWifiListRsp *> *wifiResult;

@property (nonatomic, strong) ESWifiStatusRsp *wifiStatusResult;

@property (nonatomic, strong) ESResponseBasePasswdTryInfo *revokeResult;

@property (nonatomic, strong) ESAdminBindResult *pairResult;

@property (nonatomic, strong) ESMicroServerRsp *adminPwdResult;

@property (nonatomic, strong) ESRspMicroServerRsp *initialResult;

@property (nonatomic, strong) ESKeyExchangeRsp *keyExchangeRsp;

@property (nonatomic, strong) ESPubKeyExchangeRsp *pubKeyExchange;

@end


@interface ESBoxBindViewModel ()

@property (nonatomic, strong) ESBoxBindLocalNetworkModule *localNetworkModule;
///MDNS
@property (nonatomic, strong) ESNetServiceBrowser *serviceBrowser;

@property (nonatomic, strong) ESNetServiceItem *mdnsItem;

@property (nonatomic, strong) ESBoxStatusItem *boxStatus;


//Bluetooth

@property (nonatomic, copy) NSString *serviceUUID;

@property (nonatomic, strong) ESBluetoothItem *bluetoothItem;

///通用
@property (nonatomic, assign) BOOL scaning;

@property (nonatomic, strong) NSTimer *timer;
// 蓝牙交互时的定时器
@property (nonatomic, strong) NSTimer * timerForBluetooth;

@property (nonatomic, copy) NSString *btid;

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation ESBoxBindViewModel

+ (instancetype)viewModelWithDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate {
    ESBoxBindViewModel *viewModel = [[ESBoxBindViewModel alloc] init];
    viewModel.delegate = delegate;
    viewModel.navigationController = delegate.navigationController;
    
    viewModel.localNetworkModule = [ESBoxBindLocalNetworkModule viewModelWithDelegate:delegate parentModule:viewModel];
    return viewModel;
}


- (BOOL)viaWiredConnection {
    return self.mode == ESBoxBindModeWiredConnection || self.mode == ESBoxBindModeBluetoothAndWiredConnection || self.mode == ESBoxBindModeWiredConnectionWithIp;
}

- (BOOL)viaBluetooth {
    return NO;
}

- (void)setDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate {
    _delegate = delegate;
    self.localNetworkModule.delegate = delegate;
}

- (NSInteger)getPairStatus {
    if (self.boxStatus && self.boxStatus.infoResult && self.boxStatus.infoResult.paired) {
        return self.boxStatus.infoResult.paired;
    }
    return -1;
}

- (NSString *)getBtid {
    return self.btid;
}

- (NSString *)localHost {
    if (_localHost.length > 0) {
        return _localHost;
    }
    return self.localNetworkModule.localHost;
}

- (void)searchWithUniqueId:(NSString *)uniqueId {
    ESDLog(@"[searchWithUniqueId] start with uuid : %@", uniqueId);

    [self reset];
    [self resetCurrentResponseChannel];
    
    self.btid = uniqueId;
    self.serviceUUID = [self.btid uuidFrombtid];
    
//    self.localNetworkModule.boxStatus = self.boxStatus;
//    self.bleModule.boxStatus = self.boxStatus;
    
    NSString *clientPreSecret = [NSString randomKeyWithLength:32];
    self.localNetworkModule.clientPreSecret = clientPreSecret;
    
    self.localNetworkModule.pair = ESRSACenter.defaultPair;
    
    //添加局域网扫描支持
    self.localNetworkModule.scanNetServiceInfo = self.scanNetServiceInfo;
    
    if (self.viaWiredConnection) {
        [self.localNetworkModule searchWithUniqueId:uniqueId];
    }
    
    return;
}

- (void)loadWifiList {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule loadWifiList];
    }
  
    return;
}

- (void)sendAddr:(NSString *)addr password:(NSString *)password {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendAddr:addr password:password];
    }
}

- (void)revokeWithSecurityPassword:(NSString *)securityPassword {
    [self resetCurrentResponseChannel];

    // NSParameterAssert(self.delegate && self.navigationController);
    self.securityPassword = securityPassword;
    if (self.viaWiredConnection) {
        [self.localNetworkModule revokeWithSecurityPassword:securityPassword];
    }
}

- (void)newRevokeWithSecurityPassword:(NSString *)securityPassword {
    [self resetCurrentResponseChannel];

    // NSParameterAssert(self.delegate && self.navigationController);
    self.securityPassword = securityPassword;
    if (self.viaWiredConnection) {
        [self.localNetworkModule newRevokeWithSecurityPassword:securityPassword];
    }
}

- (void)sendPassthrough:(NSString *)string {
    [self resetCurrentResponseChannel];

//    NSString * enJson = [self encrypt:string];
    if (self.viaWiredConnection) {
        [self.localNetworkModule sendPassthrough:string];
    }

    return;
}


- (void)sendDiskRecognition {
    [self resetCurrentResponseChannel];

    ESDLog(@"[系统启动] 发送磁盘识别请求");
    if (self.viaWiredConnection) {
        [self.localNetworkModule sendDiskRecognition];
    }

    return;
}

- (void)sendSpaceReadyCheck {
    [self resetCurrentResponseChannel];

    ESDLog(@"[系统启动] 发送磁盘检测空间是否准备就绪的请求");

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendSpaceReadyCheck];
    }

}

- (void)sendDiskInitialize:(ESDiskInitializeReq *)req {
    [self resetCurrentResponseChannel];

    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[系统启动] 发送磁盘初始化请求: %@", string);

//    NSString * enJson = [self encrypt:string];
    
    if (self.viaWiredConnection) {
        [self.localNetworkModule sendDiskInitialize:req];
    }
}

- (void)sendSystemShutdown {
    [self resetCurrentResponseChannel];

    ESDLog(@"[系统启动] 发送关机请求");
    
    if (self.viaWiredConnection) {
        [self.localNetworkModule sendSystemShutdown];
    }
}

- (void)sendNetworkIgnore:(NSString *)wifiName {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendNetworkIgnore:wifiName];
    }
}

- (void)sendGetNetworkConfig {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendGetNetworkConfig];
    }
}

- (void)sendDeviceAbility {
    [self resetCurrentResponseChannel];

 
    
    [self.localNetworkModule sendDeviceAbility];
}

- (void)sendUpdataNetworkConfig:(ESBoxNetworkConfigReq *)req {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendUpdataNetworkConfig:req];
    }
}


- (void)sendDiskInitializeProgress {
    [self resetCurrentResponseChannel];

    ESDLog(@"[系统启动] 磁盘初始化的进度请求");

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendDiskInitializeProgress];
    }
}

- (void)sendDiskManagementList {
    [self resetCurrentResponseChannel];

    ESDLog(@"[系统启动] 磁盘管理列表");
    if (self.viaWiredConnection) {
        [self.localNetworkModule sendDiskManagementList];
    }
}

- (void)sendV2Domin:(NSString *)string {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendV2Domin:string];
    }
}

- (void)pairing {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule pairing];
    }
}

- (void)setAdminPwd:(NSString *)pwd {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule setAdminPwd:pwd];
    }
}

- (void)initial {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule initial];
    }
}

- (void)sendSpaceStartInitialize {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendSpaceStartInitialize];
    }
}

- (void)sendBindComProgress {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendBindComProgress];
    }
}

- (void)sendSpaceCreate:(NSDictionary *)req {
    [self resetCurrentResponseChannel];

    if (self.viaWiredConnection) {
        [self.localNetworkModule sendSpaceCreate:req];
    }
}

#pragma mark - ESBluetoothCommunicationDelegate

- (void)reset {
    self.btid = nil;
    self.serviceUUID = nil;
    self.boxStatus = nil;
    self.boxInfo = nil;
    [self.localNetworkModule reset];
}

- (ESDiskInitializeReq *)diskInitializeReq {
    if (!_diskInitializeReq) {
        _diskInitializeReq = [[ESDiskInitializeReq alloc] init];
    }
    return _diskInitializeReq;
}

- (void)dealloc {
    [self reset];
}

#pragma mark - Lazy Load

- (ESBoxStatusItem *)boxStatus {
    if (self.mode == ESBoxBindModeBluetooth) {
        return nil;
    }
    if (self.mode == ESBoxBindModeWiredConnection || self.mode == ESBoxBindModeWiredConnectionWithIp) {
        return self.localNetworkModule.boxStatus;
    }
    
    if (self.mode == ESBoxBindModeBluetoothAndWiredConnection) {
        if (self.currentResponseChannel == ESBoxRespChannelBle) {
            return nil;
        } else if (self.currentResponseChannel == ESBoxRespChannelNetwork) {
            return self.localNetworkModule.boxStatus;
        }
        return nil;
    }
    return nil;
}

#pragma mark - Response

- (void)viewModelFound:(ESBluetoothItem *)bluetoothItem mdnsItem:(ESNetServiceItem *)mdnsItem channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];
    
}

- (void)viewModelOnPubKeyExchange:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];
    
    if ([self.delegate respondsToSelector:@selector(viewModelOnPubKeyExchange:)]) {
        [self.delegate viewModelOnPubKeyExchange:self.boxStatus];
    }
}

- (void)viewModelOnAESKeyExchange:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnAESKeyExchange:)]) {
        [self.delegate viewModelOnAESKeyExchange:self.boxStatus];
    }
}

- (void)viewModelOnClose:(NSError *)error channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnClose:)]) {
        [self.delegate viewModelOnClose:error];
    }
}

//尝试使用配置的IP和端口交换公钥失败，设备不可达
- (void)viewModelLocalNetServiceNotReachable:(NSError *)error channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelLocalNetServiceNotReachable:)]) {
        [self.delegate viewModelLocalNetServiceNotReachable:error];
    }
}

- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    ESDLog(@"[viewModelOnInit] ESBoxStatusItem.infoResult : %@ channel:%ld ", boxStatus.infoResult, channel);

    if (boxStatus.infoResult == nil) {
        ESDLog(@"[viewModelOnInit] channel  %ld 失败", channel);
        return;
    }
    
    ESDLog(@"[viewModelOnInit] bleModule stopSearch");

    self.supportNewBindProcess = boxStatus.infoResult.newBindProcessSupport;
    [self updateCurrentResponseChannel:channel];
    
    if ([self.delegate respondsToSelector:@selector(viewModelOnInit:)]) {
        [self.delegate viewModelOnInit:boxStatus];
    }
}

- (void)viewModelOnWifiList:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnWifiList:)]) {
        [self.delegate viewModelOnWifiList:boxStatus];
    }
}

- (void)viewModelOnWifiStatus:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnWifiStatus:)]) {
        [self.delegate viewModelOnWifiStatus:boxStatus];
    }
}

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnRevoke:)]) {
        [self.delegate viewModelOnRevoke:boxStatus];
    }
}

- (void)viewModelOnPair:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnPair:)]) {
        [self.delegate viewModelOnPair:boxStatus];
    }
}

- (void)viewModelOnSetAdminPwd:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnSetAdminPwd:)]) {
        [self.delegate viewModelOnSetAdminPwd:boxStatus];
    }
}

- (void)viewModelOnInitial:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnInitial:)]) {
        [self.delegate viewModelOnInitial:boxStatus];
    }
}

- (void)viewModelPassthrough:(NSDictionary *)rspDict channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelPassthrough:)]) {
        [self.delegate viewModelPassthrough:rspDict];
    }
}

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelOnSpaceCheckReady:)]) {
        [self.delegate viewModelOnSpaceCheckReady:response];
    }
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelDiskRecognition:)]) {
        [self.delegate viewModelDiskRecognition:response];
    }
}

- (void)viewModelDiskInitializeProgress:(ESDiskInitializeProgressResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelDiskInitializeProgress:)]) {
        [self.delegate viewModelDiskInitializeProgress:response];
    }
}

- (void)viewModelDiskInitialize:(ESBaseResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelDiskInitialize:)]) {
        [self.delegate viewModelDiskInitialize:response];
    }
}

- (void)viewModelSystemShutdown:(ESBaseResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelSystemShutdown:)]) {
        [self.delegate viewModelSystemShutdown:response];
    }
}

- (void)viewModelDiskManagementList:(ESDiskManagementListResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelDiskManagementList:)]) {
        [self.delegate viewModelDiskManagementList:response];
    }
}

- (void)viewModelUpdataNetworkConfig:(ESBaseResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelUpdataNetworkConfig:)]) {
        [self.delegate viewModelUpdataNetworkConfig:response];
    }
}

- (void)viewModelGetNetworkConfig:(ESBoxNetworkConfigResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelGetNetworkConfig:)]) {
        [self.delegate viewModelGetNetworkConfig:response];
    }
}

- (void)viewModelIgnoreNetworkConfig:(ESBaseResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelIgnoreNetworkConfig:)]) {
        [self.delegate viewModelIgnoreNetworkConfig:response];
    }
}

- (void)viewModelDeviceAbility:(ESDeviceAbilityResp *)response channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelDeviceAbility:)]) {
        [self.delegate viewModelDeviceAbility:response];
    }
}

- (void)viewModelUpdateDomin:(NSDictionary *)rspDict channel:(ESBoxRespChannel)channel {
    [self updateCurrentResponseChannel:channel];

    if ([self.delegate respondsToSelector:@selector(viewModelUpdateDomin:)]) {
        [self.delegate viewModelUpdateDomin:rspDict];
    }
}

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response channel:(ESBoxRespChannel)channel {
    ESDLog(@"[onBindCommand] ESBCCommandType : %ld response:%@  channel:%ld ", command, response, channel);

    [self updateCurrentResponseChannel:channel];

    if (command == ESBCCommandTypeBindSpaceCreateReq) {
        if ([response isKindOfClass:[NSDictionary class]]  ) {
            NSDictionary *res = (NSDictionary *)response;
            if ([res[@"code"] isEqual:@"AG-200"] && [res[@"results"][@"spaceUserInfo"] isKindOfClass:[NSDictionary class]]) {
                ESPairingBoxInfo *boxInfo = [[ESPairingBoxInfo alloc] initWithDictionary:res[@"results"][@"spaceUserInfo"][@"results"] error:nil];
                NSArray *ipModelList = res[@"results"][@"connectedNetwork"];
                boxInfo.boxPubKey = self.boxStatus.pubKeyExchange.boxPubKey;
                self.boxInfo = boxInfo;
                self.enableInternetAccess = [res[@"results"][@"enableInternetAccess"] boolValue];
                self.spaceName = boxInfo.spaceName;
                
                [ipModelList enumerateObjectsUsingBlock:^(NSDictionary  * _Nonnull ipModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([ipModel isKindOfClass:[NSDictionary class]] &&
//                        [ipModel[@"wire"] boolValue] &&
                        [ipModel.allKeys containsObject:@"ip"] &&
                        [ipModel.allKeys containsObject:@"port"]) {
                        self.localHost = [NSString stringWithFormat:@"http://%@:%@", ipModel[@"ip"], ipModel[@"port"]];
                    }
                }];
               
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
        [self.delegate onBindCommand:command resp:response];
    }
}

- (void)updateCurrentResponseChannel:(ESBoxRespChannel)currentResponseChannel {
    if (currentResponseChannel !=ESBoxRespChannelUnkown) {
        self.currentResponseChannel = currentResponseChannel;
    }
}

- (void)resetCurrentResponseChannel {
    self.currentResponseChannel = ESBoxRespChannelUnkown;
}
@end
