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
//  ESRSACenter.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSACenter.h"
#import "ESSafeCache.h"
#import "NSString+ESTool.h"
#import <YYModel/YYModel.h>

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

NSString *const kESRSACenterDefaultPeerId = @"default";

@interface ESRSAPair ()

@property (nonatomic, copy) NSString *peerId;

@property (nonatomic, readonly) NSDictionary *toJson;

@end

@interface ESRSACenter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESRSAPair *> *peerCache;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *peerPEMCache;

@property (nonatomic, copy) NSString *uuid;

@end

@implementation ESRSACenter {
    dispatch_semaphore_t _lock;
}

+ (instancetype)defaultCenter {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _peerCache = NSMutableDictionary.dictionary;
        _peerPEMCache = NSMutableDictionary.dictionary;
        _uuid = [NSBundle.mainBundle.bundleIdentifier stringByAppendingString:@".pem"];
        NSString *json = [ESSafeCache.safeCache objectForKey:self.uuid];
        NSDictionary *dict = [json toJson];
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            [_peerPEMCache setDictionary:dict];
        }
        [_peerPEMCache enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key,
                                                           NSDictionary *_Nonnull obj,
                                                           BOOL *_Nonnull stop) {
            ESRSAPair *pair = [ESRSAPair fromJson:obj];
            _peerCache[pair.peerId ?: key] = pair;
        }];
    }
    return self;
}

+ (ESRSAPair *)defaultPair {
    return [self.defaultCenter pairForPeerId:kESRSACenterDefaultPeerId];
}

+ (ESRSAPair *)boxPair:(NSString *)boxUUID {
    if (!boxUUID) {
        return nil;
    }
    return [self.defaultCenter pairForPeerId:boxUUID];
}

- (ESRSAPair *)addPeer:(NSString *)peerId publicPem:(NSString *)publicPem {
    return [self addPeer:peerId publicPem:publicPem privatePem:nil];
}

- (ESRSAPair *)addPeer:(NSString *)peerId publicPem:(NSString *)publicPem privatePem:(NSString *)privatePem {
    if (!peerId) {
        return nil;
    }
    if (publicPem.length == 0 && privatePem.length == 0) {
        NSParameterAssert(publicPem.length == 0 && privatePem.length == 0);
        return nil;
    }
    ESRSA *publicKey = [ESRSAPair keyFromPEM:publicPem isPubkey:YES];
    ESRSA *privateKey = [ESRSAPair keyFromPEM:privatePem isPubkey:NO];
    ESRSAPair *pair = [ESRSAPair pairWithPublicKey:publicKey privateKey:privateKey];
    pair.peerId = peerId;
    return [self addPeer:peerId pair:pair];
}

- (ESRSAPair *)addBoxPublicPem:(NSString *)publicPem boxUUID:(NSString *)boxUUID {
    return [self addPeer:boxUUID publicPem:publicPem];
}

- (void)removeBoxPublicPem:(NSString *)boxUUID {
    _peerPEMCache[boxUUID] = nil;
    _peerCache[boxUUID] = nil;
    [self savePem];
}

- (ESRSAPair *)addPeer:(NSString *)peerId pair:(ESRSAPair *)pair {
    _peerPEMCache[peerId] = [pair toJson];
    _peerCache[peerId] = pair;
    [self savePem];
    return pair;
}

- (void)savePem {
    NSString *json = [_peerPEMCache yy_modelToJSONString];
    [ESSafeCache.safeCache setObject:json forKey:self.uuid];
}

- (ESRSAPair *)pairForPeerId:(NSString *)peerId {
    Lock();
    ESRSAPair *pair = _peerCache[peerId];
    if (!pair) {
        pair = [ESRSAPair generateRSAKeyPairWithKeySize:2048];
        pair.peerId = peerId;
        [self addPeer:peerId pair:pair];
    }
    Unlock();
    return pair;
}

@end
