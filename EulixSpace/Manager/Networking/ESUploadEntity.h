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
//  ESUploadEntity.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESUploadEntityBusiness) {
    ESUploadEntityBusinessDefault,                //  int = 0//默认业务来源
    ESUploadEntityBusinessSync,       //int = 1    //同步业务来源
    ESUploadEntityBusinessUpload,     //int = 2    // 智能相册上传
};

@class ESUploadMetadata;
/// 文件参数,json格式，包括filename、path、createTime、modifyTime和md5sum, 其中时间字段为 unix timestamp 整型值，其它为 string 类型
@interface ESUploadEntity : NSObject

@property (nonatomic, copy, readonly) NSString *filename;

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, readonly) UInt64 size;

@property (nonatomic, copy, readonly) NSString *md5sum;

@property (nonatomic, copy, readonly) NSString *mediaType;

@property (nonatomic, readonly) NSUInteger createTime;

@property (nonatomic, readonly) NSUInteger modifyTime;

@property (nonatomic, assign) ESUploadEntityBusiness businessId;

@property (nonatomic, assign) NSInteger albumId;

+ (instancetype)entityFromFilePath:(NSString *)src dir:(NSString *)dir;

+ (instancetype)entityFromMetadata:(ESUploadMetadata *)metadata dir:(NSString *)dir;

@end
