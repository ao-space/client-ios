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
//  ESSetNativeTitleJSBCommand.m
//  EulixSpace
//
//  Created by KongBo on 2023/3/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSetNativeTitleJSBCommand.h"
#import "UIColor+ESHEXTransform.h"

@implementation ESSetNativeTitleJSBCommand
/**
{
   {titleName:'xxx',canGoBack:true|false}
    style : 0 带自定义导航栏， 1 fullscreen 全屏展示， 2 透明模式
}*/

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
        NSString *titleName = params[@"titleName"];

        BOOL canGoBack = params[@"canGoBack"] ? [params[@"canGoBack"] boolValue] : YES;
        [self.context.customNavigationBar setTitle:titleName];
        [self.context.customNavigationBar  setCanGoBack:canGoBack];
        if ([params.allKeys containsObject:@"style"]) {
            NSInteger style = [params[@"style"] intValue];
            self.context.webVC.style = style;
        }
        if ([params.allKeys containsObject:@"statusBarBackgroudColor"]) {
            NSString *color = params[@"statusBarBackgroudColor"];
            self.context.webVC.statusBarBackgroudColor =  [UIColor es_colorWithHexString:color];
        }

        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @"",
                            @"context" : @{
                                @"platform" : @"iOS",
                            }
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"setNativeTitle";
}
@end
