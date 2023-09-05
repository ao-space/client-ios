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
//  ESBluetoothCommunication.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBCResult.h"
#import "ESBoxStatusItem.h"
#import <Foundation/Foundation.h>
#import "ESBindInitResp.h"
#import "ESBoxWifiModel.h"

@class ESBluetoothItem;
@class ESPairingBoxInfo;
@protocol ESBluetoothCommunicationDelegate <NSObject>

@optional

- (void)onConnection:(ESBluetoothItem *)item;
- (void)onClose:(NSError *)error;

- (void)onPubKeyExchange:(ESRspPubKeyExchangeRsp *)response;
- (void)onAESKeyExchange:(ESRspKeyExchangeRsp *)response;
- (void)onInit:(ESBindInitResp *)response;

- (void)onWifi:(ESRspWifiListRsp *)response;
- (void)onWifiStatus:(ESRspWifiStatusRsp *)response;

- (void)onRevoke:(ESRspMicroServerRsp *)response;
- (void)onPair:(ESRspMicroServerRsp *)response;

- (void)onSetAdminPwd:(ESRspMicroServerRsp *)response;
- (void)onInitial:(ESRspMicroServerRsp *)response;
- (void)onPassthrough:(NSDictionary *)response;

- (void)onSpaceCheckReady:(ESSpaceReadyCheckResp *)response;
- (void)onDiskRecognition:(ESDiskRecognitionResp *)response;
- (void)onDiskInitializeProgress:(ESDiskInitializeProgressResp *)response;
- (void)onDiskInitialize:(ESBaseResp *)response;
- (void)onSystemShutdown:(ESBaseResp *)response;
- (void)onDiskManagementList:(ESDiskManagementListResp *)response;

- (void)onUpdataNetworkConfig:(ESBaseResp *)respone;
- (void)onGetNetworkConfig:(ESBoxNetworkConfigResp *)respone;
- (void)onIgnoreNetworkConfig:(ESBaseResp *)respone;
- (void)onDeviceAbility:(ESDeviceAbilityResp *)response;

- (void)onDomin:(NSDictionary *)response;
-(void)onDominChange:(NSDictionary *)response;

- (void)onBindCommand:(ESBCCommandType)command resp:(id)response;

@end

@interface ESBluetoothCommunication : NSObject

+ (instancetype)shared;

@property (nonatomic, weak) id<ESBluetoothCommunicationDelegate> delegate;

- (void)reset;

- (void)resetForTimeout:(ESBCCommandType)command;
@end
