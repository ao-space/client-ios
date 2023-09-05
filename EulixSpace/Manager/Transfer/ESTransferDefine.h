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
//  ESTransferDefine.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESTransferDefine_h
#define ESTransferDefine_h

#import <UIKit/UIKit.h>

// 文件上传并发数最大数，不包含相册同步这个任务
#define ESMaxUploadNum 3

// 文件下载并发数最大数
#define ESMaxDownloadNum 3

// 大文件分片上传时，内部分片并发数
#define ESMaxSliceUploadNum 4

// 大文件分片下载时，内部分片并发数
#define ESMaxSliceDownloadNum 4


// 达到8M的内容就进行分片上传的逻辑:8 * 1024 * 1024
#define MIN_SLICE_UNIT 8388608

// 上传分片大小 4 * 1024 * 1024
#define UploadFileFragmentMaxSize 4194304

// 下载分片大小 4 * 1024 * 1024
#define DownloadFileFragmentMaxSize 4194304

// 传输状态
typedef NS_ENUM(NSUInteger, ESTransferState) {
    ESTransferStateReady,     // 等待传输
    ESTransferStateRunning,   // 正在传输
    ESTransferStateSuspended, // 传输暂停
    ESTransferStateCompleted, // 传输完成
    ESTransferStateFailed     // 传输失败
};

/**
 bytes:：此次传输的数量
 totalBytes： 已传输的数量
 totalBytesExpected：文件的总大小
 */
typedef void (^ESProgressHandler)(int64_t bytes,
                                  int64_t totalBytes,
                                  int64_t totalBytesExpected);


// 传输通道
typedef NS_ENUM(NSUInteger, ESTransferWay) {
    ESTransferWay_HTTP = 1,
    ESTransferWay_HTTP_FILEAPI, // 局域网下，直接对接 fileapi 进行传输
};

// 传输错误码
typedef NS_ENUM(NSUInteger, ESTransferErrorState) {
    ESTransferErrorStateFileNotExist = 1003,     // 下载的原文件已不存在
    
    ESTransferErrorStateUploadFailedMissing = 100001, // 上传的文件丢失了
};


#endif /* ESTransferDefine_h */
