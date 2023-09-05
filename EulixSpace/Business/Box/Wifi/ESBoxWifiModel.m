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
//  ESBoxWifiModel.m
//  EulixSpace
//
//  Created by dazhou on 2022/11/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBoxWifiModel.h"
#import "NSString+ESTool.h"

@implementation ESBoxWifiModel

- (instancetype)init {
    if (self = [super init]) {
        self.connectList = [NSMutableArray array];
        self.availableList = [NSMutableArray array];
    }
    return self;
}

- (BOOL)hasDetail {
    ESBindNetworkModel * model = [self.connectList firstObject];
    if (model) {
        return model.hasDetail;
    }
    
    return NO;
}

@end


@implementation ESBoxNetworkStatusModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"networkAdapters" : [ESBoxNetworkAdapterModel class]
    };
}

@end

@implementation ESBoxNetworkAdapterModel

@end


@implementation ESBoxNetworkConfigReq
- (instancetype)init {
    if (self = [super init]) {
        self.networkAdapters = [NSMutableArray array];
    }
    return self;
}
@end


@implementation ESBoxNetSectionModel
- (instancetype)init {
    if (self = [super init]) {
        self.rowList = [NSMutableArray array];
    }
    return self;
}
@end


@implementation ESBoxNetRowModel

@end

@implementation ESBoxNetworkConfigResp


@end


@implementation ESBoxNetEditModel

- (void)setIpv4:(NSString *)ipv4 {
    _ipv4 = ipv4;
    [self checkIfDone];
}

- (void)setSubNetMask:(NSString *)subMask {
    _subNetMask = subMask;
    [self checkIfDone];
}

- (void)setDefaultGateway:(NSString *)defaultGateway {
    _defaultGateway = defaultGateway;
    [self checkIfDone];
}

- (void)setDns1:(NSString *)dns1 {
    _dns1 = dns1;
    [self checkIfDone];
}

- (void)setDns2:(NSString *)dns2 {
    _dns2 = dns2;
    [self checkIfDone];
}

- (void)checkIfDone {
    if (!self.canDoneBlock) {
        return;
    }
    
    if (![self.ipv4 es_validateIPV4Format]
        || ![self.subNetMask es_validateIPV4Format]
        || ![self.defaultGateway es_validateIPV4Format]) {
        self.canDoneBlock(NO);
        return;
    }
    
    if (![self.dns1 es_validateIPV4Format]
        || ![self.dns2 es_validateIPV4Format]) {
        self.canDoneBlock(NO);
        return;
    }
    
    self.canDoneBlock(YES);
}

@end
