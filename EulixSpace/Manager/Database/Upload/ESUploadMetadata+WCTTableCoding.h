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
//  ESUploadMetadata+WCTTableCoding.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUploadMetadata.h"
#import <WCDB/WCDB.h>

@interface ESUploadMetadata (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(creationDate)
WCDB_PROPERTY(modificationDate)
WCDB_PROPERTY(assetLocalIdentifier)
WCDB_PROPERTY(originalFilename)

WCDB_PROPERTY(localDataFile)
WCDB_PROPERTY(fileName)
WCDB_PROPERTY(sessionTaskIdentifier)
WCDB_PROPERTY(requestId)
WCDB_PROPERTY(size)

WCDB_PROPERTY(status)
WCDB_PROPERTY(ocId)
WCDB_PROPERTY(taskUUID)
WCDB_PROPERTY(taskType)

///分片
WCDB_PROPERTY(multipart)
WCDB_PROPERTY(betag)
WCDB_PROPERTY(uploadId)
WCDB_PROPERTY(folderId)
WCDB_PROPERTY(folderPath)
WCDB_PROPERTY(partSize)
WCDB_PROPERTY(uploadedOffset)

@end
