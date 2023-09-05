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
//  ESSetting8ackd00rItem.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSetting8ackd00rItem.h"
#import "ESCache.h"
#import <YYModel/YYModel.h>

#define kESSetting8ackd00rCacheKey @"kESSetting8ackd00rCacheKey"

@interface ESSetting8ackd00rItem ()

@property (nonatomic, assign) ESSettingEnvType envType; //App 连接的盒子环境

@end

@implementation ESSetting8ackd00rItem

+ (instancetype)current {
    NSString *json = [ESCache.defaultCache objectForKey:kESSetting8ackd00rCacheKey];
    return [ESSetting8ackd00rItem yy_modelWithJSON:json ?: @{}];
}

- (void)save {
    [ESCache.defaultCache setObject:[self yy_modelToJSONString] forKey:kESSetting8ackd00rCacheKey];
}

@end
