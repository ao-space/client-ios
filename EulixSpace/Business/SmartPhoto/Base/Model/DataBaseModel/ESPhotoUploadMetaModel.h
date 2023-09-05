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
//  ESPhotoUploadMetaModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPhotoUploadMetaModel : NSObject

@property (nonatomic, copy) NSString *photoID;
@property (nonatomic, copy) NSString *photoName;
@property (nonatomic, assign) NSTimeInterval creationDate;      //创建日期
@property (nonatomic, assign) NSTimeInterval modificationDate;  //修改日志
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *folderPath;     ///上传的目录 路径
@property (nonatomic, copy) NSString *sourcePath;    ///上传的来源文件目录 路径
@property (nonatomic, copy) NSString *sourceType;    ///上传的来源type
@property (nonatomic, copy) NSString *addAlbumId;    ///上传的AlbumId

@property (nonatomic, assign) UInt64 size;         ///文件大小
@property (nonatomic, assign) NSInteger taskPhotoCount; //上传任务的图片数
@property (nonatomic, copy) NSString *taskPhotoIds; //上传任务的图片ID list json

@property(nonatomic, copy) NSString* uuid;       //上传后返回id

@property (nonatomic, readonly, nullable) NSArray *photoIdList;

@end

NS_ASSUME_NONNULL_END
