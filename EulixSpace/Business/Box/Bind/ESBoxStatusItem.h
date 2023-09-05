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
//  ESBoxStatusItem.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBCResult.h"
#import "ESPairingBoxInfo.h"
#import "ESAdminBindResult.h"
#import "ESNetApi.h"
#import "ESPairApi.h"
#import "ESResponseBaseString.h"
#import <Foundation/Foundation.h>
#import "ESBaseResp.h"
#import "ESNotifiResp.h"
#import "ESDiskRecognitionResp.h"
#import "ESBindInitResp.h"

@class ESSecurityPasswordResetBinderRsp;

@interface ESBoxStatusItem : NSObject

@property (nonatomic, strong, readonly) ESBindInitResultModel *infoResult;

@property (nonatomic, strong, readonly) NSArray<ESWifiListRsp *> *wifiResult;

@property (nonatomic, strong, readonly) ESResponseBasePasswdTryInfo *revokeResult;

@property (nonatomic, strong, readonly) ESWifiStatusRsp *wifiStatusResult;

@property (nonatomic, strong, readonly) ESMicroServerRsp *adminPwdResult;

@property (nonatomic, strong, readonly) ESAdminBindResult *pairResult;

@property (nonatomic, strong, readonly) ESRspMicroServerRsp *initialResult;

@property (nonatomic, strong, readonly) ESKeyExchangeRsp *keyExchangeRsp;

@property (nonatomic, strong, readonly) ESPubKeyExchangeRsp *pubKeyExchange;

@property (nonatomic, strong) ESSecurityPasswordResetBinderRsp * resetPasswdRsp;
@end



@interface ESPassthroughReq : NSObject
@property (nonatomic, strong) NSString * apiName;
@property (nonatomic, strong) NSString * serviceName;
@property (nonatomic, strong) NSString * apiPath;
@property (nonatomic, strong) NSString * apiVersion;
@end


@interface ESSecurityPasswordResetModel : NSObject
//登录网关后授权令牌
@property (nonatomic, strong) NSString * accessToken;
//新密码
@property (nonatomic, strong, getter=theNewPasswd) NSString * newPasswd;

// 绑定端允许拿到的 securityToken ，仅用于 授权端
@property (nonatomic, strong) NSString * acceptSecurityToken;
// 绑定端的 clientUuid ，仅用于 授权端
@property (nonatomic, strong) NSString * clientUuid;
// 本次申请的id ，仅用于 授权端
@property (nonatomic, strong) NSString * applyId;


//邮箱验证通过拿到的 securityToken
@property (nonatomic, strong) NSString * emailSecurityToken;
// 新设备的 clientUuid
@property (nonatomic, strong, getter=theNewDeviceClientUuid) NSString * newDeviceClientUuid;
@end

// 通过蓝牙或局域网重置安全密码
@interface ESSecurityPasswordResetBinderReq : ESPassthroughReq
@property (nonatomic, strong) ESSecurityPasswordResetModel * entity;
@end

@interface ESSecurityPasswordResetBinderRsp : ESBaseResp
@property (nonatomic, strong) ESBaseResp * results;
@end


@interface ESSecurityEmailSetModel : NSObject
//登录网关后授权令牌
@property (nonatomic, strong) NSString * accessToken;
@property (nonatomic, strong) NSString * emailAccount;
@property (nonatomic, strong) NSString * emailPasswd;//新邮箱密码,使用16进制Hex编码
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * port;
@property (nonatomic, assign) BOOL sslEnable;

- (BOOL)hasBoundSecurityEmail;

@end

// 通过蓝牙或局域网设置密保邮箱
@interface ESSecurityEmailSetReq : ESPassthroughReq
@property (nonatomic, strong) ESSecurityEmailSetModel * entity;
@end


@interface ESSecurityEmailSetRsp : ESBaseResp
@property (nonatomic, strong) ESBaseResp * results;
@end

@interface ESNewDeviceApplyModel : NSObject
@property (nonatomic, strong) NSString * deviceInfo;//设备类型
@property (nonatomic, strong) NSString * clientUuid;//新设备的 clientUuid
@property (nonatomic, strong) NSString * applyId;//本次申请的id

@end

@interface ESNewDeviceApplyReq : ESPassthroughReq
@property (nonatomic, strong) ESNewDeviceApplyModel * entity;
@end


@interface ESNewDeviceAuthApplyRsp : ESBaseResp
@property (nonatomic, strong) NSArray<ESAuthApplyRsp *> * results;
@end

@interface ESNewDeviceLocalRsp : ESBaseResp
@property (nonatomic, strong) ESNewDeviceAuthApplyRsp * results;
@end



@interface ESSecurityMessagePollModel : NSObject
@property (nonatomic, strong) NSString * clientUuid;//发起请求者的 clientUuid
@end

@interface ESSecurityMessagePollReq : ESPassthroughReq
@property (nonatomic, strong) ESSecurityMessagePollModel * entity;
@end


@interface ESSecurityEmailVerityModel : NSObject
@property (nonatomic, strong) NSString * emailAccount;
@property (nonatomic, strong) NSString * emailPasswd;//邮箱密码,使用16进制Hex编码
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * port;
@property (nonatomic, assign) BOOL sslEnable;
@property (nonatomic, strong) NSString * clientUuid;//发起请求者的 clientUuid


@end
@interface ESSecurityEmailVerityReq : ESPassthroughReq
@property (nonatomic, strong) ESSecurityEmailVerityModel * entity;

@end


@interface ESSecurityEmailVerityRspModel : ESBaseResp
@property (nonatomic, strong) NSString * securityToken;
@property (nonatomic, strong) NSString * expiredAt;

@end

@interface ESSecurityEmailVerityRsp : ESBaseResp
@property (nonatomic, strong) ESSecurityEmailVerityRspModel * results;
@end
