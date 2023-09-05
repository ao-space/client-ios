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
//  ESJSBOpenUrlWithSystemWebCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBOpenUrlWithSystemWebCommand.h"

@implementation ESJSBOpenUrlWithSystemWebCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        ESDLog(@"[ESJSBOpenUrlWithSystemWebCommand] invoke commandHander %@", data);
        if (![self checkResponseData:data callback:responseCallback]) {
            return;
        }
        
        NSDictionary *params = (NSDictionary *)data;
        NSString *urlStr = params[@"url"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ESSafeString(urlStr)]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ESSafeString(urlStr)]];
            responseCallback(@{ @"code" : @(200),
                                @"data" : @{},
                                @"msg" : @"已经触发跳转到系统浏览器"
                             });
            return;
        }
        
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : @"不支持打开这个链接"
                         });
    };
    return _commandHander;
}

- (NSArray<NSString *> *)needCheckParams {
    return @[@"url"];
}

- (NSString *)commandName {
    return @"openUrlWithSystemWeb";
}

@end

