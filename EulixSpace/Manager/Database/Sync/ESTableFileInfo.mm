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
//  ESTableFileInfo.mm
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTableFileInfo.h"
#import "ESDatabaseManager+CURD.h"
#import "ESTableFileInfo+WCTTableCoding.h"

@implementation ESTableFileInfo

WCDB_IMPLEMENTATION(ESTableFileInfo)
WCDB_SYNTHESIZE(ESTableFileInfo, category)
WCDB_SYNTHESIZE(ESTableFileInfo, createdAt)
WCDB_SYNTHESIZE(ESTableFileInfo, fileCount)

WCDB_SYNTHESIZE(ESTableFileInfo, isDir)
WCDB_SYNTHESIZE(ESTableFileInfo, betag)
WCDB_SYNTHESIZE(ESTableFileInfo, mime)
WCDB_SYNTHESIZE(ESTableFileInfo, modifyAt)
WCDB_SYNTHESIZE(ESTableFileInfo, name)

WCDB_SYNTHESIZE(ESTableFileInfo, path)
WCDB_SYNTHESIZE(ESTableFileInfo, size)
WCDB_SYNTHESIZE(ESTableFileInfo, trashed)

WCDB_SYNTHESIZE(ESTableFileInfo, operationAt)
WCDB_SYNTHESIZE(ESTableFileInfo, uuid)

WCDB_PRIMARY(ESTableFileInfo, uuid)

+ (NSArray<ESTableFileInfo *> *)query:(NSString *)path limit:(NSInteger)limit {
    WCTSelect *select = [ESDatabaseManager.manager select:ESTableFileInfo.class];
    if (path) {
        [select where:ESTableFileInfo.path == path];
    }
    WCTOrderBy wctOrder = WCDB::Order(WCTExpr(ESTableFileInfo.operationAt), WCDB::OrderTerm::DESC);
    [select orderBy:wctOrder];
    if (limit > 0) {
        [select limit:limit];
    }
    return select.allObjects;
}

+ (BOOL)clearTable {
    WCTDelete *remove = [ESDatabaseManager.manager delete:self];
    return [remove execute];
}

@end
