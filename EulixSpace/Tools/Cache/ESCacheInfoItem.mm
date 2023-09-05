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
//  ESCacheInfoItem.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCacheInfoItem.h"
#import <WCDB/WCDB.h>

@implementation ESCacheInfoItem

WCDB_IMPLEMENTATION(ESCacheInfoItem)
WCDB_SYNTHESIZE(ESCacheInfoItem, uuid)
WCDB_SYNTHESIZE(ESCacheInfoItem, name)
WCDB_SYNTHESIZE(ESCacheInfoItem, cacheDate)
WCDB_SYNTHESIZE(ESCacheInfoItem, path)
WCDB_SYNTHESIZE(ESCacheInfoItem, size)
WCDB_SYNTHESIZE(ESCacheInfoItem, category)
WCDB_SYNTHESIZE(ESCacheInfoItem, cacheType)

WCDB_PRIMARY(ESCacheInfoItem, uuid) //主键

@end


