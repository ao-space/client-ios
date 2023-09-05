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
//  ESNetworking.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESNetworking.h"
#import "ESAES.h"
#import "ESToast.h"
#import "ESAccountManager.h"
#import "ESApiCode.h"
#import "ESBoxManager.h"
#import "ESCommunication.h"
#import "ESCommunicationBackground.h"
#import "ESFileHandleManager.h"
#import "ESGatewayManager.h"
#import "ESGlobalDefine.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESMultipartNetworking.h"
#import "ESNetworkingTask.h"
#import "ESUploadEntity.h"
#import "ESUpdataTool.h"
#import "ESFileStreamOperation.h"
#import "ESCommentCachePlistData.h"
#import "ESApiClient.h"
#import "ESRspUploadRspBody.h"
#import "ESSpaceGatewayGenericCallServiceApi.h"
#import "ESRspCreateMultipartTaskRsp.h"
#import "ESMultipartApi.h"
#import <YCEasyTool/YCEventNotifier.h>
#import <YYModel/YYModel.h>
#include <CommonCrypto/CommonDigest.h>
#import "ESCommentCachePlistData.h"
#import "ESReTransmissionManager.h"
#import "NSError+ESTool.h"
#import "NSArray+ESTool.h"
#import "ESLanTransferManager.h"
#import "ESLocalNetworking.h"

@interface ESNetworkingTask ()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

static NSString *const kESTransferHeaderFileSizeKey = @"File-Size";

static NSErrorDomain const ESNetworkingErrorDomain = @"ESNetworkingErrorDomain";

@interface ESNetworking ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionTask *> *taskDict;
// key:task  value:requestId
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, NSString *> *taskAndRequestIdDict;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESProgressHandler> *progressDict;

/// 下载
@property (nonatomic, strong) AFURLSessionManager *downloadManager;
@property (nonatomic, strong) AFURLSessionManager *downloadManager4Lan;

/// 后台上传
@property (nonatomic, strong) NSURLSession *sessionManagerBackground;

@property (nonatomic, strong) NSURLSession *sessionManagerBackgroundWWan;

@property (nonatomic, copy) void (^completionHandler)(void);

@property (nonatomic, strong) dispatch_queue_t decryptQueue;

@property (nonatomic, strong) dispatch_queue_t taskQueue;

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) ESMultipartNetworking *multipart;

@end

@implementation ESNetworking

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self monitorNetworkReachability];
        [self initData];
    }
    return self;
}

- (void)initData {
    _multipart = ESMultipartNetworking.new;
    _taskDict = NSMutableDictionary.dictionary;
    _taskAndRequestIdDict = NSMutableDictionary.dictionary;
    _progressDict = NSMutableDictionary.dictionary;
    _lock = [[NSLock alloc] init];
    weakfy(self);
    {
        [self initDownloadSession4Internet];
        [self initDownloadSession4Lan];
    }

    [self observeSession:ESCommunication.shared.getSessionManager];
    [self observeSession:ESCommunication.shared.getSessionWWanManager];
    {
        [ESCommunicationBackground.shared setTaskDidSendBodyDataBlock:^(NSURLSession *_Nonnull session,
                                                                        NSURLSessionTask *_Nonnull task,
                                                                        int64_t bytes,
                                                                        int64_t totalBytes,
                                                                        int64_t totalBytesExpected) {
            strongfy(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lock lock];
                NSString *requestId = [self.taskDict allKeysForObject:task].firstObject;
                [self.lock unlock];
                ESProgressHandler progress = self.progressDict[requestId];
                if (progress) {
                    progress(bytes, totalBytes, totalBytesExpected);
                }
            });
        }];
    }
}

- (void)initDownloadSession4Internet {
    weakfy(self);
    NSURLSessionConfiguration *configuration = [self getDownloadSessionConfiguration:kNetworkingSessionMaximumConnectionsPerHost];
    self.downloadManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    [self.downloadManager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *_Nonnull session) {
        strongfy(self);
        if (self.completionHandler) {
            self.completionHandler();
        }
    }];
    [self.downloadManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *_Nonnull session,
                                                             NSURLSessionDownloadTask *_Nonnull downloadTask,
                                                             int64_t bytes,
                                                             int64_t totalBytes,
                                                             int64_t totalBytesExpected) {
        strongfy(self);
        [self onDownloadProcess:downloadTask bytes:bytes totalBytes:totalBytes totalBytesExpected:totalBytesExpected];
    }];
}

- (void)initDownloadSession4Lan {
    weakfy(self);
    NSURLSessionConfiguration *configuration = [self getDownloadSessionConfiguration:kNetworkingSessionMaximumConnectionsPerHostForLan];
    
    self.downloadManager4Lan = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    [self.downloadManager4Lan setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *_Nonnull session) {
        strongfy(self);
        if (self.completionHandler) {
            self.completionHandler();
        }
    }];
    [self.downloadManager4Lan setDownloadTaskDidWriteDataBlock:^(NSURLSession *_Nonnull session,
                                                             NSURLSessionDownloadTask *_Nonnull downloadTask,
                                                             int64_t bytes,
                                                             int64_t totalBytes,
                                                             int64_t totalBytesExpected) {
        strongfy(self);
        [self onDownloadProcess:downloadTask bytes:bytes totalBytes:totalBytes totalBytesExpected:totalBytesExpected];
    }];
}

- (NSURLSessionConfiguration *)getDownloadSessionConfiguration:(int)HTTPMaximumConnectionsPerHost {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.sessionSendsLaunchEvents = YES;
    configuration.discretionary = YES;
    configuration.HTTPMaximumConnectionsPerHost = HTTPMaximumConnectionsPerHost;
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    return configuration;
}

- (void)onDownloadProcess:(NSURLSessionDownloadTask *)downloadTask
                    bytes:(int64_t)bytes
               totalBytes:(int64_t)totalBytes
       totalBytesExpected:(int64_t)totalBytesExpected {
    int64_t fileSize = totalBytesExpected;
    if (totalBytesExpected == -1) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)downloadTask.response;
        fileSize = [response.allHeaderFields[kESTransferHeaderFileSizeKey] longLongValue];
    }
    
    [self.lock lock];
    NSString * requestId = self.taskAndRequestIdDict[downloadTask];
    [self.lock unlock];
    ESProgressHandler progress = self.progressDict[requestId];
    if (progress) {
        progress(bytes, totalBytes, fileSize);
    }
}

- (void)observeSession:(AFHTTPSessionManager *)session {
    weakfy(self);
    [session setTaskDidSendBodyDataBlock:^(NSURLSession *_Nonnull session,
                                           NSURLSessionTask *_Nonnull task,
                                           int64_t bytes,
                                           int64_t totalBytes,
                                           int64_t totalBytesExpected) {
        strongfy(self);
        [self.lock lock];
        NSString *requestId = [self.taskDict allKeysForObject:task].firstObject;
        [self.lock unlock];
        ESProgressHandler progress = self.progressDict[requestId];
        if (progress) {
            progress(bytes, totalBytes, totalBytesExpected);
        }
    }];
}

// 只能用来下载图片
- (ESNetworkingTask *)downloadRequest:(ESRealCallRequest *)request
                                  box:(ESBoxItem *)box
                           targetPath:(NSString *)targetPath
                             progress:(ESProgressHandler)progress
                             callback:(void (^)(NSURL *output, NSError *error))callback {
    ESNetworkingTask *networkingTask = [ESNetworkingTask new];
    [ESGatewayManager token:box defaultHeaders:nil callback:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            if (callback) {
                callback(nil, nil);
            }
            return;
        }
        //任务取消
        if (networkingTask.canceled) {
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        

        NSString *requestId = request.requestId;
        ESSpaceGatewayGenericCallServiceApi *api = [ESSpaceGatewayGenericCallServiceApi new];
        ESApiClient *apiClient = api.apiClient;
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:apiClient.configuration.defaultHeaders];
        headerParams[@"Request-Id"] = requestId;
        headerParams[@"Accept"] = @"*/*"; //application/octet-stream
        headerParams[@"Content-Type"] = @"application/json";
        [headerParams addEntriesFromDictionary:request.headers];
        request.headers = headerParams;
    

        ESCallRequest *callRequest = [ESCallRequest new];
        callRequest.accessToken = token.accessToken;

        if (request) {
            //加密body
            NSString *body = [request.json aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
            callRequest.body = body;
        }

        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"/space/v1/api/gateway/download" relativeToURL:apiClient.baseURL]];

        urlRequest.allHTTPHeaderFields = headerParams;
        [urlRequest setHTTPMethod:@"POST"];

        [urlRequest setHTTPBody:[callRequest yy_modelToJSONData]];

        AFURLSessionManager *downloadManager = self.downloadManager;

        NSURLSessionTask *downloadTask;
        weakfy(self);
        //先下载到临时的加密文件路径中
        NSString *encryptPath = [NSString stringWithFormat:@"%@.encrypt", targetPath];
        downloadTask = [downloadManager downloadTaskWithRequest:urlRequest
            progress:nil
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                if ([http isKindOfClass:[NSHTTPURLResponse class]] && http.statusCode != 200) {
                    return targetPath;
                }
                return [NSURL fileURLWithPath:encryptPath];
            }
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                strongfy(self);
                [self.lock lock];
                self.taskDict[requestId] = nil;
                self.progressDict[requestId] = nil;
                [self.lock unlock];
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                    NSString *contentDisposition = http.allHeaderFields[@"Content-Disposition"];
                    NSString *contentType = http.allHeaderFields[@"Content-Type"];
                    if (http.statusCode != 200
                        || ([contentType containsString:@"text/plain"] && ![contentDisposition containsString:@"txt"])) {
                        [targetPath clearCachePath];
                        [encryptPath clearCachePath];
                        if (callback) {
                            callback(nil, error);
                        }
                        return;
                    }
                }
                if (!error) {
                    dispatch_async(self.decryptQueue, ^{
                        //解密文件
                        [ESFileHandleManager.manager decryptFile:encryptPath target:targetPath key:token.secretKey iv:token.secretIV];
                        //清理下载下来的加密文件
                        [encryptPath clearCachePath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (callback) {
                                callback([NSURL fileURLWithPath:targetPath], nil);
                            }
                        });
                    });
                } else {
                    //清理下载下来的加密文件
                    [encryptPath clearCachePath];
                    if (callback) {
                        callback(nil, error);
                    }
                }
            }];
        if (networkingTask.canceled) {
            [downloadTask cancel];
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        [self.lock lock];
        self.taskDict[requestId] = downloadTask;
        self.progressDict[requestId] = progress;
        [self.lock unlock];
        networkingTask.task = downloadTask;
        [downloadTask resume];
    }];
    return networkingTask;
}

// 只能用来下载图片
- (ESNetworkingTask *)downloadRequest:(ESRealCallRequest *)request
                           targetPath:(NSString *)targetPath
                             progress:(ESProgressHandler)progress
                             callback:(void (^)(NSURL *output, NSError *error))callback {
    ESNetworkingTask *networkingTask = [ESNetworkingTask new];
    [self token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            if (callback) {
                callback(nil, nil);
            }
            return;
        }
        //任务取消
        if (networkingTask.canceled) {
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        

        NSString *requestId = request.requestId;
        ESSpaceGatewayGenericCallServiceApi *api = [ESSpaceGatewayGenericCallServiceApi new];
        ESApiClient *apiClient = api.apiClient;
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:apiClient.configuration.defaultHeaders];
        headerParams[@"Request-Id"] = requestId;
        headerParams[@"Accept"] = @"*/*"; //application/octet-stream
        headerParams[@"Content-Type"] = @"application/json";
        [headerParams addEntriesFromDictionary:request.headers];
        request.headers = headerParams;
    

        ESCallRequest *callRequest = [ESCallRequest new];
        callRequest.accessToken = token.accessToken;

        if (request) {
            //加密body
            NSString *body = [request.json aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
            callRequest.body = body;
        }

        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"/space/v1/api/gateway/download" relativeToURL:apiClient.baseURL]];

        urlRequest.allHTTPHeaderFields = headerParams;
        [urlRequest setHTTPMethod:@"POST"];

        [urlRequest setHTTPBody:[callRequest yy_modelToJSONData]];

        AFURLSessionManager *downloadManager = self.downloadManager;

        NSURLSessionTask *downloadTask;
        weakfy(self);
        //先下载到临时的加密文件路径中
        NSString *encryptPath = [NSString stringWithFormat:@"%@.encrypt", targetPath];
        downloadTask = [downloadManager downloadTaskWithRequest:urlRequest
            progress:nil
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                if ([http isKindOfClass:[NSHTTPURLResponse class]] && http.statusCode != 200) {
                    return targetPath;
                }
                return [NSURL fileURLWithPath:encryptPath];
            }
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                strongfy(self);
                [self.lock lock];
                self.taskDict[requestId] = nil;
                self.progressDict[requestId] = nil;
                [self.lock unlock];
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                    NSString *contentDisposition = http.allHeaderFields[@"Content-Disposition"];
                    NSString *contentType = http.allHeaderFields[@"Content-Type"];
                    if (http.statusCode != 200
                        || ([contentType containsString:@"text/plain"] && ![contentDisposition containsString:@"txt"])) {
                        [targetPath clearCachePath];
                        [encryptPath clearCachePath];
                        if (callback) {
                            callback(nil, error);
                        }
                        return;
                    }
                }
                if (!error) {
                    dispatch_async(self.decryptQueue, ^{
                        //解密文件
                        [ESFileHandleManager.manager decryptFile:encryptPath target:targetPath key:token.secretKey iv:token.secretIV];
                        //清理下载下来的加密文件
                        [encryptPath clearCachePath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (callback) {
                                callback([NSURL fileURLWithPath:targetPath], nil);
                            }
                        });
                    });
                } else {
                    //清理下载下来的加密文件
                    [encryptPath clearCachePath];
                    if (callback) {
                        callback(nil, error);
                    }
                }
            }];
        if (networkingTask.canceled) {
            [downloadTask cancel];
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        [self.lock lock];
        self.taskDict[requestId] = downloadTask;
        self.progressDict[requestId] = progress;
        [self.lock unlock];
        networkingTask.task = downloadTask;
        [downloadTask resume];
    }];
    return networkingTask;
}

- (void)token:(ESGatewayManageOnToken)callback {
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        dispatch_async(self.taskQueue, ^{
            if (callback) {
                callback(token, error);
            }
        });
    }];
}

// 合并分片
- (void)mergeSlice:(NSString *)uploadId task:(ESTransferTask *)task callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback {
    ESUploadMetadata * metadata = task.metadata;
    ESDLog(@"[上传下载] %@, 断点续传-合并-发送请求：%@", metadata.fileName, uploadId);
    if (!uploadId) {
        return;
    }
    
    task.endMultiPartReqTime = [[NSDate date] timeIntervalSince1970];
    [self.multipart completeUploadId:uploadId completionBlock:^(ESRspCompleteMultipartTaskRsp *output, NSError *error) {
        task.endMultiPartRespTime = [[NSDate date] timeIntervalSince1970];
        if (error && callback) {
            ESDLog(@"[上传下载] %@, 断点续传-合并-请求失败：%@", metadata.fileName, error);
            callback(nil, error);
            return;
        }

        if (output.code.intValue == 200) {
            ESDLog(@"[上传下载] %@, 断点续传-合并-成功", metadata.fileName);
            [task updateUploadMetadataStatue:ESUploadMetadataStatusUploadSuccess];
            ESRspUploadRspBody * body = [ESMultipartNetworking transferModel:output];
            if (callback) {
                callback(body, nil);
            }
            [self saveCompleVideoMetadata:metadata];
        } else {
            ESDLog(@"[上传下载] %@, 断点续传-合并-失败 %@", metadata.fileName, output.message);
            if (callback) {
                NSError * error = [NSError errorWithDomain:output.message ?: @"合并分片失败" code:-1 userInfo:nil];
                callback(nil, error);
            }
        }
    }];
}

// 分片下载
- (void)downloadBySlice:(ESRealCallRequest *)request
                  task:(ESTransferTask *)task
              progress:(ESProgressHandler)progress
              callback:(void (^)(NSURL *output, NSError *error))callback {
    if (task.state == ESTransferStateSuspended) {
        return;
    }
    
    if ([task isCompletedDownloadTask]) {
        [task mergeDownloadData:^(NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(url, nil);
                }
            });
        }];
        return;
    }
    
    for (int i = 0; i < ESMaxSliceDownloadNum; i++) {
        ESDownloadFragmentModel * item = [task.downloadSliceModel getCanDownloadFragment];
        [task updateDownloadSliceTransferWay:item way:ESTransferWay_HTTP];
        [self doSliceDownloadRunLoop:request task:task item:item progress:progress callback:callback];
    }
}

- (void)doSliceDownloadRunLoop:(ESRealCallRequest *)request
                          task:(ESTransferTask *)task
                          item:(ESDownloadFragmentModel *)item
                      progress:(ESProgressHandler)progress
                      callback:(void (^)(NSURL *output, NSError *error))callback {
  
    if (task.state == ESTransferStateSuspended || item == nil || item.downloadFragmentState == ESTransferStateRunning) {
        return;
    }
    
    [task updateDownloadSliceState:item state:ESTransferStateRunning];
    [self token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            if (callback) {
                [task updateDownloadSliceState:item state:ESTransferStateFailed];

                callback(nil, nil);
            }
            return;
        }
        
        NSString * rangeStr = item.range;
        NSString *requestId = request.requestId;
        ESSpaceGatewayGenericCallServiceApi *api = [ESSpaceGatewayGenericCallServiceApi new];
        ESApiClient *apiClient = api.apiClient;
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:apiClient.configuration.defaultHeaders];
        headerParams[@"Request-Id"] = requestId;
        headerParams[@"Accept"] = @"*/*";
        headerParams[@"Content-Type"] = @"application/json";
        [headerParams addEntriesFromDictionary:request.headers];
        headerParams[@"Range"] = rangeStr;
        request.headers = headerParams;

        if ([rangeStr hasPrefix:@"bytes=0-"]) {
            task.downloadBeginTime = [[NSDate date] timeIntervalSince1970];
        }
        
        item.startDownloadTime = [[NSDate date] timeIntervalSince1970];
        BOOL isLanNet = [ESLocalNetworking isLANReachable];
        if (!task.isCertificateFailed && isLanNet && [ESLanTransferManager.shared hasCertData]) {
            NSMutableDictionary * queriesParams = [NSMutableDictionary dictionary];
            queriesParams[@"uuid"] = task.file.uuid;
            queriesParams[@"userId"] = [[ESBoxManager manager] getAoidValue];
            
            NSMutableDictionary * header = [NSMutableDictionary dictionary];
            header[@"Range"] = rangeStr;
            // Token 的生成算法： {aoid}-{hex(md5({aoid}-bp-{secret}))的前20个字符}
            NSString * hex = [[[NSString alloc] initWithFormat:@"%@-bp-%@", ESBoxManager.activeBox.aoid, token.secretKey].md5 substringToIndex:20];
            NSString * tokenKey = [[NSString alloc] initWithFormat:@"%@-%@", ESBoxManager.activeBox.aoid, hex];
            header[@"Token"] = tokenKey;
            header[@"Request-Id"] = requestId;

            [task updateDownloadSliceTransferWay:item way:ESTransferWay_HTTP_FILEAPI];
            NSString * savePath = [task getDownloadRangePath:item];
            
            NSURLSessionDownloadTask * downloadTask = [ESLanTransferManager.shared downloadFile:savePath host:apiClient.baseURL.host query:queriesParams header:header progress:progress completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
                if (error && !error.userInfo[@"code"]) {
                    task.isCertificateFailed = YES;
                }
                [self processDownloadResult:requestId task:task item:item token:token callback:callback error:error request:request progress:progress];
            }];
            
            [self.lock lock];
            if (downloadTask) {
                self.taskAndRequestIdDict[downloadTask] = requestId;
            }
            self.progressDict[requestId] = progress;
            [self.lock unlock];
            
            NSString * key = [[NSString alloc] initWithFormat:@"%@_%@", task.name, item.range];
            [[ESReTransmissionManager Instance] addTransmission:key];
            [downloadTask resume];
            return;
        }
        
        ESCallRequest *callRequest = [ESCallRequest new];
        callRequest.accessToken = token.accessToken;
        
        if (request) {
            //加密body
            NSString *body = [request.json aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
            callRequest.body = body;
        }
        
        NSString * baseUrl = apiClient.baseURL.absoluteString;
        NSString * downloadPath = @"/space/v1/api/gateway/download";
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:downloadPath relativeToURL:apiClient.baseURL]];
        
        urlRequest.allHTTPHeaderFields = headerParams;
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[callRequest yy_modelToJSONData]];
        
        NSString * encryptPath = [task getDownloadRangeEncryptPath:item];
        AFURLSessionManager *downloadManager = self.downloadManager;
        if ([self isLan:baseUrl]) {
            downloadManager = self.downloadManager4Lan;
        }
        NSURLSessionTask * downloadTask = [downloadManager downloadTaskWithRequest:urlRequest
                                                       progress:nil
                                                    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            //先下载到临时的加密文件路径中
            return [NSURL fileURLWithPath:encryptPath];
        }
                                              completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSError * tmpError;
            if (error) {
                ESDLog(@"[上传下载] 下载失败-http name:%@, range:%@", task.name, rangeStr);
                tmpError = error;
            } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                if (http.statusCode != 200) {
                    ESDLog(@"[上传下载] 下载失败-http name:%@, range:%@, code:%ld", task.name, rangeStr, http.statusCode);
                    tmpError = [NSError errorWithDomain:@"http statusCode不是200" code:http.statusCode userInfo:@{NSLocalizedDescriptionKey : @"返回的statusCode不是200"}];
                }
            }
            [task updateDownloadSliceTransferWay:item way:ESTransferWay_HTTP];

            [self processDownloadResult:requestId task:task item:item token:token callback:callback error:tmpError request:request progress:progress];
        }];
        
        [self.lock lock];
//        self.taskDict[requestId] = downloadTask;
        if (downloadTask) {
            self.taskAndRequestIdDict[downloadTask] = requestId;
        }
        self.progressDict[requestId] = progress;
        [self.lock unlock];
        
        NSString * key = [[NSString alloc] initWithFormat:@"%@_%@", task.name, item.range];
        [[ESReTransmissionManager Instance] addTransmission:key];
        ESDLog(@"[上传下载] http下载开始：%@，range:%@", task.name, rangeStr);
        [downloadTask resume];
    }];
}

- (BOOL)isLan:(NSString *)url {
    if ([url hasPrefix:@"https"]) {
        return NO;
    }
    
    return YES;
}

// 处理分片下载结果
- (void)processDownloadResult:(NSString *)requestId
                         task:(ESTransferTask *)task
                     item:(ESDownloadFragmentModel *)item
                        token:(ESTokenItem *)token
                     callback:(void (^)(NSURL *output, NSError *error))callback
                        error:(NSError *)error
                      request:(ESRealCallRequest *)request
              progress:(ESProgressHandler)progress
{
    [self.lock lock];
    self.taskDict[requestId] = nil;
    self.progressDict[requestId] = nil;
    [self.lock unlock];
    
    NSString *encryptPath = [task getDownloadRangeEncryptPath:item];
    NSString * key = [[NSString alloc] initWithFormat:@"%@_%@", task.name, item.range];

    if (error) {
        [task updateDownloadSliceState:item state:ESTransferStateFailed];
        NSDictionary * dict = error.userInfo;
        if (dict[@"code"] && [dict[@"code"] isKindOfClass:NSNumber.class] &&
            [dict[@"code"] intValue] == ESTransferErrorStateFileNotExist) {
            [task updateDownloadTaskErrorState:ESTransferErrorStateFileNotExist];
            if (callback) {
                callback(nil, error);
            }
            return;
        }
        
        if ([[ESReTransmissionManager Instance] canTrans:key max:3 increment:YES]) {
            ESDLog(@"[上传下载] %@ %@下载 - 分片 - 失败，自动重试", task.name, @"HTTP");
            [task updateDownloadSliceState:item state:ESTransferStateReady];
            [self doSliceDownloadRunLoop:request task:task item:item progress:progress callback:callback];
            return;
        }
        
        [encryptPath clearCachePath];
        if (callback) {
            callback(nil, error);
        }
                
        NSString * errorMsg = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        ESDLog(@"[上传下载] %@下载 - 分片 - 失败，%@", @"HTTP" ,errorMsg);
        
        return;
    }
    
    [[ESReTransmissionManager Instance] removeTransission:key];
    
    if (item.downloadTransferWay == ESTransferWay_HTTP_FILEAPI) {
        
    } else {
        NSData *fileData =  [NSData dataWithContentsOfFile:encryptPath];
        if(fileData == nil || fileData.length == 48){
            ESDLog(@"[上传下载] 下载的加密文件不存在或有问题 %@ - %@", task.name, item.range);
            [task updateDownloadSliceState:item state:ESTransferStateFailed];
            [task updatedTaskState];

            if (callback) {
                callback(nil, error);
            }
            return;
        }
        [ESFileHandleManager.manager decryptFile:encryptPath target:[task getDownloadRangePath:item] key:token.secretKey iv:token.secretIV];
    }
    
    [task updateDownloadSliceState:item state:ESTransferStateCompleted];
    [task updatedTaskState];
    
    NSTimeInterval distace = [[NSDate date] timeIntervalSince1970] - item.startDownloadTime;
    CGFloat speed = item.size / distace;
    [task updateDownloadSliceSpeed:item speed:speed];
    
    if ([task isCompletedDownloadTask]) {
        task.downloadEndTime = [[NSDate date] timeIntervalSince1970];
        ESDLog(@"[上传下载] 下载-合并-成功-%@  %@",@"HTTP", task.name);
        
        [task mergeDownloadData:^(NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(url, nil);
                }
            });
        }];
        
        return;
    }
    
    ESDLog(@"[上传下载] 下载-分片-成功, %@ - %@ - %@, ", task.name, @"HTTP", item.range);

    ESDownloadFragmentModel * nextItem = [task.downloadSliceModel getCanDownloadFragment];
    [task updateDownloadSliceTransferWay:nextItem way:item.downloadTransferWay];
    [self doSliceDownloadRunLoop:request task:task item:nextItem progress:progress callback:callback];
}

- (ESNetworkingTask *)uploadFile:(NSString *)filePath
                             dir:(NSString *)dir
                         request:(ESRealCallRequest *)request
                        progress:(ESProgressHandler)progress
                        callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback {
    ESNetworkingTask *networkingTask = [ESNetworkingTask new];
    [self token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeFailedToCreateToken userInfo:nil]);
            }
            return;
        }
        if (networkingTask.canceled) {
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        NSString *requestId = request.requestId;
        ESSpaceGatewayGenericCallServiceApi *api = [ESSpaceGatewayGenericCallServiceApi new];
        ESApiClient *apiClient = api.apiClient;
        ///Header
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:apiClient.configuration.defaultHeaders];
        headerParams[@"Request-Id"] = requestId;
        headerParams[@"Accept"] = @"*/*";
        [headerParams addEntriesFromDictionary:request.headers];

        ///加密文件
        NSString *encryptFilePath = [NSString cacheLocationWithDir:requestId];
        encryptFilePath = [NSString stringWithFormat:@"%@%@", encryptFilePath, filePath.lastPathComponent];
        encryptFilePath = encryptFilePath.fullCachePath;
        UInt64 cipherTextLength = [ESFileHandleManager.manager encryptFile:filePath target:encryptFilePath key:token.secretKey iv:token.secretIV];
        if (cipherTextLength <= 0) {
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeFailedToEncryptData userInfo:nil]);
            }
            return;
        }

        ESUploadEntity *uploadEntity = [ESUploadEntity entityFromFilePath:filePath dir:dir];

        ///RealCallRequest
        request.headers = headerParams;
        request.entity = [uploadEntity yy_modelToJSONObject];

        ///CallRequest
        ESCallRequest *callRequest = [ESCallRequest new];
        callRequest.accessToken = token.accessToken;
        if (request) {
            //加密body
            NSString * jsonStr = request.json;
            ESDLog(@"upload input :\n%@", jsonStr);
            NSString *body = [jsonStr aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
            callRequest.body = body;
        }

        NSString *url = [NSURL URLWithString:@"/space/v1/api/gateway/upload" relativeToURL:apiClient.baseURL].absoluteString;

        NSURLSessionDataTask *uploadTask;

        void (^completionHandler)(NSURLResponse *response, id responseObject, NSError *error) = ^(NSURLResponse *response, id responseObject, NSError *error) {
            [self.lock lock];
            self.taskDict[requestId] = nil;
            self.progressDict[requestId] = nil;
            [self.lock unlock];
            //移除加密后的文件
            [encryptFilePath clearCachePath];
            NSString *json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [json toJson];
            if ([dict[@"code"] integerValue] == ESApiCodeOk) {
                NSString *body = [dict[@"body"] aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
                ESDLog(@"upload output body :\n%@", body);
                NSDictionary *bodyDict = [body toJson];
                NSError *serializationError;
                ESRspUploadRspBody *response = [[ESRspUploadRspBody alloc] initWithDictionary:bodyDict error:&serializationError];
                if (!response && !error) {
                    error = serializationError;
                }
                if (response.code.integerValue == ESApiCodeOk) {
                    ESDLog(@"upload result :\n%@", response.results);
                    if (callback) {
                        callback(response, error);
                    }
                    return;
                } else {
                    ESDLog(@"upload output :\n%@", json);
                }
                if (callback) {
                    callback(nil, error);
                }
            }
        };

        uploadTask = [ESCommunication.shared
                   uploadFile:encryptFilePath
                    serverUrl:url
                       entity:uploadEntity
                  realRequest:request
                  callRequest:callRequest
               sessionManager:ESCommunication.shared.getSessionWWanManager
            completionHandler:completionHandler];
        if (networkingTask.canceled) {
            [uploadTask cancel];
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeCanceled userInfo:nil]);
            }
            return;
        }
        [self.lock lock];
        self.taskDict[requestId] = uploadTask;
        self.progressDict[requestId] = progress;
        [self.lock unlock];
        networkingTask.task = uploadTask;
        [uploadTask resume];
    }];
    
    
    return networkingTask;
}

#pragma mark - Public

- (void)getOcIdInBackgroundSession:(void (^)(NSArray<NSString *> *listOcId))completionHandler {
    NSMutableArray *listOcId = NSMutableArray.array;
    [self.sessionManagerBackground getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
        for (NSURLSessionTask *task in tasks) {
            [listOcId addObject:task.description];
        }
        [self.sessionManagerBackgroundWWan getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
            for (NSURLSessionTask *task in tasks) {
                [listOcId addObject:task.description];
            }
        }];
        if (completionHandler) {
            completionHandler(listOcId);
        }
    }];
}

- (void)getOcIdInDefaultSession:(void (^)(NSArray<NSString *> *listOcId))completionHandler {
    NSMutableArray *listOcId = NSMutableArray.array;
    NSMutableArray *listArray = NSMutableArray.array;
    NSMutableArray *listArrayWanManager = NSMutableArray.array;
    [ESCommunication.shared.getSessionManager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
        if(tasks.count > 0){
            for (NSURLSessionTask *task in tasks) {
                [listOcId addObject:task.description];
            }
            [ESCommunication.shared.getSessionWWanManager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
                for (NSURLSessionTask *task in tasks) {
                    [listArray addObject:task.description];
                }
            }];
        }
        if (listOcId.count > 0) {
            for (int i = 0; i < listOcId.count; i++) {
                [listArrayWanManager addObject:listOcId[i]];
            }
        }
        if(listArray.count >0){
            for (int i = 0; i < listArray.count; i++) {
                [listArrayWanManager addObject:listArray[i]];
            }
        }
        if (completionHandler) {
            completionHandler(listArrayWanManager);
        }
    }];
}

- (void)getAllTasksInBackgroundSession:(void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionHandler {
    NSMutableArray *listOcId = NSMutableArray.array;
    [self.sessionManagerBackground getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
        for (NSURLSessionTask *task in tasks) {
            [listOcId addObject:task];
        }
        [self.sessionManagerBackgroundWWan getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
            for (NSURLSessionTask *task in tasks) {
                [listOcId addObject:task];
            }
        }];
        if (completionHandler) {
            completionHandler(listOcId);
        }
    }];
}

- (void)getAllTasksInDefaultSession:(void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionHandler {
    NSMutableArray *listOcId = NSMutableArray.array;
    [ESCommunication.shared.getSessionManager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
        for (NSURLSessionTask *task in tasks) {
            [listOcId addObject:task];
        }
        [ESCommunication.shared.getSessionWWanManager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> *_Nonnull tasks) {
            for (NSURLSessionTask *task in tasks) {
                [listOcId addObject:task];
            }
        }];
        if (completionHandler) {
            completionHandler(listOcId);
        }
    }];
}

- (void)cancelAllTransfer:(void (^)(void))completion {
    [ESUploadMetadata deleteMetadata:@[@(ESUploadMetadataStatusWaitUpload), @(ESUploadMetadataStatusUploadError)] type:kESUploadMetadataTypeAutoUpload];
    NSArray<ESUploadMetadata *> *metadatas = [ESUploadMetadata autoUploadMetadata:nil limit:-1];
    NSInteger counter = 0;
    for (ESUploadMetadata *metadata in metadatas) {
        counter += 1;
        if (metadata.status == ESUploadMetadataStatusUploading) {
            [self cancelTransferMetadata:metadata
                              completion:^{
                                  if (counter == metadatas.count) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          if (completion) {
                                              completion();
                                          }
                                      });
                                  }
                              }];
        }
    }
}

- (void)cancelTransferMetadata:(ESUploadMetadata *)metadata completion:(void (^)(void))completion {
    [self.lock lock];
    NSURLSessionTask *task = self.taskDict[metadata.requestId];
    [self.lock unlock];
    [task cancel];
    [metadata remove];
    if (completion) {
        completion();
    }
}

#pragma mark - NetworkReachability

- (void)monitorNetworkReachability {
    _reachabilityManager = [AFNetworkReachabilityManager manager];
    weakfy(self);
    [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        strongfy(self);
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.yc_asNotifier notifyListener:@(status)];
        }
    }];
    [_reachabilityManager startMonitoring];
}

#pragma mark - Lazy Load

- (NSURLSession *)sessionManagerBackground {
    if (!_sessionManagerBackground) {
        NSString *identifier = [NSString stringWithFormat:@"%@.upload.background.wwan", NSBundle.mainBundle.bundleIdentifier];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        configuration.allowsCellularAccess = YES;
        configuration.sessionSendsLaunchEvents = YES;
        configuration.discretionary = NO;
        configuration.HTTPMaximumConnectionsPerHost = kNetworkingSessionMaximumConnectionsPerHost;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.waitsForConnectivity = YES;
        _sessionManagerBackground = [NSURLSession sessionWithConfiguration:configuration
                                                                  delegate:ESCommunicationBackground.shared
                                                             delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _sessionManagerBackground;
}

- (NSURLSession *)sessionManagerBackgroundWWan {
    if (!_sessionManagerBackgroundWWan) {
        NSString *identifier = [NSString stringWithFormat:@"%@.upload.background", NSBundle.mainBundle.bundleIdentifier];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        configuration.allowsCellularAccess = YES;
        configuration.sessionSendsLaunchEvents = YES;
        configuration.discretionary = NO;
        configuration.HTTPMaximumConnectionsPerHost = kNetworkingSessionMaximumConnectionsPerHost;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.waitsForConnectivity = YES;
        _sessionManagerBackgroundWWan = [NSURLSession sessionWithConfiguration:configuration
                                                                      delegate:ESCommunicationBackground.shared
                                                                 delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _sessionManagerBackgroundWWan;
}

- (dispatch_queue_t)decryptQueue {
    if (!_decryptQueue) {
        NSString *queueName = [NSString stringWithFormat:@"%@.decrypt.queue", NSBundle.mainBundle.bundleIdentifier];
        _decryptQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    return _decryptQueue;
}

- (dispatch_queue_t)taskQueue {
    if (!_taskQueue) {
        NSString *queueName = [NSString stringWithFormat:@"%@.task.queue", NSBundle.mainBundle.bundleIdentifier];
        _taskQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    return _taskQueue;
}

//delegate
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
                      completionHandler:(void (^)(void))completionHandler {
    self.completionHandler = completionHandler;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession {
    if (self.completionHandler) {
        self.completionHandler();
    }
    ESDLog(@"Called urlSessionDidFinishEvents for Background URLSession");
    self.completionHandler = nil;
}

-(void)saveCompleVideoMetadata:(ESUploadMetadata *)metadata{
    if (metadata.photoID) {
        NSDictionary *uploadPhotoDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadPhotoIDDic"];
        NSString *str = [NSString stringWithFormat:@"%@",metadata.photoNum];
        NSArray *uploadPhotoIDArray =uploadPhotoDic[str];
        NSMutableArray *uploadPhotoIDmutableArray;
        if(uploadPhotoIDArray.count > 0){
            uploadPhotoIDmutableArray = [[NSMutableArray alloc]initWithArray:uploadPhotoIDArray];
            [uploadPhotoIDmutableArray addObject:metadata.photoID];
        }else{
            uploadPhotoIDmutableArray = [[NSMutableArray alloc] init];
            [uploadPhotoIDmutableArray addObject:metadata.photoID];
        }
        NSMutableDictionary *miuDic = [[NSMutableDictionary alloc] init];

        NSArray *array = [[NSArray alloc]initWithArray:uploadPhotoIDmutableArray];
        [miuDic setValue:array forKey:str];
        NSDictionary *dic =[miuDic mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"uploadPhotoIDDic"];
    }
    
    NSArray *uploadingArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadUploadingArray"];
    
    if(uploadingArray.count > 0){
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:uploadingArray];
        [mutableArray removeObject:metadata.photoID];
        NSArray *array = mutableArray;
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"uploadUploadingArray"];
    }
}



// 分片上传
- (void)uploadBySlice:(ESTransferTask *)task
                                 dir:(NSString *)dir
                            progress:(ESProgressHandler)progress
                           callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback {
    ESUploadMetadata * metadata = task.metadata;
    if (metadata.size == 0) {
        ///文件没有写入沙盒
        [task updateUploadMetadataStatue:ESUploadMetadataStatusUploadError];
        [metadata remove];
        [task updateUploadTaskErrorState:ESTransferErrorStateUploadFailedMissing];
        if (callback) {
            callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeFailedToReadAssetData userInfo:nil]);
        }
        return;
    }
    
    task.createMultiPartReqTime = [[NSDate date] timeIntervalSince1970];
    [self.multipart create:metadata completionBlock:^(ESRspCreateMultipartTaskRsp *output, NSError *error) {
        task.createMultiPartRespTime = [[NSDate date] timeIntervalSince1970];
        if (error) {
            if (callback) {
                callback(nil, error);
            }
            return;
        }
        
        if (output.code.integerValue != ESApiCodeOk) {
            ESRspUploadRspBody * uploadRspBody = [ESRspUploadRspBody new];
            uploadRspBody.code = output.code;
            ESDLog(@"[上传下载] 创建分片任务失败:code:%@, msg:%@", output.code, output.message);
            if (callback) {
                NSError * error = [NSError errorWithDomain:output.message ?: @"创建分片任务失败" code:output.code.integerValue userInfo:nil];
                callback(uploadRspBody, error);
            }
            return;
        }
        // rspType: 0：创建任务成功； 1：秒传完成； 2：冲突，任务已存在
        if (output && output.results.rspType.intValue == 1) {
            // 盒子里已经有此betag的数据了
            ESRspUploadRspBody * uploadRspBody = [ESRspUploadRspBody new];
            uploadRspBody.code = @(200);
            uploadRspBody.results = [ESMultipartNetworking transferUploadResult:output.results.completeInfo];
            callback(uploadRspBody, nil);
            [self saveCompleVideoMetadata:metadata];
            return;
        }
        
        if (output && output.results && output.results.rspType.intValue == 2 && output.results.conflictInfo && output.results.conflictInfo.uploadedParts && output.results.conflictInfo.uploadingParts.count == 0) {
            // 处理数据上传完毕，但最后合并失败或者还未合并时的场景，可以通过用户再上传，避免文件一直无法上传成功
            ESPart * uploadedPart = [output.results.conflictInfo.uploadedParts firstObject];
            if (output.results.conflictInfo.uploadedParts.count == 1 && uploadedPart.start.integerValue == 0 && uploadedPart.end == output.results.conflictInfo.size) {
                NSString * uploadId = output.results.conflictInfo.uploadId;
                [self mergeSlice:uploadId task:task callback:callback];
                return;
            }
        }
        
        NSString * uploadId = output.results.succInfo.uploadId;
        if(output.results.conflictInfo.uploadId){
            uploadId = output.results.conflictInfo.uploadId;
        }
        [task updateUploadUploadId:uploadId];
        for (int i = 0; i < ESMaxSliceUploadNum; i++) {
            FileFragment * item = [task.sliceModel getCanTransferFragment];
            [task updateUploadSliceTransferWay:item way:ESTransferWay_HTTP];
            [self doSliceUploadRunLoop:task dir:dir uploadId:uploadId progress:progress item:item callback:^(ESRspUploadRspBody *result, NSError *error) {
                 callback(result, error);
//                [self saveCompleVideoMetadata:metadata];
            }];
        }
    }];
}

- (void)doSliceUploadRunLoop:(ESTransferTask *)task
                         dir:(NSString *)dir
                    uploadId:(NSString *)uploadId
                    progress:(ESProgressHandler)progress
                        item:(FileFragment *)ment
                    callback:(void (^)(ESRspUploadRspBody *result, NSError *error))callback
{
    if (task.state == ESTransferStateSuspended || ment == nil || ment.fragmentState == ESTransferStateRunning) {
        return;
    }
    [task updateUploadSliceState:ment state:ESTransferStateRunning];

    [self token:^(ESTokenItem *token, NSError *error){
        ESUploadMetadata * metadata = task.metadata;
        
        ESRealCallRequest *request = [ESRealCallRequest new];
        request.apiName = @"multipart_upload";
        request.serviceName = @"eulixspace-file-service";
        if (dir) {
            request.queries = @{@"uuid": dir};
        }

        if (!token) {
            // [filePath clearCachePath];
            [task updateUploadMetadataStatue:ESUploadMetadataStatusUploadError];

            [metadata save];
            if (callback) {
                callback(nil, [NSError errorWithDomain:ESNetworkingErrorDomain code:ESNetworkingErrorCodeFailedToCreateToken userInfo:nil]);
            }
//            [NSNotificationCenter.defaultCenter postNotificationName:kESGlobalUploadAutoUploadReady object:metadata];
        }
        NSString *requestId = request.requestId;

        ESSpaceGatewayGenericCallServiceApi *api = [ESSpaceGatewayGenericCallServiceApi new];
        ESApiClient *apiClient = api.apiClient;
        ///Header
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:apiClient.configuration.defaultHeaders];
        headerParams[@"Request-Id"] = requestId;
        headerParams[@"Accept"] = @"*/*";
        [headerParams addEntriesFromDictionary:request.headers];
        
        NSMutableDictionary *queriesParams = [NSMutableDictionary new];
        queriesParams[@"requestId"] = requestId;
        NSNumber *start = [NSNumber numberWithInteger:ment.fragementOffset];
        queriesParams[@"start"] = start;
        NSNumber *fragementOffsetNumber = [NSNumber numberWithInteger:ment.fragementOffsetEnd];
        queriesParams[@"end"] = fragementOffsetNumber;
        queriesParams[@"uploadId"] = uploadId;
        queriesParams[@"md5sum"] = ment.md5sum;
        
        ment.startUploadTime = [[NSDate date] timeIntervalSince1970];

        BOOL isLanNet = [ESLocalNetworking isLANReachable];
        if (!task.isCertificateFailed && isLanNet && [ESLanTransferManager.shared hasCertData]) {
            queriesParams[@"userId"] = [[ESBoxManager manager] getAoidValue];
            NSString * start = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)ment.fragementOffset];
            queriesParams[@"start"] = start;
            NSString * end = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)ment.fragementOffsetEnd];
            queriesParams[@"end"] = end;
            
            NSString * filePath = [task getFragmentFilePath:ment];
            [task updateUploadSliceTransferWay:ment way:ESTransferWay_HTTP_FILEAPI];

            
//            Token 的生成算法： {aoid}-{hex(md5({aoid}-bp-{secret}))的前20个字符}
            NSString * hex = [[[NSString alloc] initWithFormat:@"%@-bp-%@", ESBoxManager.activeBox.aoid, token.secretKey].md5 substringToIndex:20];
            NSString * tokenKey = [[NSString alloc] initWithFormat:@"%@-%@", ESBoxManager.activeBox.aoid, hex];
            NSURLSessionDataTask *uploadTask = [ESLanTransferManager.shared uploadFile:filePath
                                                                                  host:apiClient.baseURL.host
                                                                                 query:queriesParams
                                                                                 token:tokenKey
                                                                              progress:progress
                                                                     completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    task.isCertificateFailed = YES;
                }
                [self processSliceUploadResult:requestId sliceName:ment.path.lastPathComponent task:task token:token dir:dir uploadId:uploadId progress:progress ment:ment data:responseObject callback:callback error:error];
            }];
            
            [self.lock lock];
            self.taskDict[requestId] = uploadTask;
            self.progressDict[requestId] = progress;
            [[ESReTransmissionManager Instance] addTransmission:ment.path.lastPathComponent];

            [self.lock unlock];
            
            ESDLog(@"[上传下载] 分片上传开始 - fileApi：%@, index:%lu, range:%@ - %@", metadata.fileName, ment.index, start, end);
            [uploadTask resume];
            
            return;
        }

        request.queries = queriesParams;
        
        
        
        NSString * encryptFilePath = [task encryptFragmentFile:ment token:token];
        if (encryptFilePath == nil) {
            [task updateUploadSliceState:ment state:ESTransferStateCompleted];
            [task updateUploadMetadataStatue:ESUploadMetadataStatusUploadError];

            [task.metadata save];
//            [NSNotificationCenter.defaultCenter postNotificationName:kESGlobalUploadAutoUploadReady object:self.metadata];
            
            FileFragment * nextItem = [task.sliceModel getCanTransferFragment];
            [task updateUploadSliceTransferWay:nextItem way:ment.transferWay];
            [self doSliceUploadRunLoop:task dir:dir uploadId:uploadId progress:progress item:nextItem callback:^(ESRspUploadRspBody *result, NSError *error) {
                callback(result, error);
            }];
            return;
        }
        
        ESUploadEntity *uploadEntity = [ESUploadEntity entityFromFilePath:ment.path dir:dir];
        uploadEntity.businessId = task.metadata.businessId;
        if (task.metadata.albumId.length > 0) {
            uploadEntity.albumId = [task.metadata.albumId integerValue];
        }
        
        ///RealCallRequest
        request.headers = headerParams;
        request.entity = [uploadEntity yy_modelToJSONObject];
        
        ///CallRequest
        ESCallRequest *callRequest = [ESCallRequest new];
        callRequest.accessToken = token.accessToken;
        if (request) {
            NSString * jsonStr = request.json;
            ESDLog(@"[上传下载] upload input :%@", jsonStr);
            callRequest.body = [jsonStr aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        }
        NSString * baseUrl = apiClient.baseURL.absoluteString;
        NSString *url = [NSURL URLWithString:@"/space/v1/api/gateway/upload" relativeToURL:apiClient.baseURL].absoluteString;
        
        AFHTTPSessionManager *session = nil;
        if ([metadata.taskType isEqualToString:kESUploadMetadataTypeAutoUpload]) {
            ESAccount *account = ESAccountManager.manager.currentAccount;
            if (account.autoUploadWWAN) {
                session = ESCommunication.shared.getSessionWWanManager;
            } else {
                session = ESCommunication.shared.getSessionManager;
            }
        } else if ([self isLan:baseUrl]) {
            session = ESCommunication.shared.getSessionWWanManager4Lan;
        } else {
            session = ESCommunication.shared.getSessionWWanManager;
        }
        
        ESCommunication *communication = [ESCommunication new];
        NSURLSessionDataTask *uploadTask = [communication uploadFile:encryptFilePath
                                                           serverUrl:url
                                                              entity:uploadEntity
                                                         realRequest:request
                                                         callRequest:callRequest
                                                      sessionManager:session
                                                   completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                ESDLog(@"[上传下载] 分片上传失败-HTTP, %@, index:%lu, message:%@", metadata.fileName, ment.index, [error errorDescription]);
            }
            [task updateUploadSliceTransferWay:ment way:ESTransferWay_HTTP];
            [self processSliceUploadResult:requestId sliceName:uploadEntity.filename task:task token:token dir:dir uploadId:uploadId progress:progress ment:ment data:responseObject callback:callback error:error];
        }];
        
        metadata.sessionTaskIdentifier = uploadTask.taskIdentifier;
        metadata.ocId = uploadTask.description;
        metadata.requestId = requestId;
        [task updateUploadMetadataStatue:ESUploadMetadataStatusUploading];
        [metadata save];
        ESDLog(@"PROCESS-UPLOAD %@ - %@", metadata.originalFilename, metadata.ocId);
        [self.lock lock];
        self.taskDict[requestId] = uploadTask;
        self.progressDict[requestId] = progress;
        [self.lock unlock];
        [[ESReTransmissionManager Instance] addTransmission:uploadEntity.filename];
        ESDLog(@"[上传下载] 分片上传开始-http：%@, index:%lu, range:%ld-%ld", metadata.fileName, ment.index, ment.fragementOffset, ment.fragementOffsetEnd);
        [uploadTask resume];
    }];
}

//处理分片上传接口 /space/v1/api/gateway/upload 的返回结果
- (void)processSliceUploadResult:(NSString *)requestId
                  sliceName:(NSString *)sliceName
                   task:(ESTransferTask *)task
                      token:(ESTokenItem *)token
                        dir:(NSString *)dir
                     uploadId:(NSString *)uploadId
                   progress:(ESProgressHandler)progress
                       ment:(FileFragment *)ment
                       data:(NSData *)data
                        callback:(void (^)(ESRspUploadRspBody *result, NSError * _Nullable error))callback
                           error:(NSError *)error
{
    ESUploadMetadata * metadata = task.metadata;
    if (error) {
        if ([[ESReTransmissionManager Instance] canTrans:sliceName max:3 increment:YES]) {
            ESDLog(@"[上传下载] 分片上传重试, %@, index:%lu", metadata.fileName, ment.index);
            [task updateUploadSliceState:ment state:ESTransferStateReady];

            [self doSliceUploadRunLoop:task dir:dir uploadId:uploadId progress:progress  item:ment callback:callback];
            return;
        }
        [task updateUploadSliceState:ment state:ESTransferStateFailed];
    }
    
    [self.lock lock];
    self.taskDict[requestId] = nil;
    [self.lock unlock];
   
    [task delEncryptFragmentFile:ment];
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ESDLog(@"[上传下载] 分片上传返回的内容 %@, result:%@", metadata.fileName, json);
    NSDictionary *dict = [json toJson];
    
    BOOL isSuccess = NO;
    NSUInteger resultCode = [dict[@"code"] justErrorCode];
    if (ment.transferWay == ESTransferWay_HTTP_FILEAPI) {
        if (resultCode == ESApiCodeOk || resultCode == ESApiCodeFileRangeUploaded) {
            isSuccess = YES;
        }
    } else {
        NSString *body = [dict[@"body"] aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
        
        ESDLog(@"[上传下载] upload %@, output body :%@", metadata.fileName, body);
        NSDictionary *bodyDict = [body toJson];
        NSError *serializationError;
        ESRspUploadRspBody *response = [[ESRspUploadRspBody alloc] initWithDictionary:bodyDict error:&serializationError];
        if (serializationError && callback) {
            callback(nil, serializationError);
            [task updateUploadSliceState:ment state:ESTransferStateFailed];
            return;
        }
        
        resultCode = response.code.integerValue;
        isSuccess = ([dict[@"code"] justErrorCode] == ESApiCodeOk
                     && (resultCode == ESApiCodeOk || resultCode == ESApiCodeFileRangeUploaded));
    }
    
    if (isSuccess) {
        [[ESReTransmissionManager Instance] removeTransission:sliceName];

        ESDLog(@"[上传下载] 上传-分片,%@ 成功 index:%lu, %@", @"HTTP", (unsigned long)ment.index, metadata.fileName);
        NSTimeInterval distace = [[NSDate date] timeIntervalSince1970] - ment.startUploadTime;
        CGFloat speed = ment.fragmentSize / distace;
        
        
        [task updateUploadSliceState:ment state:ESTransferStateCompleted];
        [task updateUploadSliceSpeed:ment speed:speed];
        [task updatedTaskState];
        [task delFragmentFile:ment];
        
        if ([task.sliceModel completedSliceNum] == task.sliceModel.dataArray.count) {
            [self mergeSlice:uploadId task:task callback:callback];
            return;
        }
        
        FileFragment * nextItem = [task.sliceModel getCanTransferFragment];
        [task updateUploadSliceTransferWay:nextItem way:ment.transferWay];
        [self doSliceUploadRunLoop:task dir:dir uploadId:uploadId progress:progress item:nextItem callback:^(ESRspUploadRspBody *result, NSError *error) {
            callback(result, error);
        }];
    } else if ([[ESReTransmissionManager Instance] canTrans:sliceName max:3 increment:YES]) {
        ESDLog(@"[上传下载] 上传-分片-重试, %@, index:%lu, code:%lu", metadata.fileName, ment.index, (unsigned long)resultCode);
        [task updateUploadSliceState:ment state:ESTransferStateReady];
        [self doSliceUploadRunLoop:task dir:dir uploadId:uploadId progress:progress item:ment callback:callback];
    } else {
        ESDLog(@"[上传下载] 上传-分片-失败，%@, index:%lu, %@, code:%@, response.code:%ld",
               metadata.fileName, ment.index, @"HTTP", dict[@"code"], resultCode);
        if (callback) {
            NSError * tErr = [NSError errorWithDomain:@"分片上传失败" code:-1 userInfo:nil];
            callback(nil, tErr);
        }
        [task updateUploadSliceState:ment state:ESTransferStateFailed];
    }
}

@end

