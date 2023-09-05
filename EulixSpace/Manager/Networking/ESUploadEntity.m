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
//  ESUploadEntity.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUploadEntity.h"
#import "ESUploadMetadata.h"
#import <FileMD5Hash/FileHash.h>

/// 文件参数,json格式，包括filename、path、createTime、modifyTime和md5sum, 其中时间字段为 unix timestamp 整型值，其它为 string 类型
@interface ESUploadEntity ()

@property (nonatomic, copy) NSString *filename;

@property (nonatomic, copy) NSString *path;

@property (nonatomic, assign) UInt64 size;

@property (nonatomic, copy) NSString *md5sum;

@property (nonatomic, copy) NSString *mediaType;

@property (nonatomic, assign) NSUInteger createTime;

@property (nonatomic, assign) NSUInteger modifyTime;

@end

@implementation ESUploadEntity

+ (instancetype)entityFromFilePath:(NSString *)src dir:(NSString *)dir {
    ESUploadEntity *entity = [ESUploadEntity new];
    entity.filename = src.lastPathComponent;
    entity.path = dir;
    entity.size = [[NSFileManager.defaultManager attributesOfItemAtPath:src error:nil] fileSize];
    entity.md5sum = [FileHash md5HashOfFileAtPath:src];
    entity.mediaType = @"application/octet-stream";
    return entity;
}

+ (instancetype)entityFromMetadata:(ESUploadMetadata *)metadata dir:(NSString *)dir {
    ESUploadEntity *entity = [ESUploadEntity new];
    entity.filename = metadata.fileName;
    entity.path = dir;
    entity.size = metadata.size;
    entity.md5sum = [FileHash md5HashOfFileAtPath:metadata.localDataFile];
    entity.createTime = metadata.creationDate;
    entity.modifyTime = metadata.modificationDate;
    entity.mediaType = @"application/octet-stream";
    if (metadata.albumId.length > 0) {
        entity.albumId = [metadata.albumId integerValue];
    }
    return entity;
}

@end
