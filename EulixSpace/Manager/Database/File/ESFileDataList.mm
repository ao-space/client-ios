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
//  ESFileDataList.m
//  EulixSpace
//
//  Created by qu Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileDataList.h"
#import "ESAccount+WCTTableCoding.h"

@implementation ESFileDataList

WCDB_IMPLEMENTATION(ESFileDataList)

WCDB_SYNTHESIZE(ESFileDataList, category)
WCDB_SYNTHESIZE(ESFileDataList, createdAt)
WCDB_SYNTHESIZE(ESFileDataList, fileCount)

WCDB_SYNTHESIZE(ESFileDataList, isDir)
WCDB_SYNTHESIZE(ESFileDataList, betag)
WCDB_SYNTHESIZE(ESFileDataList, mime)
WCDB_SYNTHESIZE(ESFileDataList, modifyAt)
WCDB_SYNTHESIZE(ESFileDataList, name)

WCDB_SYNTHESIZE(ESFileDataList, path)
WCDB_SYNTHESIZE(ESFileDataList, size)
WCDB_SYNTHESIZE(ESFileDataList, trashed)

WCDB_SYNTHESIZE(ESFileDataList, operationAt)
WCDB_SYNTHESIZE(ESFileDataList, uuid)

@end
