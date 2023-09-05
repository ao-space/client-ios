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
//  ESAlbumModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumModel.h"
#import <WCDB/WCDB.h>

@implementation ESAlbumModel

WCDB_IMPLEMENTATION(ESAlbumModel)
WCDB_SYNTHESIZE(ESAlbumModel, albumId)
WCDB_SYNTHESIZE(ESAlbumModel, albumName)
WCDB_SYNTHESIZE(ESAlbumModel, picCount)
WCDB_SYNTHESIZE(ESAlbumModel, coverUrl)
WCDB_SYNTHESIZE(ESAlbumModel, createdAt)
WCDB_SYNTHESIZE(ESAlbumModel, modifyAt)
WCDB_SYNTHESIZE(ESAlbumModel, type)
WCDB_SYNTHESIZE(ESAlbumModel, uuidList)
WCDB_SYNTHESIZE(ESAlbumModel, collection)

WCDB_PRIMARY(ESAlbumModel, albumId) //主键

@end

