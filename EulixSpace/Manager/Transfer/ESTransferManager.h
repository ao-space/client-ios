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
//  ESTransferManager.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESNetworking.h"
#import "ESTransferTask.h"
#import "ESFileInfoPub.h"
#import "ESUploadRspBody.h"
#import <Foundation/Foundation.h>

@class AFURLSessionManager;
@class AFHTTPSessionManager;
@class ESRealCallRequest;
@class ESUploadMetadata;

@protocol ESTransferManagerProtocl <NSObject>

@optional
- (void)notifyUploadTransferTaskComplete:(ESTransferTask *)task;

@end

@interface ESTransferManager : NSObject

+ (instancetype)manager;

+ (instancetype)newServiceInstance;
- (void)startService;
- (void)resetService;

@property (nonatomic, copy) void (^taskCountBlock)(NSInteger count);


/**
 分片下载接口，默认存储在 NSCachesDirectory 目录下，下载列表中可见
 @param file 需要下载的文件，一般由服务端返回，其中必传参数 uuid 是文件唯一标识符；其他参数，比如 name，用于显示
 @param callback 下载完成/失败的回调
 @result 下载任务，可以从中获取下载进度、速度等信息，建议以 weak 方式引用
 */
- (ESTransferTask *)download:(ESFileInfoPub *)file
        callback:(void (^)(NSURL *output, NSError *error))callback;


/**
 分片下载接口，默认存储在 NSCachesDirectory 目录下
 @param file 需要下载的文件，一般由服务端返回，其中必传参数 uuid 是文件唯一标识符；其他参数，比如 name，用于显示
 @param visible 是否在下载列表中可见, 预览时, 默认不出现在下载列表
 @param callback 下载完成/失败的回调
 @result 下载任务，可以从中获取下载进度、速度等信息，建议以 weak 方式引用
 */
- (ESTransferTask *)download:(ESFileInfoPub *)file
         visible:(BOOL)visible
        callback:(void (^)(NSURL * output, NSError *error))callback;

/**
 下载接口
 业务调用方比较特殊，不参与下载队列的排队规则，传输列表队列中不可见
 */
- (ESTransferTask *)downloadPre:(ESFileInfoPub *)file
           callback:(void (^)(NSURL *output, NSError *error))callback;

/**
 压缩图下载，默认存储在 NSCachesDirectory 目录下，路径中包含 uuid
 */
- (void)preview:(ESFileInfoPub *)file
       progress:(ESProgressHandler)progress
       callback:(void (^)(NSURL *output, NSError *error))callback;

- (void)upload:(ESUploadMetadata *)metadata
      callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback;

// 相册同步功能调用
- (void)autoSyncUpload:(ESUploadMetadata *)metadata
              callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback;

// 上传
- (void)resumeUploadTask:(ESTransferTask *)item;
- (void)suspendedUploadTask:(ESTransferTask *)item;
- (void)resumeAllUploadTask;
- (void)suspendAllUploadTask;

// 下载
- (void)resumeDownloadTask:(ESTransferTask *)item;
- (void)suspendedDownloadTask:(ESTransferTask *)item;
- (void)resumeAllDownloadTask;
- (void)suspendAllDownloadTask;

- (void)addTaskStatusObserver:(id<ESTransferManagerProtocl>)observer;

- (BOOL)hasSameBetagTaskInUploadingQueue:(ESTransferTask *)item;

- (NSArray<ESTransferTask *> *)getAutoSyncUploadingTask;

// 清除选中记录
- (void)clearAllSelectRecordState;
// 清除上传任务记录
- (void)clearUploadTask:(NSArray<ESTransferTask *> *)itemArray;

// 获取上传未完成且可见的任务列表
- (NSArray<ESTransferTask *> *)uploading;
// 获取已上传完成且可见的任务列表
- (NSArray<ESTransferTask *> *)uploaded;

// zdz todo just for test
@property (nonatomic, strong) NSMutableArray * transferResultList;
- (void)addTransferResult:(NSString *)result;
@end
