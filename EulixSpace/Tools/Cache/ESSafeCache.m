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
//  ESSafeCache.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSafeCache.h"
#import <SAMKeychain/SAMKeychain.h>

@interface ESSafeCache ()

@property (nonatomic, copy) NSString *serviceName;

@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, copy) NSString *clientUUID;

@property (class, nonatomic, copy, readonly) NSString *deviceId;

@property (class, nonatomic, copy, readonly) NSString *clientUUID;

@end

@implementation ESSafeCache

+ (instancetype)safeCache {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[ESSafeCache alloc] init];
    });
    return instance;
}

+ (NSString *)deviceId {
    return ESSafeCache.safeCache.deviceId;
}

+ (NSString *)clientUUID {
    return ESSafeCache.safeCache.clientUUID.lowercaseString;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _serviceName = NSBundle.mainBundle.bundleIdentifier;
    }
    return self;
}

- (void)setObject:(NSString *)object forKey:(NSString *)key {
    [SAMKeychain setPassword:object forService:_serviceName account:key];
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    return [SAMKeychain passwordForService:_serviceName account:key];
}

- (void)reset {
    {
        NSString *account = [_serviceName stringByAppendingString:@".deviceId"];
        self.deviceId = NSUUID.UUID.UUIDString.lowercaseString;
        [SAMKeychain setPassword:self.deviceId forService:_serviceName account:account];
    }
    {
        self.clientUUID = NSUUID.UUID.UUIDString.lowercaseString;
        NSString *account = [_serviceName stringByAppendingString:@".uuid"];
        [SAMKeychain setPassword:self.clientUUID forService:_serviceName account:account];
    }
}

- (NSString *)deviceId {
    if (!_deviceId) {
        NSString *account = [_serviceName stringByAppendingString:@".deviceId"];
        _deviceId = [SAMKeychain passwordForService:_serviceName account:account];
        if (!_deviceId) {
            _deviceId = [[NSUUID UUID] UUIDString].lowercaseString;
            [SAMKeychain setPassword:_deviceId forService:_serviceName account:account];
        }
    }
    return _deviceId;
}

- (NSString *)clientUUID {
    if (!_clientUUID) {
        NSString *account = [_serviceName stringByAppendingString:@".uuid"];
        _clientUUID = [SAMKeychain passwordForService:_serviceName account:account];
        if (!_clientUUID) {
            _clientUUID = [[NSUUID UUID] UUIDString].lowercaseString;
            [SAMKeychain setPassword:_clientUUID forService:_serviceName account:account];
        }
    }
    return _clientUUID;
}

@end
