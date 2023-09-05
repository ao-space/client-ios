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
//  ESBoxItem.h
//  ESBoxItem
//
//  Created by Ye Tao on 2021/8/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPairingBoxInfo.h"
#import "ESTokenItem.h"
#import <Foundation/Foundation.h>
#import "ESBindInitResp.h"
#import "ESBoxIPModel.h"

#import "ESAccountServiceApi.h"

typedef NS_ENUM(NSUInteger, ESBoxType) {
    ESBoxTypePairing, //配对的盒子
    ESBoxTypeAuth,    //授权的盒子, 只有accesToken + {aeskey + iv }
    ESBoxTypeMember,  //邀请的成员
};

typedef NS_ENUM(NSUInteger, ESDiskInitStatus) {
    ESDiskInitStatusNormal = 1, // 磁盘正常
    ESDiskInitStatusNotInit = 2, // 未初始化
    ESDiskInitStatusFormatting = 3, // 正在格式化
    ESDiskInitStatusSynchronizingData = 4, // 正在数据同步
    
    ESDiskInitStatusError = 100, // 未知错误
    ESDiskInitStatusFormatError = 101, // 磁盘格式化错误; >101: 其他初始化错误;
};

@class ESApiClient;
@class ESCreateTokenResult;
@interface ESBoxItem : NSObject <NSCopying>
// 保存 call 接口请求回来的数据，与 绑定过程 中 pair/init 中拿到的进行区分
@property (nonatomic, strong) ESDeviceAbilityModel * deviceAbilityModel;
/// 配对时获取的数据
@property (nonatomic, strong, readonly) ESPairingBoxInfo *info;
// 绑定过程中初始化的得到的数据
@property (nonatomic, strong) ESBindInitResultModel * bindInitResultModel;
// 保存盒子IP的信息
@property (nonatomic, strong) ESBoxIPResp * boxIPResp;
///从info获取的, 方便读取
@property (nonatomic, copy, readonly) NSString *boxUUID;

///扫描二维码获取，保存在此，便于使用
@property (nonatomic, copy) NSString *btid;

///从info获取的, 方便读取
@property (nonatomic, copy, readonly) NSString *name;

/// 盒子类型,
/// 
@property (nonatomic, readonly) ESBoxType boxType;

// 磁盘状态
@property (nonatomic, assign) ESDiskInitStatus diskInitStatus;

// 硬件盒子类型
@property (nonatomic, assign) ESBoxGenEnum boxGenEnum;

///授权方授权给出的临时token
@property (nonatomic, strong, readonly) ESTokenItem *authToken;

///指定该盒子调用的客户端
@property (nonatomic, weak) ESApiClient *apiClient;

///盒子是否在线
@property (nonatomic, readonly) BOOL offline;
@property (nonatomic, assign) BOOL showTrailUnvalied;

@property (nonatomic, assign) BOOL enableInternetAccess;
@property (nonatomic, copy) NSString *localHost;

//所有绑定信息跟盒子不直接相关，应该收敛成一个model
///判断是授权的盒子还是配对的盒子
@property (nonatomic, readonly) BOOL auth;
@property (nonatomic, assign) BOOL supportNewBindProcess;
@property (nonatomic, copy) NSString *spaceName;

//@property (nonatomic, assign) BOOL checkingLocalAcesss;

@property (nonatomic, copy, readonly) NSString *aoid;
@property (nonatomic, strong) NSString * platformUrl;

@property (nonatomic, copy, readonly) NSString *uniqueKey;
@property (nonatomic, copy) NSString *bindUserName; //盒子绑定用户自定义名字
@property (nonatomic, copy) NSString *bindUserHeadImagePath; //盒子绑定用户自定义头像

@property (nonatomic, strong) NSArray<ESAccountInfoResult> *results; //盒子成员信息


+ (instancetype)fromPairing:(ESPairingBoxInfo *)info;

+ (instancetype)fromAuth:(NSDictionary *)data;

+ (instancetype)fromInviteMemberWithBoxUUID:(NSString *)boxUUID
                                    authKey:(NSString *)authKey
                                 userDomain:(NSString *)userDomain
                                       aoid:(NSString *)aoid;

- (NSString *)prettyDomain;

- (NSString *)getPersonalName;

- (BOOL)hasInnerDiskSupport;

- (void)setOffline:(BOOL)offline;

@end
