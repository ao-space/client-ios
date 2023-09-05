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
//  ESJSBGetUserInfoCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBGetUserInfoCommand.h"
#import "ESNavigationBar+ESStyle.h"

@implementation ESJSBGetUserInfoCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
//           "uuid": "client_uuid",
//           "userId": "ao_id",
//           "avatarPath": "头像资源本地路径",
//           "nickName": "昵称",
//           "userDomain": "用户域名"

        
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @""
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"getUserInfo";
}

@end

