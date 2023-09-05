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
//  ESECkeyUtils.h
//  EulixSpace
//
//  Created by qu on 2021/6/17.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECkeyPairs : NSObject

/**
 私钥PEM
 */
@property (nonatomic, strong) NSString *privatePem;

/**
 公钥PEM
 */
@property (nonatomic, strong) NSString *publicPem;

/**
 三方公钥
 */
@property (nonatomic, strong) NSString *peerPublicPem;

/**
 生成的协商密钥
 */
@property (nonatomic, strong) NSString *shareKey;

@end

@interface ESECkeyUtils : NSObject

@property (nonatomic, strong) ECkeyPairs *eckeyPairs;

/**
 生成ECC(椭圆曲线加密算法)的私钥和公钥
 */
- (void)generatekeyPairs;
- (void)generatekeyPairs_Secp256r1;

/**
 根据三方公钥和自持有的私钥经过DH(Diffie-Hellman)算法生成的协商密钥

 @param peerPubPem 三方公钥
 @param privatePem 自持有私钥
 @param length 协商密钥长度
 @return 协商密钥
 */
+ (NSString *)getShareKeyFromPeerPubPem:(NSString *)peerPubPem
                             privatePem:(NSString *)privatePem
                                 length:(int)length;
@end

NS_ASSUME_NONNULL_END
