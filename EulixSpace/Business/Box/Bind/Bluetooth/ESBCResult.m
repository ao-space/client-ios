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
//  ESBCResult.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBCResult.h"
#import "ESApiCode.h"
#import "ESGlobalMacro.h"
#import "ESThemeDefine.h"
#import "NSData+ESTool.h"
#import "NSString+ESTool.h"

@interface ESBCCommand ()

@property (nonatomic, strong) NSData *body;

@end

@implementation ESBCCommand

/// 傲来蓝牙传输协议 v4
/// 数据帧格式
/// @param type  类型字段
/// @param payload  数据字段
///   | 描述                                            | 长度(单位:字节) |
///   |----|---------------------------------------------------------|
///   | 数据帧格式版本号                        | 1 |
///   | 保留字段                                      | 1 |
///   | 数据包序列号字段                        | 1 |
///   | 类型字段                                       | 1 |
///   | 数据包总帧数                                | 1 |
///   | 当前帧索引                                   | 1 |
///   | 当前帧总长度(仅载荷数据)           | 2 |
///   | 数据字段                                       | 不定长 |
///   | 补位                                              | 不定长 |
+ (instancetype)command:(ESBCCommandType)type
                reserve:(uint8_t)reserve
                payload:(NSString *)payload
           packetSeqNum:(uint8_t)packetSeqNum
             frameCount:(uint8_t)frameCount
             frameIndex:(uint8_t)frameIndex {
    NSMutableData *body = [NSMutableData data];
    //数据帧格式版本号
    [body appendData:[NSData byteFromUInt8:ESBCCommandVersion1]];
    //保留字段
    [body appendData:[NSData byteFromUInt8:reserve]];
    //数据包序列号字段
    [body appendData:[NSData byteFromUInt8:packetSeqNum]];
    //类型字段
    [body appendData:[NSData byteFromUInt8:type]];
    //数据包总帧数
    [body appendData:[NSData byteFromUInt8:frameCount]]; //1
    //当前帧索引
    [body appendData:[NSData byteFromUInt8:frameIndex]]; //0

    ///  单片
    ///  0b 0000 0000  1 0
    ///  分片
    ///  0b 1000 0000  2 0 第一帧
    ///  0b 1000 0000  2 1 第二帧

    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];

    //当前帧总长度(仅载荷数据)
    [body appendData:[NSData bytesFromUInt16:payloadData.length]];
    //数据字段
    [body appendData:payloadData];

    ESBCCommand *cmd = [ESBCCommand new];
    cmd.body = body;
    return cmd;
}

+ (instancetype)command:(ESBCCommandType)command
                payload:(NSString *)payload
           packetSeqNum:(uint8_t)packetSeqNum {
    return [self command:command reserve:ESBCCommandReserveDefault payload:payload packetSeqNum:packetSeqNum frameCount:1 frameIndex:0];
}

@end

@interface ESBCCommonResult ()

@property (nonatomic, assign) ESBCCommandType command;

@property (nonatomic, assign) uint8_t version;

@property (nonatomic, assign) uint8_t reserve;

@property (nonatomic, assign) uint8_t packetSeqNum;

@property (nonatomic, assign) uint8_t frameCount;

@property (nonatomic, assign) uint8_t frameIndex;

@property (nonatomic, assign) uint16_t payloadLength;

@property (nonatomic, copy) NSString *json;

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation ESBCCommonResult

/// 傲来蓝牙传输协议 v4
/// 数据帧格式
/// @param data 接受的二进制流
///   | 描述                                            | 长度(单位:字节) |
///   |----|---------------------------------------------------------|
///   | 数据帧格式版本号                        | 1 |
///   | 保留字段                                      | 1 |
///   | 数据包序列号字段                        | 1 |
///   | 类型字段                                       | 1 |
///   | 数据包总帧数                                | 1 |
///   | 当前帧索引                                   | 1 |
///   | 当前帧总长度(仅载荷数据)           | 2 |
///   | 数据字段                                       | 不定长 |
///   | 补位                                              | 不定长 |
+ (instancetype)parse:(NSData *)data {
    ESDLog(@"[Bluetooth] parse data %@", data);
    NSUInteger offset = 0;
    NSUInteger length = 1;
    //数据帧格式版本号 0-1
    uint8_t version = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset += length;
    ESDLog(@"[Bluetooth] parse version %d", version);

    //保留字段, 暂时忽略
    uint8_t reserve = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset += length;
    ESDLog(@"[Bluetooth] parse reserve %d", reserve);

    //数据包序列号字段 2-1
    uint8_t packetSeqNum = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset++;
    ESDLog(@"[Bluetooth] parse seqId %d", packetSeqNum);

    //类型字段
    uint8_t command = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset++;
    ESDLog(@"[Bluetooth] parse command %@", nameOfCommand(command));

    //数据包总帧数
    uint8_t frameCount = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset++;

    //当前帧索引
    uint8_t frameIndex = [data subdataWithRange:NSMakeRange(offset, length)].uint8FromBytes;
    offset++;
    ESDLog(@"[Bluetooth] parse frameIndex/frameCount => %d/%d", frameIndex, frameCount);

    //当前帧总长度(仅载荷数据)
    length = 2;
    uint16_t payloadLength = [data subdataWithRange:NSMakeRange(offset, length)].uint16FromBytes;
    offset += length; //offset == 8
    ESDLog(@"[Bluetooth] parse payloadLength %d", payloadLength);

    NSParameterAssert(data.length >= offset + payloadLength);

    NSData *payload = [data subdataWithRange:NSMakeRange(offset, payloadLength)];
    NSString *json = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    ESDLog(@"[Bluetooth] parse payload start ==>\n%@", json);
    ESDLog(@"[Bluetooth] parse payload end <==");
    ESBCCommonResult *result = [ESBCCommonResult new];
    result.version = version;             //数据帧格式版本号
    result.reserve = reserve;             //保留字段
    result.packetSeqNum = packetSeqNum;   //数据包序列号字段
    result.command = command;             //类型字段
    result.frameCount = frameCount;       //数据包总帧数
    result.frameIndex = frameIndex;       //当前帧索引
    result.payloadLength = payloadLength; //当前帧索引
    result.data = payload.mutableCopy;
    if (result.completed) {
        result.json = json;
    }
    return result;
}

- (ESBCCommonResult *)merge:(ESBCCommonResult *)other {
    //同一个指令 并且是下一帧
    if (self.command != other.command || self.frameIndex != other.frameIndex - 1 || self.frameCount != other.frameCount) {
        return nil;
    }
    //标记为下一帧
    self.frameIndex = other.frameIndex;        /// 0 -> 1
    self.payloadLength += other.payloadLength; ///240 += 240
    [self.data appendData:other.data];
    if (self.completed) {
        self.json = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        ESDLog(@"[Bluetooth] parse merge all frame payload %@", self.json);
    }
    return self;
}

/// index == 0  count == 1
///
/// index == 2  count == 3
///
- (BOOL)completed {
    return self.frameIndex == self.frameCount - 1;
}

- (BOOL)firstFrame {
    return self.frameIndex == 0;
}

@end

@implementation ESInitResult (ESTool)

- (NSString *)linkName {
    __block ESNetwork *item = self.network.firstObject;
    [self.network enumerateObjectsUsingBlock:^(ESNetwork *_Nonnull obj,
                                               NSUInteger idx,
                                               BOOL *_Nonnull stop) {
        if (!obj.wire.boolValue) {
            item = obj;
            *stop = YES;
        }
    }];
    if (!item) {
        return nil;
    }
    return item.wire.boolValue ? TEXT_BOX_NETWORK_LOCAL_NETWORK : item.wifiName;
}

- (NSString *)realHost {
    return [NSString stringWithFormat:@"%@:5678", self.realIpAddress];
}

- (NSString *)realIpAddress {
    __block ESNetwork *item = self.network.firstObject;
    [self.network enumerateObjectsUsingBlock:^(ESNetwork *_Nonnull obj,
                                               NSUInteger idx,
                                               BOOL *_Nonnull stop) {
        if (!obj.wire.boolValue) {
            item = obj;
            *stop = YES;
        }
    }];
    return item.ip;
}

- (BOOL)unpaired {
    return self.paired.integerValue == ESPairStatusUnpaired || self.paired.integerValue == ESPairStatusPairedWithoutAdmin;
}

- (BOOL)oldBox {
    return self.paired.integerValue == ESPairStatusPairedWithoutAdmin || self.paired.integerValue == ESPairStatusPaired;
}

@end

@implementation ESWifiListRsp (ESTool)

- (BOOL)isEqual:(ESWifiListRsp *)object {
    if (![object isKindOfClass:[ESWifiListRsp class]]) {
        return NO;
    }
    return [self.addr isEqualToString:object.addr];
}

@end

@implementation ESResponseBasePasswdTryInfo (ESTool)

- (BOOL)success {
    return self.code.justErrorCode == ESApiCodeOk || self.code.justErrorCode == ESApiCodeAdminHasBeenRevoked;
}

@end

@implementation ESRspPubKeyExchangeResult

@end

extern NSString *nameOfCommand(ESBCCommandType cmd) {
    static NSDictionary *_config;
    if (!_config) {
        _config = @{
            @(ESBCCommandTypeNone): @"None",
            @(ESBCCommandTypeReceipt): @"Receipt",
            @(ESBCCommandTypeInitReq): @"InitReq",
            @(ESBCCommandTypeInitRsp): @"InitRsp",
            @(ESBCCommandTypeWifiListReq): @"WifiListReq",
            @(ESBCCommandTypeWifiListRsp): @"WifiListRsp",
            @(ESBCCommandTypeWifiPwdReq): @"WifiPwdReq",
            @(ESBCCommandTypeWifiPwdRsp): @"WifiPwdRsp",
            @(ESBCCommandTypePairReq): @"PairReq",
            @(ESBCCommandTypePairRsp): @"PairRsp",
            @(ESBCCommandTypeRevokeReq): @"RevokeReq",
            @(ESBCCommandTypeRevokeRsp): @"RevokeRsp",
            @(ESBCCommandTypeSetAdminPwdReq): @"SetAdminPwdReq",
            @(ESBCCommandTypeSetAdminPwdRsp): @"SetAdminPwdRsp",
            @(ESBCCommandTypeInitialReq): @"InitialReq",
            @(ESBCCommandTypeInitialRsp): @"InitialRsp",
            @(ESBCCommandTypePubKeyExchangeReq): @"PubKeyExchangeReq",
            @(ESBCCommandTypePubKeyExchangeRsp): @"PubKeyExchangeRsp",
            @(ESBCCommandTypeKeyExchangeReq): @"ExchangeReq",
            @(ESBCCommandTypeKeyExchangeRsp): @"ExchangeRsp",
            @(ESBCCommandTypePassthroughReq): @"PassthroughReq",
            @(ESBCCommandTypePassthroughRsp): @"PassthroughRsp",

            
            @(ESBCCommandTypeSpaceReadyCheckReq): @"SpaceReadyCheckReq", // 检测空间是否准备就绪请求
            @(ESBCCommandTypeSpaceReadyCheckRsp): @"SpaceReadyCheckRsp", // 检测空间是否准备就绪响应
            @(ESBCCommandTypeDiskRecognitionReq): @"DiskRecognitionReq", // 磁盘识别请求
            @(ESBCCommandTypeDiskRecognitionRsp): @"DiskRecognitionRsp", // 磁盘识别响应
            @(ESBCCommandTypeDiskInitializeReq): @"DiskInitializeReq", // 磁盘开始初始化请求
            @(ESBCCommandTypeDiskInitializeRsp): @"DiskInitializeRsp", // 磁盘开始初始化响应
            @(ESBCCommandTypeDiskInitializeProgressReq): @"DiskInitializeProgressReq", // 磁盘开始初始化进度获取请求
            @(ESBCCommandTypeDiskInitializeProgressRsp): @"DiskInitializeProgressRsp",// 磁盘开始初始化进度获取响应
            @(ESBCCommandTypeDiskManagementListReq): @"DiskManagementListReq",// 磁盘管理列表请求
            @(ESBCCommandTypeDiskManagementListRsp): @"DiskManagementListRsp",// 磁盘管理列表响应
            @(ESBCCommandTypeSystemShutdownReq): @"SystemShutdownReq",// 系统关机请求
            @(ESBCCommandTypeSystemShutdownRsp): @"SystemShutdownRsp",// 系统关机响应
            @(ESBCCommandTypeSystemRebootReq): @"SystemRebootReq",// 系统重启请求
            @(ESBCCommandTypeSystemRebootRsp): @"SystemRebootRsp",// 系统重启响应

            @(ESBCCommandTypeUpdataNetworkConfigReq) : @"UpdataNetworkConfigReq", // 更新网络配置请求
            @(ESBCCommandTypeUpdataNetworkConfigRsp) : @"UpdataNetworkConfigRsp", // 更新网络配置响应
            @(ESBCCommandTypeGetNetworkConfigReq) : @"GetNetworkConfigReq", // 获取网络配置请求
            @(ESBCCommandTypeGetNetworkConfigRsp) : @"GetNetworkConfigRsp", // 获取网络配置响应
            @(ESBCCommandTypeIgnoreNetworkConfigReq) : @"IgnoreNetworkConfigReq", // 忘记网络配置请求
            @(ESBCCommandTypeIgnoreNetworkConfigRsp) : @"IgnoreNetworkConfigRsp", // 忘记网络配置响应
            @(ESBCCommandTypeDeviceAbilityReq) : @"DeviceAbilityReq", // 查询设备能力请求
            @(ESBCCommandTypeDeviceAbilityRsp) : @"DeviceAbilityRsp", // 查询设备能力请求

            @(ESSwithPlatformReq): @"SwithPlatformReq",
            @(ESSwithPlatformRsp): @"SwithPlatformRsp",
            
            @(ESBCCommandTypeBindInitReq): @"ESBCCommandTypeBindInitReq",
            @(ESBCCommandTypeBindInitRsp): @"ESBCCommandTypeBindInitRsp",
            
            @(ESBCCommandTypeBindComStartReq): @"ESBCCommandTypeBindComStartReq",
            @(ESBCCommandTypeBindComStartRsp): @"ESBCCommandTypeBindComStartRsp",
            
            @(ESBCCommandTypeBindComProgressReq): @"ESBCCommandTypeBindComProgressReq",
            @(ESBCCommandTypeBindComProgressRsp): @"ESBCCommandTypeBindComProgressRsp",
            
            @(ESBCCommandTypeBindInternetServiceConfigReq): @"ESBCCommandTypeBindInternetServiceConfigReq",
            @(ESBCCommandTypeBindInternetServiceConfigRsp): @"ESBCCommandTypeBindInternetServiceConfigRsp",
            
            @(ESBCCommandTypeBindSpaceCreateReq): @"ESBCCommandTypeBindSpaceCreateReq",
            @(ESBCCommandTypeBindSpaceCreateRsp): @"ESBCCommandTypeBindSpaceCreateRsp",
            
            @(ESBCCommandTypeBindPasswordVerifyReq): @"ESBCCommandTypeBindPasswordVerifyReq",
            @(ESBCCommandTypeBindPasswordVerifyRsp): @"ESBCCommandTypeBindPasswordVerifyRsp",

            @(ESBCCommandTypeBindRevokeReq): @"ESBCCommandTypeBindRevokeReq",
            @(ESBCCommandTypeBindRevokeRsp): @"ESBCCommandTypeBindRevokeRsp",
        };
    }
    NSCParameterAssert(_config[@(cmd)]);
    return _config[@(cmd)] ?: @"None";
}
