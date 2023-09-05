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
//  ESBoxBindLocalNetworkModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/19.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxBindLocalNetworkModule.h"
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


//- (void)onSpaceStartInitialize:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;
//- (void)onBindComProgress:(NSDictionary *)response channel:(ESBoxRespChannel)channel;
//- (void)onInternetServiceConfig:(ESBaseResp *)response channel:(ESBoxRespChannel)channel;

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

@interface ESBoxBindLocalNetworkModule ()

///MDNS
@property (nonatomic, strong) ESNetServiceBrowser *serviceBrowser;
@property (nonatomic, strong) ESNetServiceItem *mdnsItem;
@property (nonatomic, strong) ESApiClient *apiClient;

//Bluetooth

@property (nonatomic, copy) NSString *serviceUUID;

///通用
@property (nonatomic, assign) BOOL scaning;

@property (nonatomic, strong) NSTimer *timer;
// 蓝牙交互时的定时器
@property (nonatomic, strong) NSTimer * timerForBluetooth;

@property (nonatomic, strong) ESRSAPair *boxPair;

@property (nonatomic, copy) NSString *securityPassword;

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation ESBoxBindLocalNetworkModule

+ (instancetype)viewModelWithDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate parentModule:(ESBoxBindViewModel *)parentModule {
    ESBoxBindLocalNetworkModule *viewModel = [[ESBoxBindLocalNetworkModule alloc] init];
    viewModel.delegate = delegate;
    viewModel.navigationController = delegate.navigationController;
    viewModel.parentModule = parentModule;
    return viewModel;
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kESBoxBindSearchTimeout target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timeout {
    self.scaning = NO;
    [self stopTimer];
    [self notifyBoxInfo];
  
    ESDLog(@"[Bind] scan mdns timeout");
    [_serviceBrowser stopSearch];
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
    self.btid = uniqueId;
    self.serviceUUID = [self.btid uuidFrombtid];
    ///eulixspace-%@
    NSString *localName = [NSString stringWithFormat:TEXT_BOX_BLUETOOTH_NAME_FORMAT, self.btid];

    if (self.parentModule.mode == ESBoxBindModeWiredConnectionWithIp) {
        [self setupServiceBrowserWithScanNetServiceInfo];
        [self pubKeyExchange];
        [self startTimer];
        return;
    }
    ///MDNS
    ///hex(sha256("eulixspace-"+btid))[0:6]
    NSString *btidHash = [NSString stringWithFormat:TEXT_BOX_MDNS_NAME_FORMAT, [localName.SHA256 substringToIndex:6]];
    [self.serviceBrowser startSearch:kESBoxServiceType inDomain:@"" target:btidHash];
    [self startTimer];
}

- (void)setupServiceBrowserWithScanNetServiceInfo {
    _serviceBrowser = [ESNetServiceBrowser new];
    self.mdnsItem = self.scanNetServiceInfo;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d", self.mdnsItem.ipv4, self.mdnsItem.port]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:url];
    client.timeoutInterval = self.boxStatus.infoResult.initialEstimateTimeSec;;
    self.apiClient = client;
}

- (void)pubKeyExchange {
    // NSParameterAssert(self.delegate && self.navigationController);
    ESRSAPair *pair = ESRSACenter.defaultPair;
    ESPubKeyExchangeReq *req = [ESPubKeyExchangeReq new];
    req.clientPubKey = pair.publicKey.pem;
#ifndef APPSTORE
    req.clientPriKey = pair.privateKey.pem;
#endif
    req.signedBtid = [pair sign:self.btid];
  
    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api pubKeyExchangeWithPubKeyExchangeReq:req
                           completionHandler:^(ESRspPubKeyExchangeRsp *output, NSError *error) {
                            if ((error != nil || output.results.boxPubKey == nil) &&
                                self.parentModule.mode == ESBoxBindModeWiredConnectionWithIp ) {
                                // 设备无法连接
                                [self.parentModule viewModelLocalNetServiceNotReachable:error channel:ESBoxRespChannelNetwork];
                                return;
                            }
                               [self onPubKeyExchange:output];
                           }];
}

- (void)aesKeyExchange {
//    NSString *clientPreSecret = [NSString randomKeyWithLength:32];
    NSString *encBtid = self.btid;
    ESKeyExchangeReq *req = [ESKeyExchangeReq new];
    req.clientPreSecret = [self.boxPair publicEncrypt:self.clientPreSecret];
    req.encBtid = encBtid;
   
    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api keyExchangeWithKeyExchangeReq:req
                     completionHandler:^(ESRspKeyExchangeRsp *output, NSError *error) {
                         [self onAESKeyExchange:output];
                     }];
}

- (void)loadBoxStatus {
    if (self.boxStatus.infoResult) {
        [self notifyBoxInfo];
        return;
    }
  
    [self stopTimer];
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:@"/agent/v1/api/pair/init" method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, NSString * response) {
        
        NSString * encodeJson = [self decrypt:response];
        ESBindInitResultModel * tmpModel = [ESBindInitResultModel yy_modelWithJSON:encodeJson];
        if (tmpModel == nil) {
            self.mdnsItem = nil;
        }
    
        ESBindInitResp * respModel = [[ESBindInitResp alloc] init];
        respModel.code = @"AG-200";
        respModel.results = tmpModel;
        [self onInit:respModel];
        
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBindInitResp * respModel = [[ESBindInitResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];

        [self onInit:respModel];
    }];
}

- (void)loadWifiList {
    ///配对时, 需要使用 ip 访问
    if (self.apiClient) {
        ///正常情况通过网关走就好
        ESNetApi *api = [[ESNetApi alloc] initWithApiClient:self.apiClient];
        [api pairNetNetConfigWithCompletionHandler:^(ESRspWifiListRsp *output, NSError *error) {
            self.boxStatus.wifiResult = output.results;
            [self showWifiList];
        }];
        return;
    }
    
    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
    apiClient.timeoutInterval = 120;
    ESDeviceApi *api = [[ESDeviceApi alloc] initWithApiClient:apiClient];
    [api pairNetNetConfigDeviceWithCompletionHandler:^(ESRspWifiListRsp *output, NSError *error) {
        self.boxStatus.wifiResult = output.results;
        [self showWifiList];
    }];
}

- (void)sendAddr:(NSString *)addr password:(NSString *)password {
    // NSParameterAssert(self.delegate && self.navigationController);
    ESWifiPwdReq *req = [ESWifiPwdReq new];
    req.pwd = [self encrypt:password];
    req.addr = [self encrypt:addr];
 
    if (self.apiClient) {
        ESNetApi *api = [[ESNetApi alloc] initWithApiClient:self.apiClient];
        [api pairNetNetConfigSettingWithReq:req
                          completionHandler:^(ESRspWifiStatusRsp *output, NSError *error) {
                              [self onWifiStatus:output];
                          }];
        return;
    }

    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
    req.pwd = password;
    req.addr = addr;
    apiClient.timeoutInterval = 120;
    ESDeviceApi *api = [[ESDeviceApi alloc] initWithApiClient:apiClient];
    [api pairNetNetConfigSettingDeviceWithReq:req
                            completionHandler:^(ESRspWifiStatusRsp *output, NSError *error) {
                                [self onWifiStatus:output];
                            }];
}

- (void)revokeWithSecurityPassword:(NSString *)securityPassword {
    // NSParameterAssert(self.delegate && self.navigationController);
    self.securityPassword = securityPassword;
    ESRevokReq *req = [ESRevokReq new];
    req.password = [self encrypt:securityPassword];
    req.clientUUID = [self encrypt: ESBoxManager.clientUUID];
  
    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api pairAdminRevokeWithRevokReq:req
                   completionHandler:^(id output, NSError *error) {
                       [self onRevoke:output];
                   }];
}

- (void)newRevokeWithSecurityPassword:(NSString *)securityPassword {
    self.securityPassword = securityPassword;
    NSDictionary *par = @{ @"password" : ESSafeString(securityPassword),
                           @"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
    };
    NSString *bodyStr = [par yy_modelToJSONString];
    NSString *body = [self encrypt:bodyStr];
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:@"/agent/v1/api/bind/revoke"
                                  method:@"POST"
                             queryParams:nil
                                  header:nil
                                    body:@{@"body" : ESSafeString(body)
                                         }
                               modelName:nil
                            successBlock:^(NSInteger requestId, NSString * response) {
        NSString * encodeJson = [self decrypt:response];
        NSData * jsonData = [encodeJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = @"AG-200";
        rspDict[@"results"] = dict;
        [self onBindCommand:ESBCCommandTypeBindRevokeReq resp:rspDict];

        ESDLog(@"[newRevoke]  rsp :%@", response);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = error.userInfo[@"code"];
        rspDict[@"message"] = error.userInfo[@"message"];
        [self onBindCommand:ESBCCommandTypeBindRevokeReq resp:rspDict];
        ESDLog(@"[newRevoke]  rsp :%@", error);
    }];
}

- (void)sendPassthrough:(NSString *)string {
    NSString * enJson = [self encrypt:string];
    ESDLog(@"[安保功能] passthrough req by lan:%@", string);
    
    NSDictionary * payload = @{@"body": enJson};
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_PASSTHROUGH method:@"POST" queryParams:nil header:nil body:payload modelName:nil successBlock:^(NSInteger requestId, NSString * response) {
        NSString * encodeJson = [self decrypt:response];
        NSData * jsonData = [encodeJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = @"AG-200";
        rspDict[@"results"] = dict;
        [self onPassthrough:rspDict];
        ESDLog(@"[安保功能] passthrough rsp by lan:%@", response);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = error.userInfo[@"code"];
        rspDict[@"message"] = error.userInfo[@"message"];
        [self onPassthrough:rspDict];
        ESDLog(@"[安保功能] passthrough rsp by lan:%@", error);
    }];
}


- (void)sendDiskRecognition {
    ESDLog(@"[系统启动] 发送磁盘识别请求");
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_DISK_RECOGNITION method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, NSString * response) {
        
        NSString * encodeJson = [self decrypt:response];
        ESDiskListModel * tmpModel = [ESDiskListModel yy_modelWithJSON:encodeJson];
        
        ESDiskRecognitionResp * respModel = [[ESDiskRecognitionResp alloc] init];
        respModel.code = @"AG-200";
        respModel.results = tmpModel;
        [self onDiskRecognition:respModel];
        
        ESDLog(@"[系统启动] 发送磁盘识别请求-成功 rsp by lan:%@", encodeJson);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDiskRecognitionResp * respModel = [[ESDiskRecognitionResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onDiskRecognition:respModel];
        
        ESDLog(@"[系统启动] 发送磁盘识别请求-失败 rsp by lan:%@", error);
    }];
}

- (void)sendSpaceReadyCheck {
    ESDLog(@"[系统启动] 发送磁盘检测空间是否准备就绪的请求");
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_SPACE_READY_CHECK method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
        
        NSString * encodeJson = [self decrypt:response];
        ESSpaceReadyCheckResultModel * resultModel = [ESSpaceReadyCheckResultModel.class yy_modelWithJSON:encodeJson];
        
        ESSpaceReadyCheckResp * respModel = [[ESSpaceReadyCheckResp alloc] init];
        respModel.code = @"AG-200";
        respModel.results = resultModel;
        [self onSpaceCheckReady:respModel];
        ESDLog(@"[系统启动] 发送磁盘检测空间是否准备就绪的请求-成功 rsp by lan:%@", encodeJson);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESSpaceReadyCheckResp * respModel = [[ESSpaceReadyCheckResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onSpaceCheckReady:respModel];
        
        ESDLog(@"[系统启动] 发送磁盘检测空间是否准备就绪的请求-失败 rsp by lan:%@", error);
    }];
}

- (void)sendDiskInitialize:(ESDiskInitializeReq *)req {
    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[系统启动] 发送磁盘初始化请求: %@", string);

    NSString * enJson = [self encrypt:string];
    NSDictionary * payload = @{@"body": enJson};
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_DISK_INITIALIZE method:@"POST" queryParams:nil header:nil body:payload modelName:nil successBlock:^(NSInteger requestId, id response) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = @"AG-200";
        
        [self onDiskInitialize:respModel];
        ESDLog(@"[系统启动] 磁盘初始化请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onDiskInitialize:respModel];
        
        ESDLog(@"[系统启动] 磁盘初始化请求-失败:%@", error);
    }];
}

- (void)sendSystemShutdown {
    ESDLog(@"[系统启动] 发送关机请求");
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_SYSTEM_SHUTDOWN method:@"POST" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = @"AG-200";
        
        [self onSystemShutdown:respModel];
        ESDLog(@"[系统启动] 发送关机请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onSystemShutdown:respModel];
        
        ESDLog(@"[系统启动] 发送关机请求-失败:%@", error);
    }];
}

- (void)sendNetworkIgnore:(NSString *)wifiName {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"wIFIName"] = wifiName;
    NSString * string = [params yy_modelToJSONString];
    NSString * enJson = [self encrypt:string];

    if (self.apiClient) {
        NSDictionary * payload = @{@"body": enJson};
        [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_NETWORK_IGNORE method:@"POST" queryParams:nil header:nil body:payload modelName:nil successBlock:^(NSInteger requestId, id response) {
            ESBaseResp * respModel = [[ESBaseResp alloc] init];
            respModel.code = @"AG-200";
            
            [self onIgnoreNetworkConfig:respModel];
            ESDLog(@"[网络设置] sendNetworkIgnore by lan-成功");
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ESBaseResp * respModel = [[ESBaseResp alloc] init];
            respModel.code = error.userInfo[@"code"];
            respModel.message = error.userInfo[@"message"];
            [self onIgnoreNetworkConfig:respModel];
            
            ESDLog(@"[网络设置] sendNetworkIgnore by lan-失败:%@", error);
        }];
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:network_ignore queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = @"AG-200";
        
        [self onIgnoreNetworkConfig:respModel];
        ESDLog(@"[网络设置] sendNetworkIgnore-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onIgnoreNetworkConfig:respModel];
        
        ESDLog(@"[网络设置] sendNetworkIgnore-失败:%@", error);
    }];
}

- (void)sendGetNetworkConfig {
    if (self.apiClient) {
        [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_NETWORK_CONFIG method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
            ESBoxNetworkConfigResp * respModel = [[ESBoxNetworkConfigResp alloc] init];
            respModel.code = @"AG-200";
            NSString * encodeJson = [self decrypt:response];
            respModel.results = [ESBoxNetworkStatusModel.class yy_modelWithJSON:encodeJson];
            
            [self onGetNetworkConfig:respModel];
            ESDLog(@"[网络设置] sendGetNetworkConfig by lan-成功");
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ESBoxNetworkConfigResp * respModel = [[ESBoxNetworkConfigResp alloc] init];
            respModel.code = error.userInfo[@"code"];
            respModel.message = error.userInfo[@"message"];
            [self onGetNetworkConfig:respModel];
            
            ESDLog(@"[网络设置] sendGetNetworkConfig by lan-失败:%@", error);
        }];
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:network_config queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESBoxNetworkConfigResp * respModel = [[ESBoxNetworkConfigResp alloc] init];
        respModel.code = @"AG-200";
        respModel.results = [ESBoxNetworkStatusModel.class yy_modelWithJSON:response];
        
        [self onGetNetworkConfig:respModel];
        ESDLog(@"[网络设置] sendNetworkIgnore-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBoxNetworkConfigResp * respModel = [[ESBoxNetworkConfigResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onGetNetworkConfig:respModel];
        
        ESDLog(@"[网络设置] sendNetworkIgnore-失败:%@", error);
    }];
}

- (void)sendDeviceAbility {
    if (self.apiClient) {
        [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_DEVICE_ABILITY method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
            ESDeviceAbilityResp * respModel = [[ESDeviceAbilityResp alloc] init];
            respModel.code = @"AG-200";
            NSString * encodeJson = [self decrypt:response];
    
            respModel.results = [ESDeviceAbilityModel.class yy_modelWithJSON:encodeJson];;
            
            [self onDeviceAbility:respModel];
            ESDLog(@"[设备信息] sendDeviceAbility by lan-成功");
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ESDeviceAbilityResp * respModel = [[ESDeviceAbilityResp alloc] init];
            respModel.code = error.userInfo[@"code"];
            respModel.message = error.userInfo[@"message"];
            [self onDeviceAbility:respModel];
            
            ESDLog(@"[设备信息] sendDeviceAbility by lan-失败:%@", error);
        }];
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:device_ability queryParams:nil header:nil body:nil modelName:@"ESDeviceAbilityModel" successBlock:^(NSInteger requestId, ESDeviceAbilityModel * response) {
        ESDeviceAbilityResp * respModel = [[ESDeviceAbilityResp alloc] init];
        respModel.code = @"AG-200";
        respModel.results = response;
        
        [self onDeviceAbility:respModel];
        ESDLog(@"[设备信息] sendDeviceAbility by call -成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDeviceAbilityResp * respModel = [[ESDeviceAbilityResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onDeviceAbility:respModel];
        
        ESDLog(@"[设备信息] sendDeviceAbility by call -失败:%@", error);
    }];
}

- (void)sendUpdataNetworkConfig:(ESBoxNetworkConfigReq *)req {
    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[系统启动] 发送磁盘初始化请求: %@", string);

    NSString * enJson = [self encrypt:string];
    
    NSDictionary * payload = @{@"body": enJson};
    if (self.apiClient) {
        [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_NETWORK_CONFIG_POST method:@"POST" queryParams:nil header:nil body:payload modelName:nil successBlock:^(NSInteger requestId, id response) {
            ESBaseResp * respModel = [[ESBaseResp alloc] init];
            respModel.code = @"AG-200";
            
            [self onUpdataNetworkConfig:respModel];
            ESDLog(@"[网络设置] sendUpdataNetworkConfig-成功");
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ESBaseResp * respModel = [[ESBaseResp alloc] init];
            respModel.code = error.userInfo[@"code"];
            respModel.message = error.userInfo[@"message"];
            [self onUpdataNetworkConfig:respModel];
            
            ESDLog(@"[网络设置] sendUpdataNetworkConfig-失败:%@", error);
        }];
        return;
    }
    NSDictionary * params = [req yy_modelToJSONObject];
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:network_config_update queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = @"AG-200";
        
        [self onUpdataNetworkConfig:respModel];
        ESDLog(@"[网络设置] sendUpdataNetworkConfig-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onUpdataNetworkConfig:respModel];
        
        ESDLog(@"[网络设置] sendUpdataNetworkConfig-失败:%@", error);
    }];
}


- (void)sendDiskInitializeProgress {
    ESDLog(@"[系统启动] 磁盘初始化的进度请求");

    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_DISK_INITIALIZE_PROGRESS method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
        
        ESDiskInitializeProgressResp * respModel = [[ESDiskInitializeProgressResp alloc] init];
        NSString * encodeJson = [self decrypt:response];
        respModel.results = [ESDiskInitializeProgressModel.class yy_modelWithJSON:encodeJson];
        respModel.code = @"AG-200";
        
        [self onDiskInitializeProgress:respModel];
        ESDLog(@"[系统启动] 磁盘初始化的进度请求-成功 rsp by lan:%@", encodeJson);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDiskInitializeProgressResp * respModel = [[ESDiskInitializeProgressResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onDiskInitializeProgress:respModel];
        
        ESDLog(@"[系统启动] 磁盘初始化的进度请求-失败 rsp by lan:%@", error);
    }];
}

- (void)sendDiskManagementList {
    ESDLog(@"[系统启动] 磁盘管理列表");
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:AGENT_V1_API_DISK_MANAGEMENT_LIST method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
        
        ESDiskManagementListResp * respModel = [[ESDiskManagementListResp alloc] init];
        NSString * encodeJson = [self decrypt:response];
        respModel.results = [ESDiskManagementModel.class yy_modelWithJSON:encodeJson];
        respModel.code = @"AG-200";
        
        [self onDiskManagementList:respModel];
        ESDLog(@"[系统启动] 磁盘管理列表-成功 rsp by lan:%@", encodeJson);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDiskManagementListResp * respModel = [[ESDiskManagementListResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onDiskManagementList:respModel];
        
        ESDLog(@"[系统启动] 磁盘管理列表-失败 rsp by lan:%@", error);
    }];
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

    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString path:@"/agent/v1/api/switch" method:@"POST" queryParams:nil header:nil body: dic modelName:nil successBlock:^(NSInteger requestId, NSString * response) {
        NSString * encodeJson = [self decrypt:response];
        NSData * jsonData = [encodeJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = @"AG-200";
        rspDict[@"results"] = dict;
        [self onDomin:rspDict];
    
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = error.userInfo[@"code"];
        rspDict[@"message"] = error.userInfo[@"message"];
        [self onDomin:rspDict];
    }];
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

    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api pairingWithPairingBoxInfo:req
                 completionHandler:^(ESRspMicroServerRsp *output, NSError *error) {
            [self onPair:output];
    }];
}

- (void)setAdminPwd:(NSString *)pwd {
    self.securityPassword = pwd;
    ESPasswordInfo *passwordInfo = [ESPasswordInfo new];
    passwordInfo.password = [self encrypt:pwd];
   
    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api setpasswordWithPasswordInfo:passwordInfo
                   completionHandler:^(ESRspMicroServerRsp *output, NSError *error) {
                       [self onSetAdminPwd:output];
                   }];
}

- (void)initial {
    ESPasswordInfo *passwordInfo = [ESPasswordInfo new];
    passwordInfo.password = [self encrypt:self.securityPassword];
    ESPairApi *api = [[ESPairApi alloc] initWithApiClient:self.apiClient];
    [api initialWithPasswordInfo:passwordInfo
               completionHandler:^(ESRspMicroServerRsp *output, NSError *error) {
                   [self onInitial:output];
               }];
}

//APP 调用开始绑定接口后 system-agent 开始启动各个微服务容器。
// code=AG-200 成功; code=AG-460 已经绑定; code=AG-470 容器启动中; code=AG-471 容器已经启动;
- (void)sendSpaceStartInitialize {
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString
                                    path:@"/agent/v1/api/bind/com/start"
                                  method:@"POST"
                             queryParams:nil
                                  header:nil
                                    body:nil
                               modelName:nil
                            successBlock:^(NSInteger requestId, id response) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = @"AG-200";
        
        [self onBindCommand:ESBCCommandTypeBindComStartReq resp:respModel];
        ESDLog(@"[启动各个微服务容器] 初始化请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESBaseResp * respModel = [[ESBaseResp alloc] init];
        respModel.code = error.userInfo[@"code"];
        respModel.message = error.userInfo[@"message"];
        [self onBindCommand:ESBCCommandTypeBindComStartReq resp:respModel];

        ESDLog(@"[启动各个微服务容器] 初始化请求-失败:%@", error);
    }];
}

    
- (void)sendBindComProgress {
//    code=AG-200 成功; code=AG-460 已经绑定;
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString
                                    path:@"/agent/v1/api/bind/com/progress"
                                  method:@"GET"
                             queryParams:nil
                                  header:nil
                                    body:nil
                               modelName:nil
                            successBlock:^(NSInteger requestId, NSString *response) {
        NSString * encodeJson = [self decrypt:response];
        NSData * jsonData = [encodeJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = @"AG-200";
        rspDict[@"results"] = dict;
       
        [self onBindCommand:ESBCCommandTypeBindComProgressReq resp:rspDict];
        ESDLog(@"[查询进度] 请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = error.userInfo[@"code"];
        rspDict[@"message"] = error.userInfo[@"message"];
        [self onBindCommand:ESBCCommandTypeBindComProgressReq resp:rspDict];
        ESDLog(@"[查询进度] 请求-失败:%@", error);
    }];
}

- (void)sendSpaceCreate:(NSDictionary *)req {
    NSString * string = [req yy_modelToJSONString];
    ESDLog(@"[sendSpaceCreate] 发送请求: %@", string);

    NSString * enJson = [self encrypt:string];
    NSDictionary * payload = @{@"body": enJson};
    
    [ESNetworkRequestManager sendRequest:self.apiClient.baseURL.absoluteString
                                    path:@"/agent/v1/api/bind/space/create"
                                  method:@"POST"
                             queryParams:nil
                                  header:nil
                                    body:payload
                               modelName:nil
                            successBlock:^(NSInteger requestId, NSString *response) {
        NSString * encodeJson = [self decrypt:response];
        NSData * jsonData = [encodeJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = @"AG-200";
        rspDict[@"results"] = dict;
       
        [self onBindCommand:ESBCCommandTypeBindSpaceCreateReq resp:rspDict];
        ESDLog(@"[空间创建] 请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary * rspDict = [[NSMutableDictionary alloc] init];
        rspDict[@"code"] = error.userInfo[@"code"];
        rspDict[@"message"] = error.userInfo[@"message"];
        [self onBindCommand:ESBCCommandTypeBindSpaceCreateReq resp:rspDict];
        ESDLog(@"[空间创建] 请求-失败:%@", error);
    }];
}

#pragma mark response
- (void)onPubKeyExchange:(ESRspPubKeyExchangeRsp *)response {
    self.boxStatus.pubKeyExchange = response.results;
    if (!self.boxStatus.pubKeyExchange.boxPubKey) {
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelNetwork];

        [self reset];
        return;
    }
    self.boxPair = [ESRSAPair pairWithPublicKey:[ESRSAPair keyFromPEM:self.boxStatus.pubKeyExchange.boxPubKey isPubkey:YES] privateKey:nil];
    ///验证签名
    if (![self.boxPair verifySignature:response.results.signedBtid plainText:self.btid]) {
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelNetwork];
        [self reset];
        return;
    }
    [self.parentModule viewModelOnPubKeyExchange:self.boxStatus channel:ESBoxRespChannelNetwork];

    [self aesKeyExchange];
}

- (void)onAESKeyExchange:(ESRspKeyExchangeRsp *)response {
    ESKeyExchangeRsp *results = response.results;
    ///异常数据
    if (results.sharedSecret.length == 0 || results.iv.length == 0) {
        if ([self.delegate respondsToSelector:@selector(viewModelOnClose:)]) {
            [self.delegate viewModelOnClose:nil];
        }
        [self.parentModule viewModelOnClose:nil channel:ESBoxRespChannelNetwork];

        [self reset];
        return;
    }
    ESRSAPair *pair = ESRSACenter.defaultPair;
    results.sharedSecret = [pair privateDecrypt:results.sharedSecret];
    results.iv = [pair privateDecrypt:results.iv];
    self.boxStatus.keyExchangeRsp = results;
    
    [self.parentModule viewModelOnAESKeyExchange:self.boxStatus channel:ESBoxRespChannelNetwork];

    [self addAOPToResponse];
    [self loadBoxStatus];
}

- (void)onInit:(ESBindInitResp *)response {
    self.boxStatus.infoResult = response.results;
    if (self.boxStatus.infoResult.boxName.length == 0) {
        self.boxStatus.infoResult.boxName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    }
    
    if (self.parentModule.mode == ESBoxBindModeWiredConnectionWithIp && self.boxStatus.infoResult.network.count <= 0) {
        ESBindNetworkModel *networkItem = [ESBindNetworkModel new];
        networkItem.wire = YES;
        networkItem.ip = self.mdnsItem.ipv4;
        networkItem.port = 80;
        networkItem.wifiName = @"eth0";
        self.boxStatus.infoResult.network = @[networkItem];
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
    self.boxStatus.wifiStatusResult = response.results;
    if (![response.code isEqual:@"AG-200"] && !response.results) {
        self.boxStatus.wifiStatusResult = [ESWifiStatusRsp new];
        self.boxStatus.wifiStatusResult.status = @(1);
    }
    [self.parentModule viewModelOnWifiStatus:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)onRevoke:(ESRspMicroServerRsp *)response {
    if ([response.results.results isKindOfClass:NSDictionary.class] || !response.results.results) {
        ESPasswdTryInfo *result = [[ESPasswdTryInfo alloc] initWithDictionary:(NSDictionary *)response.results.results error:nil];
        response.results.results = nil;
        ESResponseBasePasswdTryInfo *info = [[ESResponseBasePasswdTryInfo alloc] initWithDictionary:response.results.toDictionary error:nil];
        info.results = result;
        self.boxStatus.revokeResult = info;
    }

    [self.parentModule viewModelOnRevoke:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)onSetAdminPwd:(ESRspMicroServerRsp *)response {
    self.boxStatus.adminPwdResult = response.results;
    [self.parentModule viewModelOnSetAdminPwd:self.boxStatus channel:ESBoxRespChannelNetwork];
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

    [self.parentModule viewModelOnPair:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)onInitial:(ESRspMicroServerRsp *)response {
    self.boxStatus.initialResult = response;
    [self.parentModule viewModelOnInitial:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)onPassthrough:(NSDictionary *)response {
    [self.parentModule viewModelPassthrough:response channel:ESBoxRespChannelNetwork];
}

- (void)onSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    [self.parentModule viewModelOnSpaceCheckReady:response channel:ESBoxRespChannelNetwork];
}

- (void)onDiskRecognition:(ESDiskRecognitionResp *)response {
    [self.parentModule viewModelDiskRecognition:response channel:ESBoxRespChannelNetwork];
}

- (void)onDiskInitializeProgress:(ESDiskInitializeProgressResp *)response {
   [self.parentModule viewModelDiskInitializeProgress:response channel:ESBoxRespChannelNetwork];
}

- (void)onDiskManagementList:(ESDiskManagementListResp *)response {
    [self.parentModule viewModelDiskManagementList:response channel:ESBoxRespChannelNetwork];
}

- (void)onDiskInitialize:(ESBaseResp *)response {
    [self.parentModule viewModelDiskInitialize:response channel:ESBoxRespChannelNetwork];
}

- (void)onSystemShutdown:(ESBaseResp *)response {
    [self.parentModule viewModelSystemShutdown:response channel:ESBoxRespChannelNetwork];
}

- (void)onUpdataNetworkConfig:(ESBaseResp *)response {
    [self.parentModule viewModelUpdataNetworkConfig:response channel:ESBoxRespChannelNetwork];
}

- (void)onGetNetworkConfig:(ESBoxNetworkConfigResp *)response {
    [self.parentModule viewModelGetNetworkConfig:response channel:ESBoxRespChannelNetwork];
}

- (void)onIgnoreNetworkConfig:(ESBaseResp *)response {
    [self.parentModule viewModelIgnoreNetworkConfig:response channel:ESBoxRespChannelNetwork];
}

- (void)onDeviceAbility:(ESDeviceAbilityResp *)response {
    [self.parentModule viewModelDeviceAbility:response channel:ESBoxRespChannelNetwork];
}

- (void)onDomin:(NSDictionary *)response {
   // v2 平台社区
    [self.parentModule viewModelUpdateDomin:response channel:ESBoxRespChannelNetwork];
}

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response {
    [self.parentModule onBindCommand:command resp:response channel:ESBoxRespChannelNetwork];
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

    ESResponseDeserializer *deserializer = (ESResponseDeserializer *)self.apiClient.responseDeserializer;
    if (deserializer) {
        deserializer.yc_store(ESBeforeParseJsonKey, aop);
    }
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
    [self.parentModule viewModelOnWifiList:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)notifyBoxInfo {
    self.boxStatus.infoResult.network = self.boxStatus.infoResult.network ?: [NSMutableArray<ESNetwork> new];
    [self.parentModule viewModelOnInit:self.boxStatus channel:ESBoxRespChannelNetwork];
}

- (void)reset {
    self.mdnsItem = nil;
    self.btid = nil;
    self.serviceUUID = nil;
    self.boxStatus = nil;
    self.apiClient = nil;
    self.boxPair = nil;
    [self stopTimer];
    [_serviceBrowser stopSearch];
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

- (ESNetServiceBrowser *)serviceBrowser {
    if (!_serviceBrowser) {
        _serviceBrowser = [ESNetServiceBrowser new];
        weakfy(self);
        _serviceBrowser.didFindService = ^(NSArray<ESNetServiceItem *> *serviceList) {
            strongfy(self);
            self.mdnsItem = serviceList.firstObject;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d", self.mdnsItem.ipv4, self.mdnsItem.port]];
            ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:url];
            client.timeoutInterval = self.boxStatus.infoResult.initialEstimateTimeSec;
            self.apiClient = client;
            [self pubKeyExchange];
        }; 
    }
    return _serviceBrowser;
}

- (ESBoxStatusItem *)boxStatus {
    if (!_boxStatus) {
        _boxStatus = [ESBoxStatusItem new];
    }
    return _boxStatus;
}

- (NSString *)localHost {
    return self.apiClient.configuration.host;
}
@end
