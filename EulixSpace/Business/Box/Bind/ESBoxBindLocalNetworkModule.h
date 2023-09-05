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
//  ESBoxBindLocalNetworkModule.h
//  EulixSpace
//
//  Created by KongBo on 2023/6/19.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBoxBindViewModel.h"
#import "ESRSAPair.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESBoxBindLocalNetworkModule : NSObject

@property (nonatomic, weak) UIViewController<ESBoxBindViewModelDelegate> *delegate;
@property (nonatomic, weak) UIViewController<ESSecuritySettingJumpDelegate> * jumpDelegate;
@property (nonatomic, weak) ESBoxBindViewModel *parentModule;

@property (nonatomic, strong) ESBoxStatusItem *boxStatus;
@property (nonatomic, readonly) NSString *localHost;

@property (nonatomic, readonly) BOOL scaning;
@property (nonatomic, strong) ESRSAPair *pair;
@property (nonatomic, strong) NSString *clientPreSecret;

@property (nonatomic, strong) ESDiskInitializeReq * diskInitializeReq;
@property (nonatomic, strong) ESNetServiceItem *scanNetServiceInfo;
@property (nonatomic, copy) NSString *btid;

+ (instancetype)viewModelWithDelegate:(UIViewController<ESBoxBindViewModelDelegate> *)delegate parentModule:(ESBoxBindViewModel *)parentModule;
- (void)reset;

- (void)searchWithUniqueId:(NSString *)uniqueId;
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

- (void)pairing;
- (void)setAdminPwd:(NSString *)pwd;
- (void)initial;
- (NSInteger)getPairStatus;
- (NSString *)getBtid;


//APP 调用开始绑定接口后 system-agent 开始启动各个微服务容器。
// code=AG-200 成功; code=AG-460 已经绑定; code=AG-470 容器启动中; code=AG-471 容器已经启动;
- (void)sendSpaceStartInitialize;
- (void)sendBindComProgress;
- (void)sendSpaceCreate:(NSDictionary *)req;

@end

NS_ASSUME_NONNULL_END
