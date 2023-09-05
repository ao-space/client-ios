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
//  ESRSAPair+openssl.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSAPair.h"

@class ESRSAPair;

@interface ESRSAPair (ESOpenssl)

/// 生成`keySize` 长度的公私钥对
/// @param keySize 1024 或者2048 , 目前项目里用2048
+ (ESRSAPair *)generateRSAKeyPairWithKeySize:(int)keySize;

/// 用 公钥 加密
/// @param plainText 待加密的 明文
- (NSString *)publicEncrypt:(NSString *)plainText;

/// 用公钥 解密
/// @param cipherText 待解密的 密文
- (NSString *)publicDecrypt:(NSString *)cipherText;

/// 用私钥 解密
/// @param cipherText 待解密的 密文
- (NSString *)privateDecrypt:(NSString *)cipherText;

/// 用私钥 加密
/// @param plainText 待加密的 明文
- (NSString *)privateEncrypt:(NSString *)plainText;

/// 从 pem 文件内容 生成公/私钥
/// @param KeyPEM pem 文件内容
/// @param isPubkey 是否是公钥
+ (ESRSA *)keyFromPEM:(NSString *)KeyPEM isPubkey:(BOOL)isPubkey;

/// 用自己的私钥签名
/// @param plainText 待签名的 明文
- (NSString *)sign:(NSString *)plainText;

/// /// 用自己的公钥验证签名
/// @param text 待验证的签名的 密文
/// @param plainText 待验证签名的 明文
- (BOOL)verifySignature:(NSString *)text plainText:(NSString *)plainText;

/**
 检查公钥的格式，如果没有头尾部信息，则补上，不然加密结果为nil
 */
+ (NSString *)checkPublicKey:(NSString *)KeyPEM;

@end
