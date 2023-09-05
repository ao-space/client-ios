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
//  ESBoxBindBleModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/19.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxBindBleModule.h"
#import "ESAES.h"
#import "ESApiCode.h"
#import "ESBluetoothCommunication.h"
#import "ESBluetoothManager.h"
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
#import "ESBoxBindViewModel.h"

static const CGFloat kESBoxBindSearchTimeout = 40;

@interface ESBoxBindViewModel ()

- (void)viewModelFound:(ESBluetoothItem *)bluetoothItem mdnsItem:(ESNetServiceItem *)mdnsItem channel:(ESBoxRespChannel)channel;
- (void)viewModelOnPubKeyExchange:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;
- (void)viewModelOnAESKeyExchange:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;

- (void)viewModelOnClose:(NSError *)error channel:(ESBoxRespChannel)channel;

//尝试使用配置的IP和端口交换公钥失败，设备不可达
- (void)viewModelLocalNetServiceNotReachable:(NSError *)error channel:(ESBoxRespChannel)channel;
- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;

- (void)viewModelOnWifiList:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;
- (void)viewModelOnWifiStatus:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;
- (void)viewModelOnPair:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;

- (void)viewModelOnSetAdminPwd:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;
- (void)viewModelOnInitial:(ESBoxStatusItem *)boxStatus channel:(ESBoxRespChannel)channel;
- (void)viewModelPassthrough:(NSDictionary *)rspDict channel:(ESBoxRespChannel)channel;

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelDiskInitializeProgress:(ESDiskInitializeProgressResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelDiskInitialize:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelSystemShutdown:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelDiskManagementList:(ESDiskManagementListResp *)response channel:(ESBoxRespChannel)channel;

- (void)viewModelUpdataNetworkConfig:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelGetNetworkConfig:(ESBoxNetworkConfigResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelIgnoreNetworkConfig:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelDeviceAbility:(ESDeviceAbilityResp *)response channel:(ESBoxRespChannel)channel;
- (void)viewModelUpdateDomin:(NSDictionary *)rspDict channel:(ESBoxRespChannel)channel;

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response channel:(ESBoxRespChannel)channel;

@end

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

@interface ESBluetoothCommunication ()

- (void)connection:(NSString *)serviceUUID name:(NSString *)name;

- (void)sendCommand:(ESBCCommandType)command payload:(NSDictionary *)payload;
- (void)sendCommand:(ESBCCommandType)command payloadStr:(NSString *)payloadStr;

@property (nonatomic, copy) ESBeforeParseJson beforeParseJson;

@end

@interface ESBoxBindBleModule () <ESBluetoothCommunicationDelegate>

@property (nonatomic, copy) NSString *serviceUUID;
@property (nonatomic, strong) ESBluetoothItem *bluetoothItem;

///通用
@property (nonatomic, assign) BOOL scaning;
@property (nonatomic, strong) NSTimer *timer;
// 蓝牙交互时的定时器
@property (nonatomic, strong) NSTimer *timerForBluetooth;

@property (nonatomic, strong) ESRSAPair *boxPair;
@property (nonatomic, copy) NSString *securityPassword;
@property (nonatomic, weak) UINavigationController *navigationController;

@end


@implementation ESBoxBindBleModule

+ (instancetype)viewModelWithDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate parentModule:(ESBoxBindViewModel *)parentModule {
    ESBoxBindBleModule *viewModel = [[ESBoxBindBleModule alloc] init];
    viewModel.delegate = delegate;
    viewModel.navigationController = delegate.navigationController;
    viewModel.parentModule = parentModule;
    return viewModel;
}

- (BOOL)viaBluetooth {
    return self.parentModule.mode == ESBoxBindModeBluetooth || self.parentModule.mode == ESBoxBindModeBluetoothAndWiredConnection;;
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kESBoxBindSearchTimeout target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void)startTimerForBluetooth:(NSTimeInterval)ti sel:(SEL)sel {
    if (ti <= 0 || ![self respondsToSelector:sel]) {
        return;
    }
    [self stopTimerForBluetooth];
    self.timerForBluetooth = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:sel userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stopTimerForBluetooth {
    if (self.timerForBluetooth) {
        [self.timerForBluetooth invalidate];
        self.timerForBluetooth = nil;
    }
}

- (void)timeout {
    self.scaning = NO;
    [self stopTimer];
    [self notifyBoxInfo];
    if (self.viaBluetooth) {
        ESDLog(@"[Bind] scan bluetooth timeout");
        [ESBluetoothCommunication.shared reset];
        return;
    }
}

- (void)onTimeoutForGetNetworkConfig {
    [self stopTimerForBluetooth];
    if (self.viaBluetooth) {
        ESDLog(@"[Bluetooth] onTimeoutForGetNetworkConfig");
        [ESBluetoothCommunication.shared resetForTimeout:ESBCCommandTypeGetNetworkConfigReq];
        ESBoxNetworkConfigResp * respModel = [[ESBoxNetworkConfigResp alloc] init];
        respModel.code = kESBluetoohTimeoutCode;
        [self onGetNetworkConfig:respModel];
    }
}

- (void)onTimeoutForConnectWifi {
    [self stopTimerForBluetooth];
    if (self.viaBluetooth) {
        ESDLog(@"[Bluetooth] onTimeoutForConnectWifi");
        [ESBluetoothCommunication.shared resetForTimeout:ESBCCommandTypeWifiPwdReq];
        ESRspWifiStatusRsp * respModel = [[ESRspWifiStatusRsp alloc] init];
        respModel.code = kESBluetoohTimeoutCode;
        [self onWifiStatus:respModel];
    }
}

- (void)onTimeoutForDeviceAbility {
    [self stopTimerForBluetooth];
    if (self.viaBluetooth) {
        ESDLog(@"[Bluetooth] onTimeoutForDeviceAbility");
        [ESBluetoothCommunication.shared resetForTimeout:ESBCCommandTypeDeviceAbilityReq];
        
        ESDeviceAbilityResp * respModel = [[ESDeviceAbilityResp alloc] init];
        respModel.code = kESBluetoohTimeoutCode;
        [self onDeviceAbility:respModel];
    }
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

- (void)searchWithUniqueId:(NSString *)uniqueId {
    [self reset];
    [ESBluetoothManager.manager isPoweredOn:^(BOOL on) {
        if (!on) {
            ESDLog(@"[Bluetooth] isPoweredOn not");
            return;
        }
        self.btid = uniqueId;
        self.serviceUUID = [self.btid uuidFrombtid];
    //    self.boxStatus = [ESBoxStatusItem new];
        ///eulixspace-%@
        NSString *localName = [NSString stringWithFormat:TEXT_BOX_BLUETOOTH_NAME_FORMAT, self.btid];
        if (self.viaBluetooth) {
            [ESBluetoothCommunication.shared reset];
            ESBluetoothCommunication.shared.delegate = self;
            self.scaning = YES;
            [ESBluetoothCommunication.shared connection:self.serviceUUID name:localName];
            [self startTimer];
            return;
        }
    }];
    
}

- (void)stopSearch {
    if (self.viaBluetooth) {
//        [ESBluetoothCommunication.shared reset];
        self.scaning = NO;
        [self stopTimer];
    }
}

- (void)pubKeyExchange {
    ESDLog(@"[Bluetooth] pubKeyExchange");
    // NSParameterAssert(self.delegate && self.navigationController);
    ESRSAPair *pair = self.pair;   //ESRSACenter.defaultPair;
    ESPubKeyExchangeReq *req = [ESPubKeyExchangeReq new];
    req.clientPubKey = pair.publicKey.pem;
#ifndef APPSTORE
    req.clientPriKey = pair.privateKey.pem;
#endif
    req.signedBtid = [pair sign:self.btid];
    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypePubKeyExchangeReq payload:req.toDictionary];
        return;
    }
}

- (void)aesKeyExchange {
    ESDLog(@"[Bluetooth] aesKeyExchange");

    // NSParameterAssert(self.delegate && self.navigationController);
//    NSString *clientPreSecret = [NSString randomKeyWithLength:32];
    NSString *encBtid = self.btid;
    ESKeyExchangeReq *req = [ESKeyExchangeReq new];
    req.clientPreSecret = [self.boxPair publicEncrypt:self.clientPreSecret];
    req.encBtid = encBtid;
    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeKeyExchangeReq payload:req.toDictionary];
        return;
    }
}

- (void)loadBoxStatus {
    ESDLog(@"[Bluetooth] loadBoxStatus");

    if (self.boxStatus.infoResult) {
        [self notifyBoxInfo];
        return;
    }
    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeInitReq payload:nil];
        return;
    }
    [self stopTimer];
}

- (void)loadWifiList {
    ESDLog(@"[Bluetooth] loadWifiList");

    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeWifiListReq payload:@{@"count": @(30)}];
        return;
    }
}

- (void)sendAddr:(NSString *)addr password:(NSString *)password {
    ESWifiPwdReq *req = [ESWifiPwdReq new];
    req.pwd = [self encrypt:password];
    req.addr = [self encrypt:addr];
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeWifiPwdReq payload:req.toDictionary];
        [self startTimerForBluetooth:120 sel:@selector(onTimeoutForConnectWifi)];
        return;
    }
}

- (void)revokeWithSecurityPassword:(NSString *)securityPassword {
    self.securityPassword = securityPassword;
    ESRevokReq *req = [ESRevokReq new];
    req.password = [self encrypt:securityPassword];
    req.clientUUID = [self encrypt: ESBoxManager.clientUUID];
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeRevokeReq payload:req.toDictionary];
        return;
    }
}

- (void)newRevokeWithSecurityPassword:(NSString *)securityPassword {
    self.securityPassword = securityPassword;
    NSDictionary *par = @{ @"password" : ESSafeString(securityPassword),
                           @"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
    };
    NSString * string = [par yy_modelToJSONString];
    ESDLog(@"[newRevokeWithSecurityPassword] 发送请求: %@", string);

    NSString * enJson = [self encrypt:string];
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeBindRevokeReq payloadStr:enJson];
        return;
    }
}

- (void)sendPassthrough:(NSString *)string {
    NSString * enJson = [self encrypt:string];
    if (self.viaBluetooth) {
        ESDLog(@"[安保功能] passthrough req by ble:%@", string);
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypePassthroughReq payloadStr:enJson];
        return;
    }
}


- (void)sendDiskRecognition {
    ESDLog(@"[系统启动] 发送磁盘识别请求");
    
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeDiskRecognitionReq payloadStr:@""];
        return;
    }
}

- (void)sendSpaceReadyCheck {
    ESDLog(@"[系统启动] 发送磁盘检测空间是否准备就绪的请求");

    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeSpaceReadyCheckReq payloadStr:@""];
        return;
    }
}

- (void)sendDiskInitialize:(ESDiskInitializeReq *)req {
    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[系统启动] 发送磁盘初始化请求: %@", string);

    NSString * enJson = [self encrypt:string];
    
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeDiskInitializeReq payloadStr:enJson];
        return;
    }
}

- (void)sendSystemShutdown {
    ESDLog(@"[系统启动] 发送关机请求");
    
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeSystemShutdownReq payloadStr:@""];
        return;
    }
}

- (void)sendNetworkIgnore:(NSString *)wifiName {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"wIFIName"] = wifiName;
    NSString * string = [params yy_modelToJSONString];
    NSString * enJson = [self encrypt:string];

    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeIgnoreNetworkConfigReq payloadStr:enJson];
        return;
    }
}

- (void)sendGetNetworkConfig {
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeGetNetworkConfigReq payloadStr:@""];
        [self startTimerForBluetooth:30 sel:@selector(onTimeoutForGetNetworkConfig)];
        return;
    }
}

- (void)sendDeviceAbility {
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeDeviceAbilityReq payloadStr:@""];
        [self startTimerForBluetooth:10 sel:@selector(onTimeoutForDeviceAbility)];
        return;
    }
}

- (void)sendUpdataNetworkConfig:(ESBoxNetworkConfigReq *)req {
    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[系统启动] 发送磁盘初始化请求: %@", string);

    NSString * enJson = [self encrypt:string];
    
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeUpdataNetworkConfigReq payloadStr:enJson];
        return;
    }
}


- (void)sendDiskInitializeProgress {
    ESDLog(@"[系统启动] 磁盘初始化的进度请求");

    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeDiskInitializeProgressReq payloadStr:@""];
        return;
    }
}

- (void)sendDiskManagementList {
    ESDLog(@"[系统启动] 磁盘管理列表");
    
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeDiskManagementListReq payloadStr:@""];
        return;
    }
}

- (void)sendV2Domin:(NSString *)string {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:[self encrypt:string] forKey:@"domain"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSTimeInterval time = [datenow timeIntervalSince1970] * 1000;
    long long int timeInt = time;
    NSString *currentTimeString = [NSString stringWithFormat:@"%lld",timeInt];
    [dic setValue:[self encrypt:currentTimeString] forKey:@"transId"];
    ESDLog(@"[V2社区版] transId:%@", currentTimeString);
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESSwithPlatformReq payload:dic];
        return;
    }
}

- (void)pairing {
    ESKeyExchangeRsp *keyExchangeRsp = self.boxStatus.keyExchangeRsp;
    NSParameterAssert(keyExchangeRsp.sharedSecret.length >= 0 && keyExchangeRsp.iv.length >= 0);
    if (keyExchangeRsp.sharedSecret.length == 0 || keyExchangeRsp.iv.length == 0) {
        return;
    }
    ESPairingReq *req = [ESPairingReq new];
    req.clientPhoneModel = [self encrypt:[ESCommonToolManager judgeIphoneType:@""]];
    req.clientUuid = [self encrypt:ESBoxManager.clientUUID];

    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypePairReq payload:req.toDictionary];
        return;
    }
}

- (void)setAdminPwd:(NSString *)pwd {
    self.securityPassword = pwd;
    ESPasswordInfo *passwordInfo = [ESPasswordInfo new];
    passwordInfo.password = [self encrypt:pwd];
    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeSetAdminPwdReq payload:passwordInfo.toDictionary];
        return;
    }
}

- (void)initial {
    ESPasswordInfo *passwordInfo = [ESPasswordInfo new];
    passwordInfo.password = [self encrypt:self.securityPassword];
    if (self.viaBluetooth) {
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeInitialReq payload:passwordInfo.toDictionary];
        return;
    }
}

- (void)sendSpaceStartInitialize  {
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeBindComStartReq payloadStr:@""];
        return;
    }
}

- (void)sendBindComProgress {
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeBindComProgressReq payloadStr:@""];
        return;
    }
}

- (void)sendSpaceCreate:(NSDictionary *)req {
    if (self.viaBluetooth) {
        ESBluetoothCommunication.shared.delegate = self;
        usleep(50 * 1000);
        NSString * string = [req yy_modelToJSONString];
        ESDLog(@"[sendSpaceCreate] 发送请求: %@", string);

        NSString * enJson = [self encrypt:string];
        [ESBluetoothCommunication.shared sendCommand:ESBCCommandTypeBindSpaceCreateReq payloadStr:enJson];
        return;
    }
}

#pragma mark - ESBluetoothCommunicationDelegate

- (void)onConnection:(ESBluetoothItem *)item {
    ESDLog(@"[Bind] bluetooth connected");
    self.bluetoothItem = item;
    if (item) {
        if (!self.boxStatus.pubKeyExchange) {
            [self pubKeyExchange];
            ESDLog(@"[Bind] start pubKeyExchange");
        }
    } else {
        if (self.scaning) {
            [self timeout];
        }
    }
}

- (void)onClose:(NSError *)error {
    ESDLog(@"[Bluetooth] onClose error: %@", error);

    self.bluetoothItem = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:ESBoxBindViewController.class]) {
            ESBoxBindViewController *next = (ESBoxBindViewController *)obj;
            self.delegate = (id)next;
            [self.navigationController popToViewController:next animated:NO];
            *stop = YES;
        }
    }];
    
    [self.parentModule viewModelOnClose:error channel:ESBoxRespChannelBle];
}

- (void)onPubKeyExchange:(ESRspPubKeyExchangeRsp *)response {
    ESDLog(@"[Bluetooth] onPubKeyExchange response: %@", response);

    self.boxStatus.pubKeyExchange = response.results;
    if (!self.boxStatus.pubKeyExchange.boxPubKey) {
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelBle];

        [self reset];
        return;
    }
    self.boxPair = [ESRSAPair pairWithPublicKey:[ESRSAPair keyFromPEM:self.boxStatus.pubKeyExchange.boxPubKey isPubkey:YES] privateKey:nil];
    ///验证签名
    if (![self.boxPair verifySignature:response.results.signedBtid plainText:self.btid]) {
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelBle];
        [self reset];
        return;
    }
    [self.parentModule viewModelOnPubKeyExchange:self.boxStatus channel:ESBoxRespChannelBle];
    [self aesKeyExchange];
}

- (void)onAESKeyExchange:(ESRspKeyExchangeRsp *)response {
    ESDLog(@"[Bluetooth] onAESKeyExchange response: %@", response);

    ESKeyExchangeRsp *results = response.results;
    ///异常数据
    if (results.sharedSecret.length == 0 || results.iv.length == 0) {
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelBle];

        [self reset];
        return;
    }
    ESRSAPair *pair = ESRSACenter.defaultPair;
    results.sharedSecret = [pair privateDecrypt:results.sharedSecret];
    results.iv = [pair privateDecrypt:results.iv];
    self.boxStatus.keyExchangeRsp = results;
    [self.parentModule viewModelOnAESKeyExchange:self.boxStatus channel:ESBoxRespChannelBle];

    [self addAOPToResponse];
    [self loadBoxStatus];
}

- (void)onInit:(ESBindInitResp *)response {
    ESDLog(@"[Bluetooth] onInit response: %@", response);

    self.boxStatus.infoResult = response.results;
    if (self.boxStatus.infoResult.boxName.length == 0) {
        self.boxStatus.infoResult.boxName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    }
    
    ESDLog(@"[Bind] get box info");
    [self stopTimer];
    self.scaning = NO;
    [self notifyBoxInfo];
}

- (void)onWifi:(ESRspWifiListRsp *)response {
    self.boxStatus.wifiResult = response.results;
    [self showWifiList];
}

- (void)onWifiStatus:(ESRspWifiStatusRsp *)response {
    [self stopTimerForBluetooth];
    self.boxStatus.wifiStatusResult = response.results;
    if (![response.code isEqual:@"AG-200"] && !response.results) {
        self.boxStatus.wifiStatusResult = [ESWifiStatusRsp new];
        self.boxStatus.wifiStatusResult.status = @(1);
    }
    [self.parentModule viewModelOnWifiStatus:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)onRevoke:(ESRspMicroServerRsp *)response {
    if ([response.results.results isKindOfClass:NSDictionary.class] || !response.results.results) {
        ESPasswdTryInfo *result = [[ESPasswdTryInfo alloc] initWithDictionary:(NSDictionary *)response.results.results error:nil];
        response.results.results = nil;
        ESResponseBasePasswdTryInfo *info = [[ESResponseBasePasswdTryInfo alloc] initWithDictionary:response.results.toDictionary error:nil];
        info.results = result;
        self.boxStatus.revokeResult = info;
    }
    [self.parentModule viewModelOnRevoke:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)onSetAdminPwd:(ESRspMicroServerRsp *)response {
    self.boxStatus.adminPwdResult = response.results;
    [self.parentModule viewModelOnSetAdminPwd:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)onPair:(ESRspMicroServerRsp *)response {
    ESDLog(@"[绑定流程] 配对结果msg: %@, %@, %@", response.message, response.results.message ,response.code);
    if ([response.results.results isKindOfClass:NSDictionary.class]) {
        ESAdminBindResult *result = [[ESAdminBindResult alloc] initWithDictionary:(NSDictionary *)response.results.results error:nil];
        self.boxStatus.pairResult = result;
        ESPairingBoxInfo *boxInfo = [[ESPairingBoxInfo alloc] initWithDictionary:result.toDictionary error:nil];
        boxInfo.boxPubKey = self.boxStatus.pubKeyExchange.boxPubKey;
        self.parentModule.boxInfo = boxInfo;
    }else{
        ESAdminBindResult *pairResult = [ESAdminBindResult new];
        pairResult.code =  response.code;
        self.boxStatus.pairResult = pairResult;
    }

    [self.parentModule viewModelOnPair:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)onInitial:(ESRspMicroServerRsp *)response {
    self.boxStatus.initialResult = response;
    [self.parentModule viewModelOnInitial:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)onPassthrough:(NSDictionary *)response {
    [self.parentModule viewModelPassthrough:response channel:ESBoxRespChannelBle];
}

- (void)onSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    [self.parentModule viewModelOnSpaceCheckReady:response channel:ESBoxRespChannelBle];
}

- (void)onDiskRecognition:(ESDiskRecognitionResp *)response {
    [self.parentModule viewModelDiskRecognition:response channel:ESBoxRespChannelBle];
}

- (void)onDiskInitializeProgress:(ESDiskInitializeProgressResp *)response {
    [self.parentModule viewModelDiskInitializeProgress:response channel:ESBoxRespChannelBle];
}

- (void)onDiskManagementList:(ESDiskManagementListResp *)response {
    [self.parentModule viewModelDiskManagementList:response channel:ESBoxRespChannelBle];
}

- (void)onDiskInitialize:(ESBaseResp *)response {
    [self.parentModule viewModelDiskInitialize:response channel:ESBoxRespChannelBle];
}

- (void)onSystemShutdown:(ESBaseResp *)response {
    [self.parentModule viewModelSystemShutdown:response channel:ESBoxRespChannelBle];
}

- (void)onUpdataNetworkConfig:(ESBaseResp *)response {
    [self.parentModule viewModelUpdataNetworkConfig:response channel:ESBoxRespChannelBle];

}

- (void)onGetNetworkConfig:(ESBoxNetworkConfigResp *)response {
    [self stopTimerForBluetooth];
    [self.parentModule viewModelGetNetworkConfig:response channel:ESBoxRespChannelBle];
}

- (void)onIgnoreNetworkConfig:(ESBaseResp *)response {
    [self.parentModule viewModelIgnoreNetworkConfig:response channel:ESBoxRespChannelBle];
}

- (void)onDeviceAbility:(ESDeviceAbilityResp *)response {
    [self stopTimerForBluetooth];
    [self.parentModule viewModelDeviceAbility:response channel:ESBoxRespChannelBle];
}

- (void)onDomin:(NSDictionary *)response {
   // v2 平台社区
    [self.parentModule viewModelUpdateDomin:response channel:ESBoxRespChannelBle];
}

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response {
    [self.parentModule onBindCommand:command resp:response channel:ESBoxRespChannelBle];
}

#pragma mark - AOP

- (void)addAOPToResponse {
    weakfy(self);
    ESBeforeParseJson aop = ^NSDictionary *(id result) {
        strongfy(self);
        if ([result isKindOfClass:NSData.class]) {
            result = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        }
        if (![result isKindOfClass:NSString.class]) {
            return result;
        }
        NSString *json = result;
        NSMutableDictionary *dict = [[json toJson] mutableCopy];
        NSString *base64Result = dict[@"results"];
        ///这个字段是 string类型, 是加密后的, 需要解密
        if ([base64Result isKindOfClass:[NSString class]]) {
            NSString *decryptString = [self decrypt:base64Result];
            if (decryptString.length > 0) {
                NSDictionary *realResults = [decryptString toJson];
                if (realResults) {
                    dict[@"results"] = realResults;
                }
            }
        }
        return dict;
    };

    ESBluetoothCommunication.shared.beforeParseJson = aop;
}

#pragma mark - AES

- (NSString *)encrypt:(NSString *)string {
    ESKeyExchangeRsp *keyExchangeRsp = self.boxStatus.keyExchangeRsp;
    if (keyExchangeRsp.sharedSecret.length == 0 || keyExchangeRsp.iv.length == 0 || !string) {
        return @"";
    }
    return [string aes_cbc_encryptWithKey:keyExchangeRsp.sharedSecret iv:keyExchangeRsp.iv];
}

- (NSString *)decrypt:(NSString *)string {
    ESKeyExchangeRsp *keyExchangeRsp = self.boxStatus.keyExchangeRsp;
    if (keyExchangeRsp.sharedSecret.length == 0 || keyExchangeRsp.iv.length == 0 || !string
        || [string isKindOfClass:NSNull.class]) {
        return @"";
    }
    return [string aes_cbc_decryptWithKey:keyExchangeRsp.sharedSecret iv:keyExchangeRsp.iv];
}

#pragma mark - call delegate

- (void)showWifiList {
    [self.parentModule viewModelOnWifiList:self.boxStatus channel:ESBoxRespChannelBle];
}

- (void)notifyBoxInfo {
    self.boxStatus.infoResult.network = self.boxStatus.infoResult.network ?: [NSMutableArray<ESNetwork> new];
    [self.parentModule viewModelOnInit:self.boxStatus channel:ESBoxRespChannelBle];

}

- (void)reset {
    self.bluetoothItem = nil;
    self.btid = nil;
    self.serviceUUID = nil;
    self.boxStatus = nil;
    self.boxPair = nil;
    [self stopTimer];
    [ESBluetoothCommunication.shared reset];
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
    if (!_boxStatus) {
        _boxStatus = [ESBoxStatusItem new];
    }
    return _boxStatus;
}

@end
