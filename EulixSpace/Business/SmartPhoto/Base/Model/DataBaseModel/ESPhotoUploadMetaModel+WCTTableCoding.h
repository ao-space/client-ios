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
//  ESPhotoUploadMetaModel+WCTTableCoding.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoUploadMetaModel.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPhotoUploadMetaModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(photoID)
WCDB_PROPERTY(photoName)
WCDB_PROPERTY(creationDate)
WCDB_PROPERTY(modificationDate)
WCDB_PROPERTY(category)
WCDB_PROPERTY(folderPath)
WCDB_PROPERTY(sourcePath)
WCDB_PROPERTY(sourceType)
WCDB_PROPERTY(addAlbumId)
WCDB_PROPERTY(uuid)
WCDB_PROPERTY(size)
WCDB_PROPERTY(taskPhotoCount)
WCDB_PROPERTY(taskPhotoIds)

@end

NS_ASSUME_NONNULL_END
