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
//  ESRSA.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSA.h"
#import <openssl/rsa.h>

@interface ESRSA ()

@property (nonatomic, copy) NSString *pem;

@property (nonatomic, assign) RSA *rsaKey;

@end

@implementation ESRSA

- (instancetype)init {
    self = [super init];
    if (self) {
        _padding = RSA_PKCS1_PADDING;
    }
    return self;
}

+ (instancetype)fromRSA:(RSA *)rsa pem:(NSString *)pem {
    ESRSA *item = [ESRSA new];
    item.rsaKey = rsa;
    item.pem = pem;
    return item;
}

@end
