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
//  ESBoxManager.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxItem.h"
#import <Foundation/Foundation.h>

static NSString *const kESBoxActiveMessage = @"kESBoxActiveMessage";

@interface ESBoxManager : NSObject

+ (instancetype)manager;

/// 所有的盒子列表
@property (class, nonatomic, readonly) NSArray<ESBoxItem *> *bindBoxArray;

/// 当前使用的盒子
@property (class, nonatomic, readonly) ESBoxItem *activeBox;

///刚刚启动
@property (nonatomic, assign) BOOL justLaunch;

///当前使用的盒子的信息

@property (class, nonatomic, copy, readonly) NSString *clientUUID;

@property (class, nonatomic, copy, readonly) NSString *deviceToken;

/// 备用, 之前推送时用到,
/// 现在只有配对才有clientUUID , 所以推送时用的是deviceId
@property (class, nonatomic, copy, readonly) NSString *deviceId;

///当前使用的盒子的信息
@property (class, nonatomic, copy, readonly) NSString *realdomain;



/// 存储deviceToken
/// @param deviceToken push的token
+ (void)onRegisterDeviceToken:(NSString *)deviceToken;

/// 盒子列表激活某个盒子
/// @param info 需要激活的盒子信息
+ (void)onActive:(ESBoxItem *)info;

/// `配对`某个盒子后需要调用
/// 会记录盒子信息, 并且加入到`bindBoxArray`
/// @param info `配对`盒子信息
+ (void)onParing:(ESPairingBoxInfo *)info;

+ (ESBoxItem *)onJustParing:(ESPairingBoxInfo *)info
                  spaceName:(NSString *)spaceName
       enableInternetAccess:(BOOL)enableInternetAccess
                  localHost:(NSString *)localHost
                        btid:(NSString *)btid
                  diskStatus:(ESDiskInitStatus)diskInitStatus
                        init:(ESBindInitResultModel *)initResult;

+ (void)onParing:(ESPairingBoxInfo *)info
            btid:(NSString *)btid
      diskStatus:(ESDiskInitStatus)diskInitStatus
            init:(ESBindInitResultModel *)initResult;

/// `授权`盒子后需要调用
/// 会记录盒子信息, 并且加入到`bindBoxArray`
/// @param info `授权`盒子信息
+ (void)onAuth:(ESBoxItem *)info;

/// `邀请成员` 盒子后需要调用
/// 会记录盒子信息, 并且加入到`bindBoxArray`
/// @param info `邀请成员`盒子信息
+ (void)onInviteMember:(ESBoxItem *)info;

//只换成成员盒子信息，不active box
+ (ESBoxItem *)newOnInviteMember:(ESBoxItem *)info;
+ (ESBoxItem *)onJustInviteMember:(ESBoxItem *)info;

/// 获取某个盒子是否可以访问
/// @param box 需要访问的盒子
/// @param completion offline  == YES 离线  offline  == NO 在线
+ (void)loadOnlineState:(ESBoxItem *)box completion:(void (^)(BOOL offline))completion;
+ (void)checkBoxStateByIP:(NSString *)ipDomain completion:(void (^)(BOOL offline))completion;
+ (void)checkBoxStateByDomain:(void (^)(BOOL offline))completion;


/// 解绑某个盒子
/// 1.会从盒子列表中删除
/// 2.如果是当前使用的盒子,会`自动`跳到盒子列表
/// @param info 盒子信息
+ (void)revoke:(ESBoxItem *)info;
- (void)justRevoke:(ESBoxItem *)info;

///  判断某个盒子是否已经绑定
/// @param boxUUID boxUUID
+ (BOOL)boxExist:(NSString *)boxUUID;

- (void)getFamilyList:(ESBoxItem *)info;

+ (NSDictionary *)cacheInfoForBox:(ESBoxItem *)box;

- (void)loadCurrentBoxOnlineState:(void (^)(BOOL offline))completion;

- (void)markBoxActive:(ESBoxItem *)box;
/**
 局域网可用时，设置老的网络库中的 baseURL 为 IP
 该方法目的是替换掉 markBoxActive 中部分功能，
 因为这个方法调用生效需要先将 box 中的 userDomain 替换成 IP 格式，这容易将原来的 domain 覆盖，很容易出问题
 */
- (void)setBoxIPConnect:(NSString *)ipDomain;

- (void)saveBoxList;
- (void)saveBox:(ESBoxItem *)box;

- (ESBoxItem *)getBoxItemWithBoxUuid:(NSString *)boxUuid
                             boxType:(ESBoxType)boxType
                                aoid:(NSString *)aoid;
- (ESBoxItem *)getBoxItemWithUserDomain:(NSString *)userDomain;

-(void)removeBoxList:(ESBoxItem *)item;

- (void)revokePush:(ESBoxItem *)info;

- (void)reqDeviceAbility:(void (^)(ESDeviceAbilityModel * model))successBlock fail:(void (^)(NSError * error))failBlock;

-(void)onActive:(ESBoxItem *)box;

- (NSString *)getAoidValue;

- (ESBoxIPResp *)getBoxIpResp;
- (void)saveBoxIp:(ESBoxItem *)box boxIP:(ESBoxIPResp *)boxIP;
- (void)reqBtid:(ESBoxItem *)item;

- (BOOL)pairingBoxCachedWithUUID:(NSString *)boxUUID;

- (void)setClientUUIDCookie:(NSString *)domain;

- (void)saveBoxUserDomain:(ESBoxItem *)box;
- (void)setAllBoxCookie;

- (void)cleanBoxsInfo;

@end
