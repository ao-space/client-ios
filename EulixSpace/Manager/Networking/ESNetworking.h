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
//  ESNetworking.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTransferTask.h"
#import "ESTransferDefine.h"
#import "ESApiClient.h"

static const NSUInteger kNetworkingSessionMaximumConnectionsPerHost = 1;

// 局域网下并发数
static const NSUInteger kNetworkingSessionMaximumConnectionsPerHostForLan = 4;


@class AFURLSessionManager;
@class AFHTTPSessionManager;
@class ESRealCallRequest;
@class UIApplication;
@class ESUploadMetadata;
@class ESRspUploadRspBody;
@class ESNetworkingTask;

typedef NS_ENUM(NSUInteger, ESNetworkingErrorCode) {
    ESNetworkingErrorCodeFailedToCreateToken,
    ESNetworkingErrorCodeFailedToReadAssetData,
    ESNetworkingErrorCodeFailedToEncryptData,
    ESNetworkingErrorCodeCanceled,
};


@class ESBoxItem;
@interface ESNetworking : NSObject

@property (nonatomic, readonly) AFNetworkReachabilityStatus reachabilityStatus;

+ (instancetype)shared;

- (void)URLSessionDidFinishEventsForBackgroundURLSession;

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
                      completionHandler:(void (^)(void))completionHandler;

- (void)getOcIdInBackgroundSession:(void (^)(NSArray<NSString *> *listOcId))completionHandler;

- (void)getAllTasksInBackgroundSession:(void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionHandler;

- (void)getOcIdInDefaultSession:(void (^)(NSArray<NSString *> *listOcId))completionHandler;

- (void)getAllTasksInDefaultSession:(void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionHandler;

- (void)cancelAllTransfer:(void (^)(void))completion;

// 只能用来下载图片
- (ESNetworkingTask *)downloadRequest:(ESRealCallRequest *)request
                           targetPath:(NSString *)targetPath
                             progress:(ESProgressHandler)progress
                             callback:(void (^)(NSURL *output, NSError *error))callback;

// 只能用来下载图片
- (ESNetworkingTask *)downloadRequest:(ESRealCallRequest *)request
                                  box:(ESBoxItem *)box
                           targetPath:(NSString *)targetPath
                             progress:(ESProgressHandler)progress
                             callback:(void (^)(NSURL *output, NSError *error))callback;
// 上传头像有在用
- (ESNetworkingTask *)uploadFile:(NSString *)filePath
                             dir:(NSString *)dir
                         request:(ESRealCallRequest *)request
                        progress:(ESProgressHandler)progress
                        callback:(void (^)(ESRspUploadRspBody *output, NSError *error))callback;

// 分片上传
- (void)uploadBySlice:(ESTransferTask *)task
                  dir:(NSString *)dir
             progress:(ESProgressHandler)progress
             callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback;

// 分片下载
- (void)downloadBySlice:(ESRealCallRequest *)request
                   task:(ESTransferTask *)task
               progress:(ESProgressHandler)progress
               callback:(void (^)(NSURL *output, NSError *error))callback;

@end

