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
//  ESBluetoothCommunication.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBluetoothCommunication.h"
#import "ESApiCode.h"
#import "ESBluetoothManager.h"
#import "ESGlobalMacro.h"
#import "NSString+ESTool.h"
#import <YYModel/YYModel.h>

@interface ESBluetoothCommunication () <ESBluetoothManagerDelegate>

@property (nonatomic, copy) NSString *serviceUUID;

@property (nonatomic, copy) NSString *localName;

@property (nonatomic, strong) ESBluetoothItem *item;

@property (nonatomic, assign) ESBCCommandType command;

@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *expectRspDict;

@property (nonatomic, copy) NSDictionary *payload;
@property (nonatomic, copy) NSString *payloadStr;

@property (nonatomic, assign) uint8_t packetSeqNum;

///基础帧, 分片时会存储第一帧, 并且会递增合并后续帧
@property (nonatomic, strong) ESBCCommonResult *baseFrame;

/// 需要发送给后端的分片信息
@property (nonatomic, strong) NSArray<NSString *> *multipart;

///切面, 解密 results 字段
@property (nonatomic, copy) ESBeforeParseJson beforeParseJson;

@end

@implementation ESBluetoothCommunication

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 定义某个`req`对应的`rsp` 类型
- (NSDictionary<NSNumber *, NSNumber *> *)expectRspDict {
    if (!_expectRspDict) {
        _expectRspDict = @{
            @(ESBCCommandTypeInitReq): @(ESBCCommandTypeInitRsp),
            @(ESBCCommandTypeWifiListReq): @(ESBCCommandTypeWifiListRsp),
            @(ESBCCommandTypeWifiPwdReq): @(ESBCCommandTypeWifiPwdRsp),
            @(ESBCCommandTypePairReq): @(ESBCCommandTypePairRsp),
            @(ESBCCommandTypeRevokeReq): @(ESBCCommandTypeRevokeRsp),
            @(ESBCCommandTypeSetAdminPwdReq): @(ESBCCommandTypeSetAdminPwdRsp),
            @(ESBCCommandTypeInitialReq): @(ESBCCommandTypeInitialRsp),
            @(ESBCCommandTypePubKeyExchangeReq): @(ESBCCommandTypePubKeyExchangeRsp),
            @(ESBCCommandTypeKeyExchangeReq): @(ESBCCommandTypeKeyExchangeRsp),
            @(ESBCCommandTypePassthroughReq): @(ESBCCommandTypePassthroughRsp),
            
            @(ESBCCommandTypeSpaceReadyCheckReq): @(ESBCCommandTypeSpaceReadyCheckRsp),
            @(ESBCCommandTypeDiskRecognitionReq): @(ESBCCommandTypeDiskRecognitionRsp),
            @(ESBCCommandTypeDiskInitializeReq): @(ESBCCommandTypeDiskInitializeRsp),
            @(ESBCCommandTypeDiskInitializeProgressReq): @(ESBCCommandTypeDiskInitializeProgressRsp),
            @(ESBCCommandTypeDiskManagementListReq): @(ESBCCommandTypeDiskManagementListRsp),
            @(ESBCCommandTypeSystemShutdownReq): @(ESBCCommandTypeSystemShutdownRsp),
            @(ESBCCommandTypeSystemRebootReq): @(ESBCCommandTypeSystemRebootRsp),
            @(ESBCCommandTypeUpdataNetworkConfigReq): @(ESBCCommandTypeUpdataNetworkConfigRsp),
            @(ESBCCommandTypeGetNetworkConfigReq): @(ESBCCommandTypeGetNetworkConfigRsp),
            @(ESBCCommandTypeIgnoreNetworkConfigReq): @(ESBCCommandTypeIgnoreNetworkConfigRsp),
            @(ESBCCommandTypeDeviceAbilityReq): @(ESBCCommandTypeDeviceAbilityRsp),
            @(ESSwithPlatformReq): @(ESSwithPlatformRsp),
            
            @(ESBCCommandTypeBindInitReq): @(ESBCCommandTypeBindInitRsp),
            @(ESBCCommandTypeBindComStartReq): @(ESBCCommandTypeBindComStartRsp),
            @(ESBCCommandTypeBindComProgressReq): @(ESBCCommandTypeBindComProgressRsp),
            @(ESBCCommandTypeBindInternetServiceConfigReq): @(ESBCCommandTypeBindInternetServiceConfigRsp),
            @(ESBCCommandTypeBindSpaceCreateReq): @(ESBCCommandTypeBindSpaceCreateRsp),
            @(ESBCCommandTypeBindPasswordVerifyReq): @(ESBCCommandTypeBindPasswordVerifyRsp),
            @(ESBCCommandTypeBindRevokeReq): @(ESBCCommandTypeBindRevokeRsp),
        };
    }
    return _expectRspDict;
}

///请求下一帧, 当收到后端返回的数据是分片时使用
- (void)requestNextFrame {
    usleep(50 * 1000);
    ESBCCommand *cmd = [ESBCCommand command:self.command
                                    reserve:ESBCCommandReserveDefault
                                    payload:nil //应该只发送头就行了，不用发送 body 了。
                               packetSeqNum:self.packetSeqNum
                                 frameCount:self.baseFrame.frameCount
                                 frameIndex:self.baseFrame.frameIndex + 1];
    [ESBluetoothManager.manager writeValue:cmd.body];
}

#pragma mark - ESBluetoothManagerDelegate

///收到懒到通道的返回数据
- (void)bluetooth:(ESBluetoothItem *)bluetooth readValue:(NSData *)value {
    ESBCCommonResult *response = [ESBCCommonResult parse:value];
    ESBCCommandType rsp = self.expectRspDict[@(self.command)].integerValue;
    if (response.command != rsp || response.packetSeqNum != self.packetSeqNum) {
        return;
    }
    //分片的, 不完整,并且是第一帧,存储下来作为基础帧
    if (!response.completed && response.firstFrame) {
        self.baseFrame = response;
    }
    //存在基础帧
    if (self.baseFrame) {
        ///不可以合并当前帧, 丢弃,重启请求下一帧
        if (![self.baseFrame merge:response]) {
            [self requestNextFrame];
            return;
        }
        ///合并了新的帧
        ///还不全
        if (!self.baseFrame.completed) {
            [self requestNextFrame];
            return;
        }
        ///全了,进入下一流程, 分发到delegate
        response = self.baseFrame;
        self.baseFrame = nil;
    }
    NSDictionary *dict = nil;
    if (self.beforeParseJson) {
        dict = self.beforeParseJson(response.json);
        ESDLog(@"[Bluetooth] plain response %@", [dict yy_modelToJSONString]);
    }    else {
        dict = [response.json toJson];
    }

  
    self.packetSeqNum++;
    switch (self.command) {
        case ESBCCommandTypeInitReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onInit:)]) {
                ESBindInitResp * respModel = [ESBindInitResp yy_modelWithJSON:dict];
                [self.delegate onInit:respModel];
            }
        } break;
        case ESBCCommandTypeWifiListReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onWifi:)]) {
                [self.delegate onWifi:[[ESRspWifiListRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypeWifiPwdReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onWifiStatus:)]) {
                [self.delegate onWifiStatus:[[ESRspWifiStatusRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypeRevokeReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onRevoke:)]) {
                [self.delegate onRevoke:[[ESRspMicroServerRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypePairReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onPair:)]) {
                [self.delegate onPair:[[ESRspMicroServerRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypeSetAdminPwdReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onSetAdminPwd:)]) {
                [self.delegate onSetAdminPwd:[[ESRspMicroServerRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypeInitialReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onInitial:)]) {
                [self.delegate onInitial:[[ESRspMicroServerRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypePubKeyExchangeReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onPubKeyExchange:)]) {
                [self.delegate onPubKeyExchange:[[ESRspPubKeyExchangeRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypeKeyExchangeReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onAESKeyExchange:)]) {
                [self.delegate onAESKeyExchange:[[ESRspKeyExchangeRsp alloc] initWithDictionary:dict error:nil]];
            }
        } break;
        case ESBCCommandTypePassthroughReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[安保功能] passthrough rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onPassthrough:)]) {
                [self.delegate onPassthrough:dict];
            }
        } break;

            
        case ESBCCommandTypeSpaceReadyCheckReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] SpaceReadyCheckReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onSpaceCheckReady:)]) {
                ESSpaceReadyCheckResp * model = [ESSpaceReadyCheckResp yy_modelWithJSON:dict];
                [self.delegate onSpaceCheckReady:model];
            }
        } break;
        case ESBCCommandTypeDiskRecognitionReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] DiskRecognitionReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onDiskRecognition:)]) {
                ESDiskRecognitionResp * model = [ESDiskRecognitionResp yy_modelWithJSON:dict];
                [self.delegate onDiskRecognition:model];
            }
        } break;
        case ESBCCommandTypeDiskInitializeReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] DiskInitializeReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onDiskInitialize:)]) {
                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
                [self.delegate onDiskInitialize:model];
            }
        } break;
        case ESBCCommandTypeDiskInitializeProgressReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] DiskInitializeProgressReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onDiskInitializeProgress:)]) {
                ESDiskInitializeProgressResp * model = [ESDiskInitializeProgressResp yy_modelWithJSON:dict];
                [self.delegate onDiskInitializeProgress:model];
            }
        } break;
        case ESBCCommandTypeDiskManagementListReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] ManagementListReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onDiskManagementList:)]) {
                ESDiskManagementListResp * model = [ESDiskManagementListResp yy_modelWithJSON:dict];
                [self.delegate onDiskManagementList:model];
            }
        } break;
        case ESBCCommandTypeSystemShutdownReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[系统启动] SystemShutdownReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onSystemShutdown:)]) {
                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
                [self.delegate onSystemShutdown:model];
            }
        } break;
        case ESBCCommandTypeUpdataNetworkConfigReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[网络配置] UpdataNetworkConfigReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onUpdataNetworkConfig:)]) {
                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
                [self.delegate onUpdataNetworkConfig:model];
            }
        } break;
        case ESBCCommandTypeGetNetworkConfigReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[网络配置] GetNetworkConfigReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onGetNetworkConfig:)]) {
                ESBoxNetworkConfigResp * model = [ESBoxNetworkConfigResp yy_modelWithJSON:dict];
                [self.delegate onGetNetworkConfig:model];
            }
        } break;
        case ESBCCommandTypeIgnoreNetworkConfigReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[网络配置] IgnoreNetworkConfigReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onIgnoreNetworkConfig:)]) {
                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
                [self.delegate onIgnoreNetworkConfig:model];
            }
        } break;
        case ESBCCommandTypeDeviceAbilityReq: {
            self.command = ESBCCommandTypeNone;
            ESDLog(@"[设备信息] ESBCCommandTypeDeviceAbilityReq rsp by ble:%@", dict);
            self.payloadStr = nil;
            if ([self.delegate respondsToSelector:@selector(onDeviceAbility:)]) {
                ESDeviceAbilityResp * model = [ESDeviceAbilityResp yy_modelWithJSON:dict];
                [self.delegate onDeviceAbility:model];
            }
        } break;
        // 社区
        case ESSwithPlatformReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onDomin:)]) {
                [self.delegate onDomin:dict];
            }
        } break;
//        case ESBCCommandTypeBindInitReq: {
//            self.command = ESBCCommandTypeNone;
//            self.payload = nil;
//            if ([self.delegate respondsToSelector:@selector(onSpaceStartInitialize:)]) {
//                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
//                [self.delegate onSpaceStartInitialize:model];
//            }
//        } break;
        case ESBCCommandTypeBindComStartReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                ESBaseResp * model = [ESBaseResp yy_modelWithJSON:dict];
                [self.delegate onBindCommand:ESBCCommandTypeBindComStartReq  resp:model];
            }
        } break;
        case ESBCCommandTypeBindComProgressReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                [self.delegate onBindCommand:ESBCCommandTypeBindComProgressReq  resp:dict];
            }
        } break;
        case ESBCCommandTypeBindInternetServiceConfigReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                [self.delegate onBindCommand:ESBCCommandTypeBindInternetServiceConfigReq  resp:dict];
            }
        } break;
        case ESBCCommandTypeBindSpaceCreateReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                [self.delegate onBindCommand:ESBCCommandTypeBindSpaceCreateReq  resp:dict];
            }
        } break;
        case ESBCCommandTypeBindPasswordVerifyReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                [self.delegate onBindCommand:ESBCCommandTypeBindPasswordVerifyReq  resp:dict];
            }
        } break;
        case ESBCCommandTypeBindRevokeReq: {
            self.command = ESBCCommandTypeNone;
            self.payload = nil;
            if ([self.delegate respondsToSelector:@selector(onBindCommand:resp:)]) {
                [self.delegate onBindCommand:ESBCCommandTypeBindRevokeReq  resp:dict];
            }
        } break;
        default: {
        } break;
    }
}

- (void)bluetooth:(ESBluetoothItem *)bluetooth onClose:(NSError *)error {
    self.item = nil;
    if ([self.delegate respondsToSelector:@selector(onClose:)]) {
        [self.delegate onClose:error];
    }
    if (self.command != ESBCCommandTypeNone) {
        weakfy(self);
        [self discoverCharacteristics:^(ESBluetoothItem *item) {
            strongfy(self);
            [self sendCommand:self.command payload:self.payload];
        }];
    }
}

- (void)discoverCharacteristics:(void (^)(ESBluetoothItem *item))onConnection {
    weakfy(self);
    [ESBluetoothManager.manager prepare:^(BOOL done) {
        strongfy(self);
        if (!done) {
            if (onConnection) {
                onConnection(nil);
            }
            if ([self.delegate respondsToSelector:@selector(onConnection:)]) {
                [self.delegate onConnection:nil];
            }
            return;
        }
        [ESBluetoothManager.manager scanPeripheral:self.serviceUUID
                                         localName:self.localName
                                      onConnection:^(ESBluetoothItem *item) {
                                          self.item = item;
                                          if (onConnection) {
                                              onConnection(self.item);
                                          }
                                          if ([self.delegate respondsToSelector:@selector(onConnection:)]) {
                                              [self.delegate onConnection:item];
                                          }
                                      }];
    }];
}

- (void)connection:(NSString *)serviceUUID name:(NSString *)name {
    ESBluetoothManager.manager.delegate = self;
    self.serviceUUID = serviceUUID;
    self.localName = name;
    [self discoverCharacteristics:nil];
}

- (void)sendCommand:(ESBCCommandType)command payload:(NSDictionary *)payload {
    ///1. 有蓝牙连接
    ///1. 没有正在发送的命令
    if (!self.item || self.command != ESBCCommandTypeNone) {
        return;
    }
    NSParameterAssert(self.serviceUUID);
    NSParameterAssert(self.expectRspDict[@(command)]);
    self.command = command;
    self.payload = payload;
    if (self.command == ESBCCommandTypeNone) {
        return;
    }
    ESDLog(@"[Bluetooth] Send Command [%@] payload :\n%@\n", nameOfCommand(command), [payload yy_modelToJSONString] ?: @"");
    if (!self.item) {
        [self discoverCharacteristics:^(ESBluetoothItem *item) {
            [self sendCommand:self.command payload:self.payload];
        }];
        return;
    }
    NSString *json = [payload yy_modelToJSONString];
    if (json.length > 240) {
        [self sendMultiFrame:json command:command];
        return;
    }
    ESBCCommand *cmd = [ESBCCommand command:command payload:json packetSeqNum:self.packetSeqNum];
    [ESBluetoothManager.manager writeValue:cmd.body];
}

- (void)sendCommand:(ESBCCommandType)command payloadStr:(NSString *)payloadStr {
    ///1. 有蓝牙连接
    ///1. 没有正在发送的命令
    if (!self.item || self.command != ESBCCommandTypeNone) {
        return;
    }
    NSParameterAssert(self.serviceUUID);
    NSParameterAssert(self.expectRspDict[@(command)]);
    self.command = command;
    self.payloadStr = payloadStr;
    if (self.command == ESBCCommandTypeNone) {
        return;
    }
    ESDLog(@"[Bluetooth] Send Command [%@] payload :\n%@\n", nameOfCommand(command), payloadStr ?: @"");
    if (!self.item) {
        [self discoverCharacteristics:^(ESBluetoothItem *item) {
            [self sendCommand:self.command payloadStr:self.payloadStr];
        }];
        return;
    }
    NSString *json = payloadStr;
    if (json.length > 240) {
        [self sendMultiFrame:json command:command];
        return;
    }
    ESBCCommand *cmd = [ESBCCommand command:command payload:json packetSeqNum:self.packetSeqNum];
    [ESBluetoothManager.manager writeValue:cmd.body];
}

- (void)sendMultiFrame:(NSString *)total command:(ESBCCommandType)command {
    NSMutableArray *parts = NSMutableArray.array;
    NSInteger index = 0;
    NSUInteger partSize = 240;
    while (index <= total.length) {
        NSString *part = [total substringWithRange:NSMakeRange(index, MIN(partSize, total.length - index))];
        [parts addObject:part];
        index += partSize;
    }
    self.multipart = parts;
    [self.multipart enumerateObjectsUsingBlock:^(NSString *_Nonnull part,
                                                 NSUInteger idx,
                                                 BOOL *_Nonnull stop) {
        [self sendFrame:self.multipart frameIndex:idx command:command];
        usleep(50 * 1000);
    }];
}

- (void)sendFrame:(NSArray<NSString *> *)parts frameIndex:(NSUInteger)frameIndex command:(ESBCCommandType)command {
    ESBCCommand *cmd = [ESBCCommand command:command
                                    reserve:ESBCCommandReserveSendMultipart
                                    payload:parts[frameIndex]
                               packetSeqNum:self.packetSeqNum
                                 frameCount:parts.count
                                 frameIndex:frameIndex];
    [ESBluetoothManager.manager writeValue:cmd.body];
}

- (void)reset {
    [ESBluetoothManager.manager stopScan];
    ESBluetoothManager.manager.delegate = self;
    self.serviceUUID = nil;
    self.item = nil;
    self.payload = nil;
    self.command = ESBCCommandTypeNone;
    self.packetSeqNum = 0;
}

- (void)resetForTimeout:(ESBCCommandType)command {
    if (self.command == command) {
        self.command = ESBCCommandTypeNone;
        self.payload = nil;
    }
}

@end
