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
//  ESJSBSaveWebDataCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBSaveWebDataCommand.h"
#import "ESWebDataManager.h"

@implementation ESJSBSaveWebDataCommand

/**
 
 {
     "key": "数据标识符",
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

        if (![params.allKeys containsObject:@"key"] ||
            ![params.allKeys containsObject:@"value"] ||
            ![params[@"key"] isKindOfClass:[NSString class]] ||
            [params[@"key"] length] <= 0) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        
        //写入数据
        [[ESWebDataManager cacheForAppletId:self.context.appletInfo.appletId] setObject: ESSafeString(params[@"value"]) forKey:ESSafeString(params[@"key"])];
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @""
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"saveWebData";
}

@end
