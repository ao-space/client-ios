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
//  ESLaunchManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLaunchManager.h"
#import "ESBoxManager.h"
#import "ESDebugMacro.h"
#import "ESGatewayClient.h"
#import "ESPlatformClient.h"
#import "ESSessionClient.h"
#import "ESSetting8ackd00rItem.h"

///Platform
static NSString *const kESPlatformClientDefaultHost = @"https://ao.space/";

@interface ESLaunchManager ()

@property (nonatomic, strong) NSDictionary *envMapping;

@end

@implementation ESLaunchManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSDictionary *)envMapping {
    if (!_envMapping) {
        _envMapping = @{
            @(ESSettingEnvTypeRCTOPEnv): @"https://eulix.top/",
            @(ESSettingEnvTypeRCXYZEnv): @"https://eulix.xyz/",
            @(ESSettingEnvTypeDevEnv): @"https://dev.eulix.xyz/",
            @(ESSettingEnvTypeTestEnv): @"https://test.eulix.xyz/",
            @(ESSettingEnvTypeQAEnv): @"https://qa.eulix.xyz/",
            @(ESSettingEnvTypeSitEnv): @"https://sit.eulix.xyz/",
        };
    }
    return _envMapping;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    ESSetting8ackd00rItem *item = [ESSetting8ackd00rItem current];
    if (item.envType == ESSettingEnvTypeDefault) {
        [ESPlatformClient setHost:kESPlatformClientDefaultHost];
    } else {
        [ESPlatformClient setHost:self.envMapping[@(item.envType)] ?: kESPlatformClientDefaultHost];
    }
    ESPlatformClient.platformClient.platformUrl = self.envMapping[@(item.envType)] ?: kESPlatformClientDefaultHost;
    [ESSessionClient sharedInstance].baseUri = kESSessionClientHost;
  
}

@end
