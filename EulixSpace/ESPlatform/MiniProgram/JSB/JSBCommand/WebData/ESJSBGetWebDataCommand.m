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
//  ESJSBGetWebDataCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBGetWebDataCommand.h"
#import "ESWebDataManager.h"

@implementation ESJSBGetWebDataCommand

/**
 
 {
     "key": "数据标识符"
 }

 {
     "value": "缓存数据内容"
 }

*/

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![data isKindOfClass:[NSDictionary class]]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;
        if (![params[@"key"] isKindOfClass:[NSString class]] || [params[@"key"] length] <= 0) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        
        //读取数据
       id value = [[ESWebDataManager cacheForAppletId:self.context.appletInfo.appletId] objectForKey:params[@"key"]];
        responseCallback(@{
            @"value" : value ?: @""
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"getWebData";
}

@end
