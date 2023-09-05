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
//  ESBoxIPModel.h
//  EulixSpace
//
//  Created by dazhou on 2023/3/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBaseResp.h"

NS_ASSUME_NONNULL_BEGIN

@class ESBoxIPModel;
@interface ESBoxIPResp : ESBaseResp
@property (nonatomic, strong) NSMutableArray<ESBoxIPModel *> * results;

// 重置是否检测过 IP 直连
- (void)resetCheckState;

- (BOOL)hasBoxIp;
- (ESBoxIPModel *)getConnectedBoxIP;
- (NSString *)toString;
@end

@class ESBoxItem;
@interface ESBoxIPModel : NSObject
@property(nonatomic, strong) NSString * ip;

@property(nonatomic, assign) long port;

@property(nonatomic, assign) long tlsPort;

@property(nonatomic, strong) NSString* wifiName;
/* 有线 [optional]
 */
@property(nonatomic, assign) BOOL wire;



// 标记 IP 是否与 盒子 处于直连状态，本地不保存该字段
@property (nonatomic, assign) BOOL ipConnected;
// 标记当次是否检测过 IP 是否连通，本地不保存该字段
@property (nonatomic, assign) BOOL ipChecked;

- (NSString *)getIPDomain;
@end

NS_ASSUME_NONNULL_END
