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
//  ESRSAPair.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSAPair.h"
#import "ESRSA.h"
#import "ESRSAPair+openssl.h"

@interface ESRSAPair ()

@property (nonatomic, copy) NSString *peerId;

@property (nonatomic, strong) ESRSA *publicKey;

@property (nonatomic, strong) ESRSA *privateKey;

@end

@implementation ESRSAPair

+ (instancetype)pairWithPublicKey:(ESRSA *)publicKey
                       privateKey:(ESRSA *)privateKey {
    ESRSAPair *pair = [ESRSAPair new];
    pair.publicKey = publicKey;
    pair.privateKey = privateKey;
    return pair;
}

- (NSString *)description {
    NSMutableString *result = NSMutableString.string;
    if (_publicKey.pem) {
        [result appendString:_publicKey.pem];
        [result appendString:@"\n"];
    }
    if (_privateKey.pem) {
        [result appendString:_privateKey.pem];
        [result appendString:@"\n"];
    }
    return result;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *result = NSMutableDictionary.dictionary;
    result[@"peerId"] = _peerId;
    result[@"publicPem"] = _publicKey.pem;
    result[@"privatePem"] = _privateKey.pem;
    return result;
}

+ (instancetype)fromJson:(NSDictionary *)json {
    NSString *peerId = json[@"peerId"];
    NSString *publicPem = json[@"publicPem"];
    NSString *privatePem = json[@"privatePem"];

    ESRSAPair *pair = [ESRSAPair pairWithPublicKey:[ESRSAPair keyFromPEM:publicPem isPubkey:YES]
                                        privateKey:[ESRSAPair keyFromPEM:privatePem isPubkey:NO]];
    pair.peerId = peerId;
    return pair;
}

@end
