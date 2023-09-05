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
//  ESJSBGetAuthParamsCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBGetAuthParamsCommand.h"
#import "ESBoxManager.h"
#import "ESRSACenter.h"

@implementation ESJSBGetAuthParamsCommand

/**
返回参数格式
{
    "aoId": "用户aoId",
    "boxPublicKey": "盒子公钥",
    "clientUuid": "客户端uuid"
    "userDomain": " "
} */

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        NSString *aoId = ESBoxManager.activeBox.aoid;
        NSString *boxPublicKey = [ESRSACenter boxPair:ESBoxManager.activeBox.boxUUID].publicKey.pem;
        NSString *clientUuid = ESBoxManager.clientUUID;
        NSString *userDomain =  [NSString stringWithFormat:@"https://%@", ESBoxManager.activeBox.info.userDomain];
        responseCallback(@{ @"aoId" : ESSafeString(aoId),
                            @"boxPublicKey" : ESSafeString(boxPublicKey),
                            @"clientUuid" : ESSafeString(clientUuid),
                            @"userDomain" : ESSafeString(userDomain),
                            @"context" : @{
                                @"platform" : @"iOS",
                                @"appVersion" : ESApplicationConfigStorage.applicationVersion
                            }
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"getAuthParams";
}
@end
