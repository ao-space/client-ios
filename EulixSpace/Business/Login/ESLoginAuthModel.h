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
//  ESLoginAuthModel.h
//  EulixSpace
//
//  Created by dazhou on 2023/3/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBaseResp.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESLoginAuthModel : NSObject

@end

@interface ESAuthBkeyCreateModel : NSObject
// 使用对称密钥加密的授权码 (4或6 位数字)。
@property (nonatomic, strong) NSString * authCode;
// 使用对称密钥加密的 bkey, 盒子侧用的 key， 用来对应手机端和跳转后的盒子页面前端
@property (nonatomic, strong) NSString * bkey;
// 使用对称密钥加密的
@property (nonatomic, strong) NSString * userDomain;
// 使用对称密钥加密的
@property (nonatomic, strong) NSString * lanDomain;
// 使用对称密钥加密的
@property (nonatomic, strong) NSString * lanIp;
// 剩余有效时间，单位是毫秒
@property (nonatomic, assign) long authCodeExpiresAt;
// 总共的时间，单位是毫秒
@property (nonatomic, assign) long authCodeTotalExpiresAt;
@end

@interface ESAuthBkeyCreateResp : ESBaseResp
@property (nonatomic, strong) ESAuthBkeyCreateModel * authCodeInfo;
@end

NS_ASSUME_NONNULL_END
