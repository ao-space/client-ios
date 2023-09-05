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
//  ESCustomNavigationBarCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCustomNavigationBarCommand.h"
#import "ESNavigationBar.h"
#import "ESNavigationBar+ESStyle.h"
#import "UIColor+ESHEXTransform.h"

@implementation ESCustomNavigationBarCommand

/**
{
    "themeType": 1,              //标题栏主题类型： 1-默认有背景标题栏；2-透明标题栏。缺省值为1
    "titleName": "测试名称",      //标题名称：（themeType为1时，缺省值为小程序名称，themeType为2时，缺省值为空）
    "canGoBack": true,             //是否显示后退按键
    "backgroundColor": "#337AFF",//标题栏背景颜色（themeType为1时生效，RGB字符串，如#FFFFFF）
    "titleTextColor": "#FFFFFF", //标题文字颜色（themeType为2时生效，RGB字符串，如#000000）
    "useLightIcons": false       //标题栏图标类型是否为浅色（themeType为2时生效，true-浅色；false-深色。缺省值为true）
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
        NSInteger themeType = 1;
        if ([params.allKeys containsObject:@"themeType"]) {
            themeType = [params[@"themeType"] intValue] ?: 1;
        }
        
        NSString *titleName = params[@"titleName"];
        BOOL canGoBack = params[@"canGoBack"] ? [params[@"canGoBack"] boolValue] : YES;
        NSString *backgroudColorStr = params[@"backgroundColor"];
        NSString *titleTextColorStr = params[@"titleTextColor"];
        
        if (themeType == 1) {
            titleName = titleName ?: self.context.appletInfo.name;
            titleTextColorStr = nil;
        }
        
        else if (themeType == 2) {
            titleName = titleName ?: @"";
            backgroudColorStr = nil ;
            
            BOOL useLightIcons =  params[@"useLightIcons"] ? [params[@"useLightIcons"] boolValue] : YES;
            [self.context.customNavigationBar setUseLightIcons:useLightIcons];
            self.context.customNavigationBar.isTranslucent = YES;
        }
        
        [self.context.customNavigationBar setCanGoBack:canGoBack];
        [self.context.customNavigationBar setTitle:titleName];
        
        if (titleTextColorStr.length > 0) {
            [self.context.customNavigationBar setTitleColor:[UIColor es_colorWithHexString:titleTextColorStr]];
        }
        
        if (backgroudColorStr.length > 0) {
            [self.context.customNavigationBar setBarBackgroundColor:[UIColor es_colorWithHexString:backgroudColorStr]];
        }

        [self.context.customNavigationBar setCanGoBack:canGoBack];
        [self.context.customNavigationBar updateShowStyle];

        
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @"",
                            @"context" : @{
                                @"platform" : @"iOS",
                                @"appVersion" : ESApplicationConfigStorage.applicationVersion
                            }
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"setNativeTitle";
}

@end
