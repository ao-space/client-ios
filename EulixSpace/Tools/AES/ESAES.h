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
//  ESAES.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ESAES)
// 不提供直接使用的方法
//- (NSData *)aes_cbc_encryptWithKey:(NSData *)keyData;
//
//- (NSData *)aes_cbc_decryptWithKey:(NSData *)keyData;

@end

@interface NSString (ESAES)

/// 使用 aes 解密
/// @param keyString 对称密钥
/// @param ivString base64 编码后的initializationVector
- (NSString *)aes_cbc_decryptWithKey:(NSString *)keyString iv:(NSString *)ivString;

/// 使用 aes 加密
/// @param keyString 对称密钥
/// @param ivString base64 编码后的initializationVector
- (NSString *)aes_cbc_encryptWithKey:(NSString *)keyString iv:(NSString *)ivString;

@end
