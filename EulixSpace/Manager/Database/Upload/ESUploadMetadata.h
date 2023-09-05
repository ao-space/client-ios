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
//  ESUploadMetadata.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRspUploadRspBody.h"

typedef NS_ENUM(NSUInteger, ESUploadMetadataStatus) {
    ESUploadMetadataStatusWaitUpload,
    ESUploadMetadataStatusInUpload,
    ESUploadMetadataStatusUploading,
    ESUploadMetadataStatusUploadError,
    ESUploadMetadataStatusUploadSuccess,
};

@class PHAsset;
@class ESAccount;
@class UIImage;

static NSString *const kESUploadMetadataTypeTransfer = @"transfer";
static NSString *const kESUploadMetadataTypeAutoUpload = @"autoUpload";

@interface ESUploadMetadata : NSObject

@property (nonatomic, assign) NSUInteger creationDate;      //创建日期
@property (nonatomic, assign) NSUInteger modificationDate;  //修改日志
@property (nonatomic, copy) NSString *assetLocalIdentifier; //相册的资源有这个字段,可以从相册读取图片/视频
@property (nonatomic, copy) NSString *originalFilename;     //相册中的资源原始名称

@property (nonatomic, copy) NSString *localDataFile;           //沙盒文件地址
@property (nonatomic, copy) NSString *fileName;                //文件名称
@property (nonatomic, assign) NSInteger sessionTaskIdentifier; //上传任务的任务 id
@property (nonatomic, copy) NSString *requestId;               //上传任务的唯一标识
@property (nonatomic, copy) NSString *url;               //上传任务的唯一标识
@property (nonatomic, assign) UInt64 size;                     ///文件大小

@property (nonatomic, assign) NSInteger status; ///上传状态
@property (nonatomic, copy) NSString *ocId;
@property (nonatomic, copy) NSString *taskType; ///区分自动同步还是手动上传
@property (nonatomic, copy) NSString *taskUUID;

///分片
@property (nonatomic, assign) BOOL multipart;        ///是否是分片上传
@property (nonatomic, copy) NSString *betag;         ///文件的校验
@property (nonatomic, copy) NSString *uploadId;      ///分片的任务 id
@property (nonatomic, copy) NSString *folderId;      ///上传的目录 id
@property (nonatomic, copy) NSString *folderPath;    ///上传的目录 路径
@property (nonatomic, assign) UInt64 partSize;       //分片大小
@property (nonatomic, assign) UInt64 uploadedOffset; //已经上传好的文件偏移量
@property (nonatomic, copy) NSString *plistPath;    ///上传的目录 路径
///
@property (nonatomic, copy) NSString *source;    ///上传的目录 路径
///
@property (nonatomic, copy) NSString *noPermissionthumbnailPath;  
///不存进数据库
@property (nonatomic, assign) NSInteger uploadDate; ///上传日期
@property (nonatomic, assign) NSInteger progress;   ///上传进度

///业务来源id， 默认为0， 1-来源相册同步    2  - 智能相册上传
@property (nonatomic, assign) NSInteger businessId;
@property (nonatomic, copy) NSString *albumId;

@property (nonatomic,copy) NSString *category;

@property (nonatomic,copy) NSNumber *photoNum;

@property (nonatomic,copy) NSString *photoID;

///相册里数据读取
@property (nonatomic, strong, readonly) UIImage *thumb;

@property (nonatomic, strong, readonly) PHAsset *asset;
// 标记图片类或视频类资源是否经edit过
@property (nonatomic, assign) BOOL isEdited;

@property (nonatomic,copy) NSString *permission;//是否开启权限

@property (nonatomic, copy) void (^callback)(ESRspUploadRspBody *result, NSError *error);
- (void)callResult:(ESRspUploadRspBody *)result error:(NSError *)error;


+ (instancetype)fromAsset:(PHAsset *)asset type:(NSString *)type;
//不赋值 fileName fileSize
+ (instancetype)newFromAsset:(PHAsset *)asset type:(NSString *)type;

///从系统`文件`中选择
+ (instancetype)fromFile:(NSString *)filePath;

///写入沙盒,
- (void)writeDataToSandbox:(void (^)(NSString *path))completion;

///加载缩略图
- (void)loadThumbImage:(void (^)(UIImage *thumb))completion;

///加载PHAsset 对象
- (void)reloadAsset;

///数据库操作
- (void)save; //保存

- (BOOL)remove; ///删除

+ (void)resetToWaitUpload:(NSString *)type; //根据条件重置状态到等待上传

+ (void)clearTable:(NSString *)type; ///根据条件删除任务

///查询
+ (NSArray<ESUploadMetadata *> *)autoUploadMetadata:(NSArray<NSNumber *> *)statuses limit:(NSInteger)limit;

+ (ESUploadMetadata *)metadataWhere:(NSString *)assetLocalIdentifier type:(NSString *)type;

///删除
+ (BOOL)deleteMetadata:(NSArray<NSNumber *> *)statuses type:(NSString *)type;

@end
