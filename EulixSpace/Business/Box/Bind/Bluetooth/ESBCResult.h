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
//  ESBCResult.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESInitResult.h"
#import "ESPairApi.h"
#import "ESPairingReq.h"
#import "ESResponseBasePasswdTryInfo.h"
#import "ESWifiListRsp.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESBCConnectStatus) {
    ESBCConnectStatusLocalNetwork, //0: 有线联网
    ESBCConnectStatusWifi,         //1: 无线联网
    ESBCConnectStatusNone,         //2: 未连接
};

///0: 已配对和管理员绑定
///1: 未绑定、未配对过(新盒子);
///2: 管理员已经解绑;
typedef NS_ENUM(NSUInteger, ESPairStatus) {
    ESPairStatusPaired,             //0: 已配对和管理员绑定
    ESPairStatusUnpaired,           //1: 未绑定、未配对过(新盒子);
    ESPairStatusPairedWithoutAdmin, //2: 管理员已经解绑;
};

static const uint8_t ESBCCommandVersion1 = 0b00000001;
// 不支持的蓝牙 cmd请求；在蓝牙请求的返回体中的 code
static const int ESBCCommandUnsupport = 404;


//最高第0位
//1 表示中心设备向外设发送的请求会分多个帧来发送，
static const uint8_t ESBCCommandReserveSendMultipart = 0b10000000; //0b 1000 0000

static const uint8_t ESBCCommandReserveDefault = 0b00000000; //0b 0000 0000

typedef NS_ENUM(NSInteger, ESBCCommandType) {
    ESBCCommandTypeNone = -1,   // 默认值
    ESBCCommandTypeReceipt = 0, // 帧回执, box->app.
    //
    ESBCCommandTypeInitReq = 1, // 初始化请求, app->box.
    ESBCCommandTypeInitRsp = 2, // 初始化响应, box->app.

    ESBCCommandTypeWifiListReq = 3, // Wifi列表请求, app->box.
    ESBCCommandTypeWifiListRsp = 4, // Wifi列表响应, box->app.

    ESBCCommandTypeWifiPwdReq = 5, // 连接WIFI请求, app->box.
    ESBCCommandTypeWifiPwdRsp = 6, // 连接WIFI响应, box->app.

    ESBCCommandTypePairReq = 7, // 配对请求, app->box. 上传数据
    ESBCCommandTypePairRsp = 8, // 配对响应, box->app.

    ESBCCommandTypeRevokeReq = 9,  // 管理员解绑请求, app->box.
    ESBCCommandTypeRevokeRsp = 10, // 管理员解绑响应, box->app.

    ESBCCommandTypeSetAdminPwdReq = 11, // 管理员设置管理密码请求 app->box.
    ESBCCommandTypeSetAdminPwdRsp = 12, // 管理员设置管理密码响应, box->app.

    ESBCCommandTypeInitialReq = 13, // 盒子完成初始化请求 app->box.
    ESBCCommandTypeInitialRsp = 14, // 盒子完成初始化响应, box->app.

    ESBCCommandTypePubKeyExchangeReq = 15, // 公钥交换请求
    ESBCCommandTypePubKeyExchangeRsp = 16, // 公钥交换响应

    ESBCCommandTypeKeyExchangeReq = 17, // 对称密钥交换请求
    ESBCCommandTypeKeyExchangeRsp = 18, // 对称密钥交换响应
    
    ESBCCommandTypePassthroughReq = 19, // 透传调用网关接口请求
    ESBCCommandTypePassthroughRsp = 20, // 透传调用网关接口响应
    

    ESSwithPlatformReq = 21, // 切换空间平台接口请求
    ESSwithPlatformRsp = 22,  // 切换空间平台接口响应
    
    // 磁盘管理相关
    ESBCCommandTypeSpaceReadyCheckReq        = 25, // 检测空间是否准备就绪请求
    ESBCCommandTypeSpaceReadyCheckRsp        = 26, // 检测空间是否准备就绪响应
    ESBCCommandTypeDiskRecognitionReq        = 27, // 磁盘识别请求
    ESBCCommandTypeDiskRecognitionRsp        = 28, // 磁盘识别响应
    ESBCCommandTypeDiskInitializeReq         = 29, // 磁盘开始初始化请求
    ESBCCommandTypeDiskInitializeRsp         = 30, // 磁盘开始初始化响应
    ESBCCommandTypeDiskInitializeProgressReq = 31, // 磁盘开始初始化进度获取请求
    ESBCCommandTypeDiskInitializeProgressRsp = 32, // 磁盘开始初始化进度获取响应
    ESBCCommandTypeDiskManagementListReq     = 33, // 磁盘管理列表请求
    ESBCCommandTypeDiskManagementListRsp     = 34, // 磁盘管理列表响应
    ESBCCommandTypeSystemShutdownReq         = 35, // 系统关机请求
    ESBCCommandTypeSystemShutdownRsp         = 36, // 系统关机响应
    ESBCCommandTypeSystemRebootReq           = 37, // 系统重启请求
    ESBCCommandTypeSystemRebootRsp           = 38, // 系统重启响应
    
    // 网络配置相关
    ESBCCommandTypeUpdataNetworkConfigReq = 39, // 更新网络配置请求
    ESBCCommandTypeUpdataNetworkConfigRsp = 40, // 更新网络配置响应
    ESBCCommandTypeGetNetworkConfigReq    = 41, // 获取网络配置请求
    ESBCCommandTypeGetNetworkConfigRsp    = 42, // 获取网络配置响应
    ESBCCommandTypeIgnoreNetworkConfigReq = 43, // 忘记网络配置请求
    ESBCCommandTypeIgnoreNetworkConfigRsp = 44, // 忘记网络配置响应

    ESBCCommandTypeDeviceAbilityReq = 45, // 查询设备能力请求
    ESBCCommandTypeDeviceAbilityRsp = 46, // 查询设备能力响应
    
    ESBCCommandTypeBindInitReq = 47, // 绑定初始化请求  /agent/v1/api/bind/init
    ESBCCommandTypeBindInitRsp = 48, // 绑定初始化响应  /agent/v1/api/bind/init

    ESBCCommandTypeBindComStartReq = 49, // 初始化组件开始请求  /agent/v1/api/bind/com/start
    ESBCCommandTypeBindComStartRsp = 50, // 初始化组件开始请求  /agent/v1/api/bind/com/start

    ESBCCommandTypeBindComProgressReq = 51, //  /agent/v1/api/bind/com/progress
    ESBCCommandTypeBindComProgressRsp = 52, //  /agent/v1/api/bind/com/progress

    ESBCCommandTypeBindInternetServiceConfigReq = 53, //   /agent/v1/api/bind/internet/service/config
    ESBCCommandTypeBindInternetServiceConfigRsp = 54, //   /agent/v1/api/bind/internet/service/config

    ESBCCommandTypeBindSpaceCreateReq = 55, //  /agent/v1/api/bind/space/create
    ESBCCommandTypeBindSpaceCreateRsp = 56, //
    
    ESBCCommandTypeBindPasswordVerifyReq = 57, // /agent/v1/api/bind/password/verify
    ESBCCommandTypeBindPasswordVerifyRsp = 58, // /agent/v1/api/bind/password/verify

    ESBCCommandTypeBindRevokeReq = 59, //   /agent/v1/api/bind/revoke
    ESBCCommandTypeBindRevokeRsp = 60, //   /agent/v1/api/bind/revoke

};

extern NSString *nameOfCommand(ESBCCommandType cmd);

@interface ESBCCommand : NSObject

@property (nonatomic, readonly) NSData *body;

/// 封装命令
/// @param command ESBCCommandType
/// @param payload 负载数据
/// @param packetSeqNum 序列号
/// 默认参数  frameCount = 1, frameIndex = 0
+ (instancetype)command:(ESBCCommandType)command
                payload:(NSString *)payload
           packetSeqNum:(uint8_t)packetSeqNum;

/// 封装命令
/// @param command ESBCCommandType
/// @param payload 负载数据
/// @param packetSeqNum 序列号
/// @param frameCount 数据包总帧数
/// @param frameIndex 当前帧索引
+ (instancetype)command:(ESBCCommandType)command
                reserve:(uint8_t)reserve
                payload:(NSString *)payload
           packetSeqNum:(uint8_t)packetSeqNum
             frameCount:(uint8_t)frameCount
             frameIndex:(uint8_t)frameIndex;

@end

@interface ESBCCommonResult : NSObject

@property (nonatomic, readonly) ESBCCommandType command;

@property (nonatomic, readonly) uint8_t packetSeqNum;

@property (nonatomic, readonly) uint8_t frameCount;

@property (nonatomic, readonly) uint8_t frameIndex;

@property (nonatomic, copy, readonly) NSString *json;

///检测是否完整

@property (nonatomic, readonly) BOOL firstFrame;

@property (nonatomic, readonly) BOOL completed;

+ (instancetype)parse:(NSData *)data;

- (ESBCCommonResult *)merge:(ESBCCommonResult *)other;

@end

@interface ESInitResult (ESTool)

@property (nonatomic, readonly) NSString *realIpAddress;

@property (nonatomic, readonly) NSString *realHost;

@property (nonatomic, readonly) NSString *linkName;

@property (nonatomic, readonly) BOOL unpaired;

@property (nonatomic, readonly) BOOL oldBox;

@end

@interface ESWifiListRsp (ESTool)

- (BOOL)isEqual:(ESWifiListRsp *)object;

@end

@interface ESResponseBasePasswdTryInfo (ESTool)

//code -1: 入参错误, code 0: 解绑成功, code 1: 重复解绑, code >=2: 解绑失败;

@property (nonatomic, readonly) BOOL success;

@end

@interface ESRspPubKeyExchangeResult : NSObject

@property (nonatomic, copy) NSString *boxPubKey;

@end
