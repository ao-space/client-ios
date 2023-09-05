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
//  ESRSACenter.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSA.h"
#import "ESRSAPair+openssl.h"
#import <Foundation/Foundation.h>

/// ESRSAPair *pair = ESRSACenter.defaultPair;
/// NSLog(@"pair.publicKey.pem : \n%@", pair.publicKey.pem);
/// NSLog(@"pair.publicKey.pem : \n%@", pair.privateKey.pem);

extern NSString *const kESRSACenterDefaultPeerId;

@interface ESRSACenter : NSObject

/// 自己的公私钥对
@property (class, nonatomic, readonly) ESRSAPair *defaultPair;

+ (instancetype)defaultCenter;

/// 获取`boxUUID` 对应的公钥信息
/// @param boxUUID 盒子的唯一标识
+ (ESRSAPair *)boxPair:(NSString *)boxUUID;

/// 添加盒子的公钥信息
/// @param publicPem 公钥内容
/// @param boxUUID 盒子的唯一标识
- (ESRSAPair *)addBoxPublicPem:(NSString *)publicPem boxUUID:(NSString *)boxUUID;

/// 删除boxUUID 对应的公钥信息
/// @param boxUUID 盒子的唯一标识
- (void)removeBoxPublicPem:(NSString *)boxUUID;

@end
