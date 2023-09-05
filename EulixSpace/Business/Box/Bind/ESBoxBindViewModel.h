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
//  ESBoxBindViewModel.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBCResult.h"
#import "ESBoxStatusItem.h"
#import "ESDeviceApi.h"
#import "ESNetApi.h"
#import "ESPairApi.h"
#import <Foundation/Foundation.h>
#import "ESBindInitResp.h"
#import "ESBoxWifiModel.h"

// 蓝牙超时专门code
static NSString * const kESBluetoohTimeoutCode = @"-1010";

typedef NS_ENUM(NSUInteger, ESBoxBindMode) {
    ESBoxBindModeBluetooth,
    ESBoxBindModeWiredConnection,
    ESBoxBindModeWiredConnectionWithIp, //适配PC模拟器
    ESBoxBindModeBluetoothAndWiredConnection, //蓝牙 + 局域网
};

typedef NS_ENUM(NSUInteger, ESBoxRespChannel) {
    ESBoxRespChannelUnkown,
    ESBoxRespChannelBle,
    ESBoxRespChannelNetwork,
};

@class ESBluetoothItem;
@class ESNetServiceItem;
@class ESPairingBoxInfo;
@class UIViewController;
@protocol ESBoxBindViewModelDelegate <NSObject>

@optional

- (void)viewModelFound:(ESBluetoothItem *)bluetoothItem mdnsItem:(ESNetServiceItem *)mdnsItem;
- (void)viewModelOnPubKeyExchange:(ESBoxStatusItem *)boxStatus;
- (void)viewModelOnAESKeyExchange:(ESBoxStatusItem *)boxStatus;

- (void)viewModelOnClose:(NSError *)error;

//尝试使用配置的IP和端口交换公钥失败，设备不可达
- (void)viewModelLocalNetServiceNotReachable:(NSError *)error;
- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus;

- (void)viewModelOnWifiList:(ESBoxStatusItem *)boxStatus;
- (void)viewModelOnWifiStatus:(ESBoxStatusItem *)boxStatus;

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus;
- (void)viewModelOnPair:(ESBoxStatusItem *)boxStatus;

- (void)viewModelOnSetAdminPwd:(ESBoxStatusItem *)boxStatus;
- (void)viewModelOnInitial:(ESBoxStatusItem *)boxStatus;
- (void)viewModelPassthrough:(NSDictionary *)rspDict;

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response;
- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response;
- (void)viewModelDiskInitializeProgress:(ESDiskInitializeProgressResp *)response;
- (void)viewModelDiskInitialize:(ESBaseResp *)response;
- (void)viewModelSystemShutdown:(ESBaseResp *)response;
- (void)viewModelDiskManagementList:(ESDiskManagementListResp *)response;

- (void)viewModelUpdataNetworkConfig:(ESBaseResp *)response;
- (void)viewModelGetNetworkConfig:(ESBoxNetworkConfigResp *)response;
- (void)viewModelIgnoreNetworkConfig:(ESBaseResp *)response;
- (void)viewModelDeviceAbility:(ESDeviceAbilityResp *)response;

- (void)viewModelUpdateDomin:(NSDictionary *)rspDict;

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response;

@end

@protocol ESSecuritySettingJumpDelegate <NSObject>

@optional
- (int)viewModelJump;

@end

@interface ESBoxBindViewModel : NSObject

+ (instancetype)viewModelWithDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate;

@property (nonatomic, weak) UIViewController<ESBoxBindViewModelDelegate> *delegate;
@property (nonatomic, weak) UIViewController<ESSecuritySettingJumpDelegate> * jumpDelegate;

@property (nonatomic, readonly) ESBoxStatusItem *boxStatus;

///存储配对中的盒子信息
@property (nonatomic, strong) ESPairingBoxInfo *boxInfo;
//绑定模式
@property (nonatomic, assign) ESBoxBindMode mode;

//支持新绑定流程
@property (nonatomic, assign) BOOL supportNewBindProcess;
@property (nonatomic, assign) BOOL enableInternetAccess;

@property (nonatomic, copy) NSString *securityPassword;
@property (nonatomic, copy) NSString *spaceName;
@property (nonatomic, copy) NSString *localHost;

@property (nonatomic, copy) NSString *agentToken;
@property (nonatomic, strong)  ESBoxItem *paringBoxItem;

@property (nonatomic, assign) ESDiskInitStatus diskInitialCode;
@property (nonatomic, assign) BOOL diskInited;

//当前返回response的通道
@property (nonatomic, assign) ESBoxRespChannel currentResponseChannel;

///快捷判断当前是否走蓝牙通道
@property (nonatomic, readonly) BOOL viaBluetooth;

@property (nonatomic, readonly) BOOL scaning;

@property (nonatomic, strong) ESDiskInitializeReq * diskInitializeReq;

@property (nonatomic, strong) ESNetServiceItem *scanNetServiceInfo;

- (void)reset;

///
- (void)searchWithUniqueId:(NSString *)uniqueId;

- (void)pubKeyExchange;

- (void)loadWifiList;

- (void)sendAddr:(NSString *)addr password:(NSString *)password;

- (void)revokeWithSecurityPassword:(NSString *)securityPassword;
- (void)newRevokeWithSecurityPassword:(NSString *)securityPassword;

- (void)sendPassthrough:(NSString *)string;


- (void)sendDiskRecognition;
- (void)sendSpaceReadyCheck;
- (void)sendDiskInitializeProgress;
- (void)sendDiskInitialize:(ESDiskInitializeReq *)req;
- (void)sendDiskManagementList;
- (void)sendSystemShutdown;

//wifiName: WIFI名称。有线连接时为空串。
- (void)sendNetworkIgnore:(NSString *)wifiName;
- (void)sendGetNetworkConfig;
- (void)sendUpdataNetworkConfig:(ESBoxNetworkConfigReq *)req;
- (void)sendDeviceAbility;

- (void)sendV2Domin:(NSString *)string;

///
- (void)pairing;

- (void)setAdminPwd:(NSString *)pwd;

- (void)initial;

- (NSInteger)getPairStatus;

- (NSString *)getBtid;

//APP 调用开始绑定接口后 system-agent 开始启动各个微服务容器。
// code=AG-200 成功; code=AG-460 已经绑定; code=AG-470 容器启动中; code=AG-471 容器已经启动;
- (void)sendSpaceStartInitialize;

- (void)sendBindComProgress;

//{
//  "clientPhoneModel": "string",
//  "clientUuid": "string",
//  "enableInternetAccess": true,
//  "password": "string",
//  "spaceName": "string"
//}
- (void)sendSpaceCreate:(NSDictionary *)req;

@end
