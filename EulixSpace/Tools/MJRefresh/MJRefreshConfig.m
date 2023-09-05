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
//  MJRefreshConfig.m
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import "MJRefreshConfig.h"
#import "MJRefreshConst.h"
#import "NSBundle+MJRefresh.h"

@interface MJRefreshConfig (Bundle)

+ (void)resetLanguageResourceCache;

@end

@implementation MJRefreshConfig

static MJRefreshConfig *mj_RefreshConfig = nil;

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mj_RefreshConfig = [[self alloc] init];
    });
    return mj_RefreshConfig;
}

- (void)setLanguageCode:(NSString *)languageCode {
    if ([languageCode isEqualToString:_languageCode]) {
        return;
    }
    
    _languageCode = languageCode;
    // 重置语言资源
    [MJRefreshConfig resetLanguageResourceCache];
    [NSNotificationCenter.defaultCenter
     postNotificationName:MJRefreshDidChangeLanguageNotification object:self];
}

@end
