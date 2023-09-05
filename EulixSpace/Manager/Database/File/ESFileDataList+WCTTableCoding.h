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
//  ESFileDataList+WCTTableCoding.h
//  EulixSpace
//
//  Created by qu on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileDataList.h"
#import <WCDB/WCDB.h>

@interface ESFileDataList (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(bucketName)
WCDB_PROPERTY(category)
WCDB_PROPERTY(createdAt)
WCDB_PROPERTY(fileCount)

WCDB_PROPERTY(isDir)
WCDB_PROPERTY(betag)
WCDB_PROPERTY(mime)
WCDB_PROPERTY(modifyAt)
WCDB_PROPERTY(name)

WCDB_PROPERTY(path)
WCDB_PROPERTY(size)
WCDB_PROPERTY(tags)

WCDB_PROPERTY(operationAt)
WCDB_PROPERTY(uuid)

@end
