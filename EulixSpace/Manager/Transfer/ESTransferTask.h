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
//  ESTransferTask.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferDefine.h"
#import <Foundation/Foundation.h>
#import "ESRspUploadRspBody.h"
#import "ESUploadEntity.h"
#import "ESFileStreamOperation.h"
#import "ESTokenItem.h"
#import "ESTransferProgress.h"
#import "ESFileInfoPub+ESTool.h"

@class ESFileInfoPub;

@class ESUploadMetadata;
@class ESSliceModel;
@class ESDownloadSliceModel;
@class ESDownloadFragmentModel;
@class ESTransferTask;

@protocol ESTaskProtocol <NSObject>

@optional
- (void)taskStateUpdated:(ESTransferTask *)task;

@end

@interface ESTransferTask : NSObject
//下载的文件id
@property (nonatomic, copy, readonly) NSString *fileId;
//下载的文件存储位置
@property (nonatomic, copy, readonly) NSString *localPath;
// 这是下载时，服务端的对象数据
@property (nonatomic, strong, readonly) ESFileInfoPub *file;
// 这是上传完成后，服务端返回的对象数据
@property (nonatomic, strong, readonly) ESFileInfoPub * uploadFile;

//上传的本地文件地址
@property (nonatomic, copy, readonly) NSString *filePath;


@property (nonatomic, copy, readonly) NSString *targetDir;

///通用

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) UInt64 size;

@property (nonatomic, readonly) UInt64 timestamp;

// 传输状态

@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, assign, readonly) BOOL selectForDelectRecord;

@property (nonatomic, assign, readonly) ESTransferState state;
@property (nonatomic, assign, readonly) ESTransferWay transferWay;

@property (nonatomic, readonly) BOOL isDownloadTask;

@property (nonatomic, assign, readonly) ESTransferErrorState taskErrorState;

// Called by uncompleted Task when Process-Change Or State-Change
@property (nonatomic, copy) void (^updateProgressBlock)(ESTransferTask *task);

///上传时的是requestId ,下载是文件的uuid
@property (nonatomic, copy, readonly) NSString *taskId;

@property (nonatomic, strong, readonly) ESUploadMetadata *metadata;

//Factory
+ (instancetype)taskWithFile:(ESFileInfoPub *)file visible:(BOOL)visible;

+ (instancetype)taskWithMetaData:(ESUploadMetadata *)metadata;

+ (instancetype)taskWithFilePath:(NSString *)filePath
                       requestId:(NSString *)requestId
                       targetDir:(NSString *)targetDir;

- (void)onUpdateProgress:(int64_t)bytes
              totalBytes:(int64_t)totalBytes
      totalBytesExpected:(int64_t)totalBytesExpected;

@property (nonatomic, copy) void (^callback)(ESRspUploadRspBody *result, NSError *error);
// 是否为分片任务
@property (nonatomic, assign, readonly) BOOL isMultipart;
// 是否在计算betag的过程中
@property (nonatomic, assign) BOOL isCalBetaging;
// 标记此任务是否检查自签名证书失败了
@property (nonatomic, assign) bool isCertificateFailed;

- (void)setVisible:(BOOL)visible;
- (void)updateSelectForRecord:(BOOL)isSelected;
- (void)updateTimestamp;
- (void)callResult:(ESRspUploadRspBody *)result error:(NSError *)error;
- (void)setUploadTaskSuspended;
// 获取上传或下载的进度
- (CGFloat)getProgress;
// 获取任务的速度
- (NSString *)getTaskSpeed;
- (void)callUpdateProgress;
- (void)updateTaskTransferWay:(ESTransferWay)way;

@property (nonatomic, weak) dispatch_semaphore_t uploadingSemaphore;
@property (nonatomic, strong) ESSliceModel * sliceModel;

@property (nonatomic, strong) NSHashTable * taskObserverArr;
- (void)addTaskObserver:(id<ESTaskProtocol>)item;
- (void)updatedTaskState;
- (void)setUploadBetag:(NSString *)betag slice:(NSMutableArray *)sliceArr;
- (void)updateUploadTaskState:(ESTransferState)state;
- (void)updateUploadTaskErrorState:(ESTransferErrorState)state;
- (void)updateUploadSliceState:(FileFragment *)item state:(ESTransferState)state;
- (void)updateUploadSliceSpeed:(FileFragment *)item speed:(CGFloat)speed;
- (void)updateUploadSliceTransferWay:(FileFragment *)item way:(ESTransferWay)way;
- (void)updateUploadMetadataStatue:(ESUploadMetadataStatus)status;
- (void)updateUploadUploadId:(NSString *)uploadId;
- (void)clearUploadRecord;

// 获取文件的路径（目前仅对分片类型的task）
- (NSString *)getFilePath;

// 获取分片数据的路径（未加密时）
- (NSString *)getFragmentFilePath:(FileFragment *)item;
- (NSString *)getEncryptFragmentFilePath:(FileFragment *)item;
// 加密分片数据，并返回加密数据的路径
- (NSString *)encryptFragmentFile:(FileFragment *)item token:(ESTokenItem *)token;

// 删除分片数据
- (BOOL)delFragmentFile:(FileFragment *)item;
- (BOOL)delEncryptFragmentFile:(FileFragment *)item;

// 将分片任务重置为挂起状态
- (void)setFragmentStateSuspended;
- (void)setUploadResult:(ESUploadRspBody *)model;
- (void)setUploadFragmentStateReady;


// download
@property (nonatomic, copy) void (^downloadCallback)(NSURL *url, NSError *error);
//  预览业务中，下载原图逻辑使用
@property (nonatomic, copy) void (^downloadPreCallback)(NSURL *url, NSError *error);

@property (nonatomic, weak) dispatch_semaphore_t downloadingSemaphore;
@property (nonatomic, strong) ESDownloadSliceModel * downloadSliceModel;
// 判断是否完成下载
- (BOOL)isCompletedDownloadTask;
- (void)mergeDownloadData:(void (^)(NSURL * url))completedBlock;

// 根据参数获取下载文件的路径
+ (NSString *)getDownloadFilePath:(ESFileInfoPub *)file;

// 获取下载文件的路径
- (NSString *)getDownloadFilePath;
- (NSString *)getDownloadFilePathForUpload;
// 获取下载分片数据的文件夹
- (NSString *)getDownloadFragmentDir;
// 获取下载分片的路径
- (NSString *)getDownloadRangePath:(ESDownloadFragmentModel *)item;
// 获取下载加密分片数据的路径
- (NSString *)getDownloadRangeEncryptPath:(ESDownloadFragmentModel *)item;
- (void)clearDownloadCache;

// 判断下载过数据还在不在（原来的逻辑是下载完，不会清理掉缓存）
- (NSString *)getCacheDownloadFilePath;

// 创建下载分片相关的数据
- (void)createDownloadRangeFragments;
- (void)callDownloadResult:(NSURL *)url error:(NSError *)error;
- (void)setDownloadFragmentStateSuspended;
- (void)setDownloadFragmentStateReady;
- (void)updateDownloadTaskState:(ESTransferState)state;
- (void)updateDownloadTaskErrorState:(ESTransferErrorState)state;
- (void)updateDownloadSliceState:(ESDownloadFragmentModel *)item state:(ESTransferState)state;
- (void)updateDownloadSliceSpeed:(ESDownloadFragmentModel *)item speed:(CGFloat)speed;
- (void)updateDownloadSliceTransferWay:(ESDownloadFragmentModel *)item way:(ESTransferWay)way;

- (NSString *)getFailedReason;

// zdz todo just for test
@property (nonatomic, assign) NSTimeInterval taskCreateTime;
// download
@property (nonatomic, assign) NSTimeInterval downloadBeginTime;
@property (nonatomic, assign) NSTimeInterval downloadEndTime;
// upload
@property (nonatomic, assign) NSTimeInterval createMultiPartReqTime;
@property (nonatomic, assign) NSTimeInterval createMultiPartRespTime;
@property (nonatomic, assign) NSTimeInterval endMultiPartReqTime;
@property (nonatomic, assign) NSTimeInterval endMultiPartRespTime;

@end


@interface ESSliceModel : NSObject
// 这个是丹江的那个方法计算出来的值，即整体文件计算出来的值
@property (nonatomic, copy) NSString * fileBetag;
// 存放每个分片的数据
@property (nonatomic, strong) NSMutableArray<FileFragment *> * dataArray;


- (int)completedSliceNum;
- (FileFragment *)getCanTransferFragment;

@end


@interface ESDownloadFragmentModel : NSObject

@property (nonatomic, assign) long index;
// 保持信息如：bytes=0-4194303
@property (nonatomic, strong) NSString * range;
@property (nonatomic, assign) UInt64 size;
@property (nonatomic, assign) ESTransferState downloadFragmentState;
// 此分片的速度
@property (nonatomic, assign) CGFloat fragmentSpeed;
@property (nonatomic, assign) ESTransferWay downloadTransferWay;

@property (nonatomic, assign) NSTimeInterval startDownloadTime;
@property (nonatomic, assign) NSTimeInterval endDownloadTime;
@end


@interface ESDownloadSliceModel : NSObject

// 保持信息如：bytes=0-4194303
@property (nonatomic, strong) NSMutableArray<ESDownloadFragmentModel *> * rangeArray;

- (int)completedFragmentNum;
- (ESDownloadFragmentModel *)getCanDownloadFragment;
// 已下载数据与全部数据的比
- (CGFloat)getDownloadProgress;
@end


