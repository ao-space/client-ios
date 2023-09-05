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
//  ESPhotoUploadMetaModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoUploadMetaModel.h"
#import <WCDB/WCDB.h>
#import "NSObject+YYModel.h"

@implementation ESPhotoUploadMetaModel

WCDB_IMPLEMENTATION(ESPhotoUploadMetaModel)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, photoID)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, photoName)

WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, creationDate)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, modificationDate)

WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, category)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, folderPath)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, sourcePath)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, sourceType)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, addAlbumId)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, uuid)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, size)

WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, taskPhotoCount)
WCDB_SYNTHESIZE(ESPhotoUploadMetaModel, taskPhotoIds)

WCDB_PRIMARY(ESPhotoUploadMetaModel, photoID) //主键


- (NSArray * _Nullable)photoIdList {
    if (self.taskPhotoIds.length <= 0) {
        return nil;
    }
    NSData *jsonData = [(NSString *)self.taskPhotoIds dataUsingEncoding : NSUTF8StringEncoding];
    NSArray *list = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    return list;
}
@end

