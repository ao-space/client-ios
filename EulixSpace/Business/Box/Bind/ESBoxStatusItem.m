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
//  ESBoxStatusItem.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxStatusItem.h"

@interface ESBoxStatusItem ()

@property (nonatomic, strong) ESBindInitResultModel *infoResult;

@property (nonatomic, strong) NSArray<ESWifiListRsp *> *wifiResult;

@property (nonatomic, strong) ESWifiStatusRsp *wifiStatusResult;

@property (nonatomic, strong) ESResponseBasePasswdTryInfo *revokeResult;

@property (nonatomic, strong) ESMicroServerRsp *adminPwdResult;

@property (nonatomic, strong) ESAdminBindResult *pairResult;

@property (nonatomic, strong) ESRspMicroServerRsp *initialResult;

@property (nonatomic, strong) ESKeyExchangeRsp *keyExchangeRsp;

@property (nonatomic, strong) ESPubKeyExchangeRsp *pubKeyExchange;

@end

@implementation ESBoxStatusItem

@end



@implementation ESPassthroughReq
- (instancetype)init {
    if (self = [super init]) {
        self.apiVersion = @"v1";
    }
    return self;
}
@end


@implementation ESSecurityPasswordResetModel
@end

@implementation ESSecurityPasswordResetBinderReq
- (instancetype)init {
    if (self = [super init]) {
        self.entity = [[ESSecurityPasswordResetModel alloc] init];
    }
    return self;
}
@end


@implementation ESSecurityPasswordResetBinderRsp

@end


@implementation ESSecurityEmailSetReq
- (instancetype)init {
    if (self = [super init]) {
        self.entity = [[ESSecurityEmailSetModel alloc] init];
    }
    return self;
}
@end

@implementation ESSecurityEmailSetModel

- (BOOL)hasBoundSecurityEmail {
    if (self.emailAccount.length > 0) {
        return YES;
    }
    return NO;
}

@end


@implementation ESSecurityEmailSetRsp

@end


@implementation ESNewDeviceApplyReq
- (instancetype)init {
    if (self = [super init]) {
        self.entity = [[ESNewDeviceApplyModel alloc] init];
    }
    return self;
}
@end

@implementation ESNewDeviceApplyModel

@end


@implementation ESSecurityMessagePollReq
- (instancetype)init {
    if (self = [super init]) {
        self.entity = [[ESSecurityMessagePollModel alloc] init];
    }
    return self;
}
@end


@implementation ESSecurityMessagePollModel

@end


@implementation ESSecurityEmailVerityReq
- (instancetype)init {
    if (self = [super init]) {
        self.entity = [[ESSecurityEmailVerityModel alloc] init];
    }
    return self;
}
@end

@implementation ESSecurityEmailVerityModel

@end

@implementation ESSecurityEmailVerityRspModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"securityToken"  : @"results.securityToken",
             @"expiredAt"  : @"results.expiredAt"
             
    };
}
@end

@implementation ESSecurityEmailVerityRsp

@end



@implementation ESNewDeviceAuthApplyRsp
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"results" : [ESAuthApplyRsp class] };
}

@end

@implementation ESNewDeviceLocalRsp
@end
