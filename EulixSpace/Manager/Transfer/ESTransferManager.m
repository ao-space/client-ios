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
//  ESTransferManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferManager.h"
#import "ESBoxManager.h"
#import "ESCache.h"
#import "ESFileDefine.h"
#import "ESGatewayManager.h"
#import "ESGlobalDefine.h"
#import "ESHomeCoordinator.h"
#import "ESLocalPath.h"
#import "ESThemeDefine.h"
#import "ESUploadMetadata.h"
#import "UIImage+ESTool.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "ESRspUploadRspBody.h"
#import "ESRspUploadRspBody.h"
#include <CommonCrypto/CommonDigest.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import <YYModel/YYModel.h>
#import "ESApiCode.h"
#import "ESToast.h"
#import "ESUpdataTool.h"
#import "ESCommentCachePlistData.h"
#import "NSString+ESTool.h"
#import "ESUploadEntity.h"

typedef void (^ESCompletionHandler)(void);

@interface ESTransferManager ()<ESTaskProtocol>

@property (nonatomic, strong) NSMutableArray<ESTransferTask *> *downloadingQueue;

@property (nonatomic, strong) NSMutableArray<ESTransferTask *> *downloadedQueue;

@property (nonatomic, strong) NSMutableArray<ESTransferTask *> *uploadingQueue;

@property (nonatomic, strong) NSMutableArray<ESTransferTask *> *uploadedQueue;
// 保存来自相册同步功能的任务
@property (nonatomic, strong) NSMutableArray<ESTransferTask *> *autoSyncUploadingQueue;

@property (nonatomic, copy) void (^notifyListener)(void);

@property (nonatomic, strong) dispatch_semaphore_t uploadingSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t uploadedSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t downloadingSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t downloadedSemaphore;


@property (nonatomic, strong) NSHashTable *taskObservers;


@end

#define kESTransferManagerDownloadingQueueUniqueKey [NSString stringWithFormat:@"kESTransferManagerDownloadingQueue_%@", ESBoxManager.activeBox.uniqueKey]

#define kESTransferManagerDownloadedQueueUniqueKey [NSString stringWithFormat:@"kESTransferManagerDownloadedQueue_%@", ESBoxManager.activeBox.uniqueKey]

#define kESTransferManagerUploadingQueueUniqueKey [NSString stringWithFormat:@"kESTransferManagerUploadingQueue_%@", ESBoxManager.activeBox.uniqueKey]

#define kESTransferManagerUploadedQueueUniqueKey [NSString stringWithFormat:@"kESTransferManagerUploadedQueue_%@", ESBoxManager.activeBox.uniqueKey]



@implementation ESTransferManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];

    });
    return instance;
}

+ (instancetype)newServiceInstance {
    return [ESTransferManager manager];
}

- (void)startService {
    [self initData];
}

- (void)resetService {
    [self initData];
}

- (void)addTransferResult:(NSString *)result {
    if (result) {
        [self.transferResultList insertObject:result atIndex:0];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadingSemaphore = dispatch_semaphore_create(1);
        _uploadedSemaphore = dispatch_semaphore_create(1);
        _downloadingSemaphore = dispatch_semaphore_create(1);
        _downloadedSemaphore = dispatch_semaphore_create(1);


        _transferResultList = [NSMutableArray array];
        
        [self initObserver];
    }
    return self;
}

#pragma mark - Local Storage
- (void)initObserver {
    weakfy(self);
    [NSNotificationCenter.defaultCenter addObserverForName:kESGlobalUploadAutoUploadSuccess
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *_Nonnull note) {
                                                    [weak_self notifyAllEvent];
                                                }];
}

- (void)initData {
    if (!ESBoxManager.activeBox) {
        return;
    }
    
    ESDLog(@"[上传下载] uniqueKey:%@", ESBoxManager.activeBox.uniqueKey);

    self.autoSyncUploadingQueue = NSMutableArray.array;
    self.uploadingQueue = NSMutableArray.array;
    self.uploadedQueue = NSMutableArray.array;
    
    {
        NSArray<ESTransferTask *> *cache = [NSArray yy_modelArrayWithClass:[ESTransferTask class] json:[ESCache.defaultCache objectForKey:kESTransferManagerUploadedQueueUniqueKey]];
        
        [cache yc_each:^(ESTransferTask *obj) {
            [obj updateUploadTaskState:ESTransferStateCompleted];
        }];
        if (cache.count > 0) {
            [self.uploadedQueue addObjectsFromArray:cache];
        }
    }
    
    {
        NSArray<ESTransferTask *> *cache = [NSArray yy_modelArrayWithClass:[ESTransferTask class] json:[ESCache.defaultCache objectForKey:kESTransferManagerUploadingQueueUniqueKey]];
        
        ESDLog(@"[上传下载] uniqueKey:%@", ESBoxManager.activeBox.uniqueKey);
        [cache yc_each:^(ESTransferTask *obj) {
            if (obj.state == ESTransferStateRunning) {
                [obj updateUploadTaskState:ESTransferStateReady];
            }
            [obj setUploadFragmentStateReady];
            obj.uploadingSemaphore = self.uploadingSemaphore;
        }];
        if (cache.count > 0) {
            [self.uploadingQueue addObjectsFromArray:cache];
        }
    }
    
    self.downloadingQueue = NSMutableArray.array;
    self.downloadedQueue = NSMutableArray.array;
    {
        NSArray<ESTransferTask *> *cache = [NSArray yy_modelArrayWithClass:[ESTransferTask class] json:[ESCache.defaultCache objectForKey:kESTransferManagerDownloadingQueueUniqueKey]];
        
        if (cache.count > 0) {
            [self.downloadingQueue addObjectsFromArray:cache];
        }
        [cache yc_each:^(ESTransferTask *obj) {
            if (obj.state == ESTransferStateRunning) {
                [obj updateDownloadTaskState:ESTransferStateReady];
            }
            [obj setDownloadFragmentStateReady];
            obj.downloadingSemaphore = self.downloadingSemaphore;
        }];
    }

    {
        NSArray<ESTransferTask *> *cache = [NSArray yy_modelArrayWithClass:[ESTransferTask class] json:[ESCache.defaultCache objectForKey:kESTransferManagerDownloadedQueueUniqueKey]];
        
        if (cache.count > 0) {
            [self.downloadedQueue addObjectsFromArray:cache];
        }
    }
    
    [self consumerUploadHandler];
    [self consumerDownloadHandler];
}

#pragma - mark ESTaskProtocol
- (void)taskStateUpdated:(ESTransferTask *)task {
    if (task.isDownloadTask) {
        if (task.state != ESTransferStateCompleted) {
            [self saveDownloadData];
            [task callUpdateProgress];
        } else {
            [self saveDownloadJob];
        }
    } else {
        if (task.state != ESTransferStateCompleted) {
            [self saveUploadingQueueData];
            [task callUpdateProgress];
        } else {
            [self saveUploadJob];
        }
    }
}

- (void)reset {
    [self.uploadingQueue removeAllObjects];
    [self.uploadedQueue removeAllObjects];
    [self saveUploadJob];

    [self.downloadingQueue removeAllObjects];
    [self.downloadedQueue removeAllObjects];
    [self saveDownloadJob];
}

- (void)notifyAllEvent {
    ESPerformBlockOnMainThread(^{
        if (self.notifyListener) {
            self.notifyListener();
        }
    });
    
    [self callTaskCountBlock];
}

- (void)callTaskCountBlock {
    ESPerformBlockOnMainThread(^{
        if (self.taskCountBlock) {
            NSArray *allSyncTask = [ESUploadMetadata autoUploadMetadata:nil limit:-1];
            self.taskCountBlock(self.downloading.count + self.uploading.count + allSyncTask.count);
        }
    });
}

- (void)saveDownloadJob {
    [self saveDownloadData];
    [self notifyAllEvent];
}

- (void)saveDownloadData {
    [self saveDownloadingQueueData];
    [self saveDownloadedQueueData];
}

- (void)saveDownloadingQueueData {
    dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
    [ESCache.defaultCache setObject:[self.downloadingQueue yy_modelToJSONString] forKey:kESTransferManagerDownloadingQueueUniqueKey];
    dispatch_semaphore_signal(self.downloadingSemaphore);
}

- (void)saveDownloadedQueueData {
    dispatch_semaphore_wait(self.downloadedSemaphore, DISPATCH_TIME_FOREVER);
    [ESCache.defaultCache setObject:[self.downloadedQueue yy_modelToJSONString] forKey:kESTransferManagerDownloadedQueueUniqueKey];
    dispatch_semaphore_signal(self.downloadedSemaphore);
}

- (void)saveUploadJob {
    [self saveUploadData];
    [self notifyAllEvent];
}

- (void)saveUploadData {
    [self saveUploadingQueueData];
    [self saveUploadedQueueData];
}

- (void)saveUploadingQueueData {
    dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
    [ESCache.defaultCache setObject:[self.uploadingQueue yy_modelToJSONString] forKey:kESTransferManagerUploadingQueueUniqueKey];
    dispatch_semaphore_signal(self.uploadingSemaphore);
}

- (void)saveUploadedQueueData {
    dispatch_semaphore_wait(self.uploadedSemaphore, DISPATCH_TIME_FOREVER);
    [ESCache.defaultCache setObject:[self.uploadedQueue yy_modelToJSONString] forKey:kESTransferManagerUploadedQueueUniqueKey];
    dispatch_semaphore_signal(self.uploadedSemaphore);
}

- (void)setTaskCountBlock:(void (^)(NSInteger))taskCountBlock {
    _taskCountBlock = [taskCountBlock copy];
    if (_taskCountBlock) {
        _taskCountBlock(self.downloading.count + self.uploading.count);
    }
}

- (void)updateDownloadQueue:(ESTransferTask *)task {
    switch (task.state) {
        case ESTransferStateCompleted: {
            [self removeFromDownloading:task];
            [self removeFromDownloaded:task];
            [self addToDownloaded:task];
            [self saveDownloadJob];
            
            [self consumerDownloadHandler];
        } break;
        case ESTransferStateReady: {
            if (![self.downloadingQueue containsObject:task]) {
                [self addToDownloading:task];
                [self consumerDownloadHandler];
            }
            [self saveDownloadJob];
        } break;
        case ESTransferStateFailed: {
            [self saveDownloadJob];
        } break;
        default:
            break;
    }
    
    [self callTaskCountBlock];
}


- (ESTransferTask *)taskExist:(NSString *)fileId {
    NSArray *array;
    array = [self.downloaded yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return [obj.fileId isEqualToString:fileId];
    }];
    if (array.count > 0) {
        return array.firstObject;
    }
    array = [self.downloading yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return [obj.fileId isEqualToString:fileId];
    }];
    if (array.count > 0) {
        return array.firstObject;
    }
    return nil;
}

#pragma mark - Download

- (void)preview:(ESFileInfoPub *)file
       progress:(ESProgressHandler)progress
       callback:(void (^)(NSURL *output, NSError *error))callback {
    NSString *fileId = file.uuid;
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.apiName = @"download_compressed";
    request.serviceName = @"eulixspace-filepreview-service";
    request.queries = @{@"uuid": fileId};
    NSString *localPath = CompressedPathForFile(file);
    [ESNetworking.shared downloadRequest:request
                              targetPath:localPath.fullCachePath
                                progress:progress
                                callback:^(NSURL *output, NSError *error) {
                                    if (output) {
                                        if (callback) {
                                            callback(output, nil);
                                        }
                                        return;
                                    }
                                    if (callback) {
                                        callback(nil, error);
                                    }
                                }];
}

- (ESTransferTask *)download:(ESFileInfoPub *)file
        callback:(void (^)(NSURL *output, NSError *error))callback {
    return [self download:file visible:YES callback:callback];
}

/// 下载文件
/// @param file 需要下载的文件
/// @param visible 是否在下载列表中可见, 预览时,默认不出现在下载列表
/// @param callback 下载完成/失败的回调
- (ESTransferTask *)download:(ESFileInfoPub *)file
         visible:(BOOL)visible
        callback:(void (^)(NSURL *output, NSError *error))callback {
    NSString *fileId = file.uuid;
    ESTransferTask *task = [self taskExist:fileId];
    task.downloadingSemaphore = self.downloadingSemaphore;
    ///本地已经存在该文件, 可能是之前下载过的, 就不继续下载了,
    BOOL isExist = [file hasLocalOriginalFile];
    if (isExist) {
        NSURL *localPath = [NSURL fileURLWithPath:[file getOriginalFileSavePath]];

        ///下载记录里没有, 则生成一个记录
        if (!task) {
            task = [ESTransferTask taskWithFile:file visible:visible];
        } else if (task && task.state == ESTransferStateCompleted) {
            [task updateTimestamp];
            [task setVisible:visible];
        }
        if (task.visible) {
            if (IsImageForFile(task.file)) {
                [UIImage saveImageURL:localPath];
            } else if (IsVideoForFile(task.file)) {
                [UIImage saveVideoURL:localPath];
            }
        }
        if (callback) {
            callback(localPath, nil);
        }
        
        //标记状态为完成
        [task updateDownloadTaskState:ESTransferStateCompleted];
        [self updateDownloadQueue:task];
        return task;
    }
    if (task) {
        [self removeFromDownloading:task];
        [self removeFromDownloaded:task];
        [self saveDownloadJob];
    }
    task = [ESTransferTask taskWithFile:file visible:visible];
    task.downloadingSemaphore = self.downloadingSemaphore;
  
    return [self downloadWithTask:task callback:callback];
}

- (ESTransferTask *)downloadPre:(ESFileInfoPub *)file
        callback:(void (^)(NSURL *output, NSError *error))callback {
    if ([file hasLocalOriginalFile]) {
        // 本地已有数据
        if (callback) {
            NSURL *localPath = [NSURL fileURLWithPath:[file getOriginalFileSavePath]];
            callback(localPath, nil);
        }
        return nil;
    }
    
    NSString *fileId = file.uuid;
    ESTransferTask *task = [self taskExist:fileId];
    if (!task || task.state == ESTransferStateCompleted) {
        //无此任务记录 或 任务状态已完成，则再下载一次
        return [self download:file visible:NO callback:callback];
    }
    
    task.downloadPreCallback = callback;
    if (task.state != ESTransferStateRunning) {
        task.downloadingSemaphore = self.downloadingSemaphore;
        [self downloadBySlice:task];
    }
    return task;
}

- (ESTransferTask *)downloadWithTask:(ESTransferTask *)task
                            callback:(void (^)(NSURL *output, NSError *error))callback {
    NSString *filePath = [task getCacheDownloadFilePath];
    if (filePath.length > 0) {
        NSURL *output = [NSURL fileURLWithPath:filePath];
        if (output) {
            if (task.visible) {
                if (IsImageForFile(task.file)) {
                    [UIImage saveImageURL:output];
                } else if (IsVideoForFile(task.file)) {
                    [UIImage saveVideoURL:output];
                }
            }
            if(callback){
                callback(output, nil);
            }
            [task updateDownloadTaskState:ESTransferStateCompleted];
            [self updateDownloadQueue:task];
            return task;
        }
    }
    
    if (task.downloadSliceModel.rangeArray.count == 0) {
        [task createDownloadRangeFragments];
    }
    
    if ([task isCompletedDownloadTask] && callback) {
        [task mergeDownloadData:^(NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(url, nil);
                }
            });
        }];
        return task;
    }
    
    [task updateDownloadTaskState:ESTransferStateReady];
    task.downloadCallback = callback;
    [self updateDownloadQueue:task];
    [self consumerDownloadHandler];
    return task;
}

- (void)consumerDownloadHandler {
    __block int transferNum = 0;
    [self.downloadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state == ESTransferStateRunning) {
            transferNum += 1;
        }
        if (transferNum >= ESMaxDownloadNum) {
            *stop = YES;
            return;
        }
    }];
    
    if (transferNum >= ESMaxDownloadNum) {
        return;
    }
    
    int balance = ESMaxDownloadNum - transferNum;
    NSMutableArray<ESTransferTask *> * waitingList = [NSMutableArray array];
    ESDLog(@"[上传下载] 当前待下载队列中任务数: %ld", self.downloadingQueue.count);
    [self.downloadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (waitingList.count >= balance) {
            *stop = YES;
            return;
        }
        
        if (obj.state == ESTransferStateReady) {
            [waitingList addObject:obj];
        }
    }];

    ESDLog(@"[上传下载] 当前还能下载的名额: %ld", waitingList.count);
    if (waitingList.count == 0) {
        return;
    }
    
    [waitingList enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self downloadBySlice:obj];
    }];
}

-(void)downloadBySlice:(ESTransferTask *)task {
    [task updateDownloadTaskState:ESTransferStateRunning];
    [task addTaskObserver:self];
    
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.apiName = @"download_file";
    request.serviceName = @"eulixspace-file-service";
    request.queries = @{@"uuid": task.file.uuid};
    
    [ESNetworking.shared downloadBySlice:request
                                         task:task
                                     progress:^(int64_t bytes,
                                                int64_t totalBytes,
                                                int64_t totalBytesExpected) {
        [task onUpdateProgress:bytes totalBytes:totalBytes totalBytesExpected:totalBytesExpected];
    }
                                     callback:^(NSURL *output, NSError *error) {
        [self processDownloadResult:task result:output error:error];
    }];
}

- (void)processDownloadResult:(ESTransferTask *)task result:(NSURL *)url error:(NSError *)error {
    if (error || url == nil || url.path.length == 0) {
        [task updateDownloadTaskState:ESTransferStateFailed];
        [self updateDownloadQueue:task];
        [task callDownloadResult:url error:error];
        return;
    }
    
    NSString *downPath = [task getDownloadFragmentDir];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",downPath, task.name];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        ///保存到相册
        if (task.visible) {
            if (IsImageForFile(task.file)) {
                [UIImage saveImageURL:url];
            } else if (IsVideoForFile(task.file)) {
                [UIImage saveVideoURL:url];
            }
        }
        [task updateDownloadTaskState:ESTransferStateCompleted];
        [self updateDownloadQueue:task];
        
        [task callDownloadResult:url error:error];
    } else {
        [task updateDownloadTaskState:ESTransferStateFailed];
        [task callDownloadResult:url error:error];
    }
}

//add copy ?
- (NSArray<ESTransferTask *> *)downloading {
    return [self.downloadingQueue yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return obj.visible;
    }];
}

- (NSArray<ESTransferTask *> *)downloaded {
    return [self.downloadedQueue yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return obj.visible;
    }];
}

- (NSArray<ESTransferTask *> *)uploading {
    return [self.uploadingQueue yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return obj.visible;
    }];
}

- (NSArray<ESTransferTask *> *)uploaded {
    return [self.uploadedQueue yc_selectWithBlock:^BOOL(NSUInteger idx, ESTransferTask *obj) {
        return obj.visible;
    }];
}

- (NSArray<ESTransferTask *> *)getAutoSyncUploadingTask {
    return self.autoSyncUploadingQueue;
}

- (void)clearAllSelectRecordState {
    [self.uploadedQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateSelectForRecord:NO];
    }];
    [self.downloadedQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateSelectForRecord:NO];
    }];
}

- (void)clearDownloaded:(NSArray<ESTransferTask *> *)itemArray {
    if (itemArray) {
        [itemArray yc_each:^(ESTransferTask *obj) {
            [obj clearDownloadCache];
            [self removeFromDownloading:obj];
            [self removeFromDownloaded:obj];
        }];
    } else {
        [self.downloadedQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj clearDownloadCache];
        }];
        [self.downloadedQueue removeAllObjects];
    }
    [self saveDownloadJob];
}

- (void)clearUploadTask:(NSArray<ESTransferTask *> *)itemArray {
    if (itemArray) {
        [itemArray enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == ESTransferStateCompleted) {
                [self removeFromUploaded:obj];
            } else {
                [self removeFromUploading:obj];
            }
            [obj clearUploadRecord];
        }];
    } else {
        [self removeAllFromUploaded];
    }
    
    [self saveUploadJob];
}

- (void)resumeUploadTask:(ESTransferTask *)item {
    [item updateUploadTaskState:ESTransferStateReady];
    [self consumerUploadHandler];
}

- (void)resumeAllUploadTask {
    [self.uploadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateUploadTaskState:ESTransferStateReady];
    }];
    [self consumerUploadHandler];
}

- (void)resumeAllDownloadTask {
    [self.downloadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateDownloadTaskState:ESTransferStateReady];
    }];
    [self consumerDownloadHandler];
}

- (void)suspendAllUploadTask {
    [self.uploadingQueue yc_each:^(ESTransferTask *obj) {
        [obj setUploadTaskSuspended];
    }];
}

- (void)suspendAllDownloadTask {
    [self.downloadingQueue yc_each:^(ESTransferTask *obj) {
        [obj updateDownloadTaskState:ESTransferStateSuspended];
    }];
}

// 暂停某个上传上的任务
- (void)suspendedUploadTask:(ESTransferTask *)item {
    [item setUploadTaskSuspended];
    [self consumerUploadHandler];
}

- (void)suspendedDownloadTask:(ESTransferTask *)item {
    [item updateDownloadTaskState:ESTransferStateSuspended];
    [item setDownloadFragmentStateSuspended];
}

- (void)resumeDownloadTask:(ESTransferTask *)item {
    [item updateDownloadTaskState:ESTransferStateReady];
    [self consumerDownloadHandler];
}

#pragma mark - Upload
- (void)upload:(ESUploadMetadata *)metadata
      callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback {
    for (ESTransferTask *task in self.uploadingQueue) {
        if([task.metadata.fileName isEqualToString:metadata.fileName]){
            return;
        }
    }
   
    if([metadata.permission isEqual:@"NO"]){
        ESTransferTask *task = [ESTransferTask taskWithMetaData:metadata];
        task.uploadingSemaphore = self.uploadingSemaphore;
        [task updateUploadTaskState:ESTransferStateReady];
        task.callback = callback;
        [self updateUploadQueue_V3:task];
    }else{
        [metadata writeDataToSandbox:^(NSString *path) {
            ESTransferTask *task = [ESTransferTask taskWithMetaData:metadata];
            task.uploadingSemaphore = self.uploadingSemaphore;
            [task updateUploadTaskState:ESTransferStateReady];
            task.callback = callback;
            metadata.url = path;
            [self updateUploadQueue_V3:task];
        }];
    }
}




// 相册同步功能调用
- (void)autoSyncUpload:(ESUploadMetadata *)metadata
          callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback {
    [metadata writeDataToSandbox:^(NSString *path) {
        ESTransferTask *task = [ESTransferTask taskWithMetaData:metadata];
        [self.autoSyncUploadingQueue addObject:task];
        [task updateUploadTaskState:ESTransferStateReady];
        [task setVisible:NO];
        task.callback = callback;

        metadata.url = path;
        [self calBetag:task];
        [self notifyAllEvent];
    }];
}

- (BOOL)isAutoSyncTask:(ESTransferTask *)task {
    return [self.autoSyncUploadingQueue containsObject:task];
}

- (void)calBetag:(ESTransferTask *)task {
    if (task.isCalBetaging) {
        return;
    }
    task.isCalBetaging = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:task.metadata.url]) {
        [task.metadata writeDataToSandbox:^(NSString *path) {
            task.metadata.url = path;
            [self doCalBetag:task];
        }];
        return;
    }
    
    [self doCalBetag:task];
}

- (void)doCalBetag:(ESTransferTask *)task {
    ESUpdataTool *tool = [ESUpdataTool new];
    [tool upDataWithPatpTmp:task completed:^(NSString *md5Name) {
        task.isCalBetaging = NO;
        
        if (!md5Name) {
            // 文件不存在了……
            [task updateUploadTaskState:ESTransferStateFailed];
            [task updateUploadTaskErrorState:ESTransferErrorStateUploadFailedMissing];
            [self saveUploadingQueueData];
            return;
        }
        
        [self saveUploadingQueueData];
        [self uploadBySlice:task];
    }];
}

- (void)updateUploadQueue_V3:(ESTransferTask *)task {
    if (!task.visible) {
        return;
    }
    switch (task.state) {
        case ESTransferStateCompleted: {
            [self removeFromUploading:task];
            [self.uploadedQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([task.metadata isEqual:obj.metadata] && [obj.targetDir isEqualToString:task.targetDir]) {
                    [self removeFromUploaded:obj];
                    *stop = YES;
                }
            }];
            [self addToUploaded:task];
            [self consumerUploadHandler];
            
            [self saveUploadJob];
            [self notifyUploadTaskComplete:task];
        } break;
        case ESTransferStateReady: {
            if (![self.uploadingQueue containsObject:task]) {
                [self addToUploading:task];
                [self consumerUploadHandler];
            }
            [self saveUploadingQueueData];
            [self callTaskCountBlock];
        } break;
        case ESTransferStateFailed: {
            [self saveUploadingQueueData];
        }
        default:
            break;
    }
}

- (void)consumerUploadHandler {
    __block int transferNum = 0;
    [self.uploadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state == ESTransferStateRunning || obj.isCalBetaging) {
            transferNum += 1;
        }
        if (transferNum >= ESMaxUploadNum) {
            *stop = YES;
            return;
        }
    }];
    
    ESDLog(@"[上传下载] 上传队列-正上传或正计算betag的任务: %d", transferNum);
    if (transferNum >= ESMaxUploadNum) {
        return;
    }
    
    int balance = ESMaxUploadNum - transferNum;
    NSMutableArray<ESTransferTask *> * waitingList = [NSMutableArray array];
    [self.uploadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (waitingList.count >= balance) {
            *stop = YES;
            return;
        }
        
        if (obj.state == ESTransferStateReady) {
            if (obj.sliceModel.fileBetag && obj.sliceModel.fileBetag.length > 0) {
                [waitingList addObject:obj];
            } else if (!obj.isCalBetaging && obj.sliceModel.fileBetag == nil) {
                [self calBetag:obj];
            }
        }
    }];

    ESDLog(@"[上传下载] 上传队列-可以上传的数量: %ld", waitingList.count);
    if (waitingList.count == 0) {
        return;
    }
    
    [waitingList enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self uploadBySlice:obj];
    }];
}

- (void)uploadBySlice:(ESTransferTask *)task {
    if ([self hasSameBetagTaskIsRuning:task.sliceModel.fileBetag]) {
        ESDLog(@"[上传下载] 开始上传-分片-same betag uploading:%@, %@", task.name, task.sliceModel.fileBetag);
        return;
    }
    
    ESDLog(@"[上传下载] 开始上传-分片:%@", task.name);
    [task updateUploadTaskState:ESTransferStateRunning];
    [task addTaskObserver:self];
    [ESNetworking.shared uploadBySlice:task dir:task.metadata.folderId progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
        [task onUpdateProgress:bytes totalBytes:totalBytes totalBytesExpected:totalBytesExpected];
    } callback:^(ESRspUploadRspBody *result, NSError *error) {
        [self processUploadResult:task result:result error:error];
    }];
}

- (BOOL)hasSameBetagTaskIsRuning:(NSString *)betag {
    __block BOOL hasSameBetagUploading = NO;
    [self.uploadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state == ESTransferStateRunning && [obj.sliceModel.fileBetag isEqualToString:betag]) {
            hasSameBetagUploading = YES;
            * stop = YES;
        }
    }];
    
    return hasSameBetagUploading;
}

- (void)processUploadResult:(ESTransferTask *)task result:(ESRspUploadRspBody *)result error:(NSError *)error {
    BOOL isAutoSyncTask = [self isAutoSyncTask:task];
    if (!result || error != nil) {
        if (isAutoSyncTask) {
            [task updateUploadTaskState:ESTransferStateFailed];
            [self.autoSyncUploadingQueue removeObject:task];
        } else {
            [task updateUploadTaskState:ESTransferStateFailed];
            [self updateUploadQueue_V3:task];
        }
        [task callResult:result error:error];
        
        if (result.code.integerValue == ESApiCodeFileNotEnoughSpace) {
            [ESToast toastError:TEXT_SYNC_NOT_ENOUGH_SPACE_PROMPT];
        }
        return;
    }
    
    [task updateUploadTaskState:ESTransferStateCompleted];
    //移除待上传文件
    [task.filePath.fullCachePath clearCachePath];
    
    if (isAutoSyncTask) {
        [self.autoSyncUploadingQueue removeObject:task];
    } else {
        [task setUploadResult:result.results];
        [self updateUploadQueue_V3:task];
    }
    
    [task callResult:result error:error];
}

- (void)notifyUploadTaskComplete:(ESTransferTask *)task {
    [[self.taskObservers allObjects] enumerateObjectsUsingBlock:^(id<ESTransferManagerProtocl>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(notifyUploadTransferTaskComplete:)]) {
            [obj notifyUploadTransferTaskComplete:task];
        }
    }];
}

- (void)addTaskStatusObserver:(id)observer {
    [self.taskObservers addObject:observer];
}

- (BOOL)hasSameBetagTaskInUploadingQueue:(ESTransferTask *)item {
    __block BOOL hasSame = NO;
    [self.uploadingQueue enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != item && [item.sliceModel.fileBetag isEqualToString:obj.sliceModel.fileBetag]) {
            hasSame = YES;
            * stop = YES;
        }
    }];
    
    return hasSame;
}

- (NSHashTable *)taskObservers {
    if (_taskObservers == nil) {
        _taskObservers = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return _taskObservers;
}

- (void)addToUploading:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
    [self.uploadingQueue addObject:task];
    dispatch_semaphore_signal(self.uploadingSemaphore);
}

- (void)removeFromUploading:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
    [self.uploadingQueue removeObject:task];
    dispatch_semaphore_signal(self.uploadingSemaphore);
}

- (void)addToUploaded:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.uploadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.uploadedQueue addObject:task];
    dispatch_semaphore_signal(self.uploadedSemaphore);
}

- (void)removeFromUploaded:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.uploadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.uploadedQueue removeObject:task];
    dispatch_semaphore_signal(self.uploadedSemaphore);
}

- (void)removeAllFromUploaded {
    dispatch_semaphore_wait(self.uploadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.uploadedQueue removeAllObjects];
    dispatch_semaphore_signal(self.uploadedSemaphore);
}

- (void)addToDownloading:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
    [self.downloadingQueue addObject:task];
    dispatch_semaphore_signal(self.downloadingSemaphore);
}

- (void)removeFromDownloading:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
    [self.downloadingQueue removeObject:task];
    dispatch_semaphore_signal(self.downloadingSemaphore);
}

- (void)addToDownloaded:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.downloadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.downloadedQueue addObject:task];
    dispatch_semaphore_signal(self.downloadedSemaphore);
}

- (void)removeFromDownloaded:(ESTransferTask *)task {
    dispatch_semaphore_wait(self.downloadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.downloadedQueue removeObject:task];
    dispatch_semaphore_signal(self.downloadedSemaphore);
}

- (void)removeAllFromDownloaded {
    dispatch_semaphore_wait(self.downloadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.downloadedQueue removeAllObjects];
    dispatch_semaphore_signal(self.downloadedSemaphore);
}

@end
