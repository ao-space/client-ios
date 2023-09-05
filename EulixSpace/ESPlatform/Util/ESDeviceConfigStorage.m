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
//  ESDeviceConfigStorage.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceConfigStorage.h"
#import "ESBoxManager.h"

@implementation ESDeviceConfigStorage

+ (NSString *)userDomain {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    return dic[@"userDomain"] ?: ESBoxManager.realdomain;
}

+ (NSString *)boxUUID {
    return ESBoxManager.activeBox.boxUUID;
}

@end
