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
//  ESBindInitResp.h
//  EulixSpace
//
//  Created by dazhou on 2022/11/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseResp.h"

NS_ASSUME_NONNULL_BEGIN

// 盒子类型
typedef NS_ENUM(NSUInteger, ESBoxGenEnum) {
    ESBoxGenEnum_Raspberry, // 树莓派
    ESBoxGenEnum_RK3568, // 二代盒子
};

typedef NS_ENUM(NSInteger, ESBoxDeviceModeEnum) {
    ESBoxDeviceModeEnum_Raspberry = 100, // 树莓派
    ESBoxDeviceModeEnum_RK3568 = 200, // 二代盒子
};

@interface ESBindNetworkModel : NSObject
@property(nonatomic) NSString * ip;

@property(nonatomic) long port;

@property(nonatomic) NSString * wifiName;
/* 有线 [optional]
 */
@property(nonatomic) BOOL wire;

// 是否有连接，不表示可以连互联网
@property (nonatomic, assign) BOOL connected;
// 业务端标记是否有互联网访问，默认有互联网连接
@property (nonatomic, assign) BOOL notInternet;
@property(nonatomic, assign) NSString * mac;
@property (nonatomic, assign) BOOL ipv4UseDhcp;
@property(nonatomic, assign) NSString * ipv6;
// 根据此字段判断是否有详情按钮及后续功能，因为要适配老系统
@property (nonatomic, assign) BOOL hasDetail;
//网卡名称
@property (nonatomic, strong) NSString * adapterName;
@end

@interface ESDeviceAbilityModel : NSObject
// 产品型号数字(内部使用, 1xx: 树莓派, 2xx: 二代, ...)
@property (nonatomic, assign) int deviceModelNumber;
//内部磁盘支持(SATA 和 m.2)
@property (nonatomic, assign) BOOL innerDiskSupport;
//支持加密芯片
@property (nonatomic, assign) BOOL securityChipSupport;

@property (nonatomic, assign) BOOL bluetoothSupport;
@property (nonatomic, assign) BOOL networkConfigSupport;
@property (nonatomic, assign) BOOL ledSupport;
@property (nonatomic, assign) BOOL backupRestoreSupport;
@property (nonatomic, assign) BOOL aospaceappSupport;
@property (nonatomic, assign) BOOL upgradeApiSupport;
@property (nonatomic, assign) BOOL aospaceDevOptionSupport;

@property (nonatomic, assign) BOOL openSource;


@property (nonatomic, strong) NSNumber *aospaceSwitchPlatformSupport;

- (BOOL)isRaspberryBox;
- (BOOL)isGen2Box;
- (BOOL)isTrialBox;
- (BOOL)isPCTrialBox;
- (BOOL)isOnlineTrialBox;
- (UIImage *)boxIcon;
- (NSString *)boxName;

@end

@interface ESBindInitResultModel : NSObject
@property(nonatomic, strong) NSString* boxName;

@property(nonatomic, strong) NSString* boxUuid;

@property(nonatomic, strong) NSString* clientUuid;

//0 是能 ping 通外网
@property(nonatomic, assign) int connected;

@property(nonatomic, assign) long initialEstimateTimeSec;

@property(nonatomic, strong) NSArray<ESBindNetworkModel *> * network;

@property(nonatomic, assign) long paired;

@property(nonatomic, assign) BOOL pairedBool;

@property (nonatomic, strong) ESDeviceAbilityModel * deviceAbility;

//设备图片链接
@property (nonatomic, strong) NSString * deviceLogoUrl;
//设备名称
@property (nonatomic, strong) NSString * deviceName;
//英文名称
@property (nonatomic, strong) NSString * deviceNameEn;
//中文代系
@property (nonatomic, strong) NSString * generationZh;
//英文代系
@property (nonatomic, strong) NSString * generationEn;
//操作系统版本
@property (nonatomic, strong) NSString * osVersion;

@property (nonatomic, strong) NSString * productId;
//产品型号
@property (nonatomic, strong) NSString * productModel;
//傲空间版本
@property (nonatomic, strong) NSString * spaceVersion;

@property(nonatomic, strong) NSString *sspUrl;

@property (nonatomic, assign) BOOL newBindProcessSupport;

@property (nonatomic, readonly) NSString *realIpAddress;
@property (nonatomic, readonly) NSString *realHost;
@property (nonatomic, readonly) NSString *linkName;
@property (nonatomic, readonly) BOOL unpaired;
@property (nonatomic, readonly) BOOL oldBox;

@end

@interface ESBindInitResp : ESBaseResp
@property (nonatomic, strong) ESBindInitResultModel * results;


@end


@interface ESDeviceAbilityResp : ESBaseResp
@property (nonatomic, strong) ESDeviceAbilityModel * results;
@end

NS_ASSUME_NONNULL_END
