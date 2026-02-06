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
//  ESNetworkRequestManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestManager.h"
#import <pthread.h>
#import "ESNetworkCallRequestServiceTask.h"
#import "ESNetworkServiceUploadTask.h"
#import "ESNetworkRequestDownloadTask.h"

NSInteger const ESRequestID_InVailed = -1;

static NSInteger const TVSPBRequestDefaultRetryCount = 3;
static NSString * const TVSPBRequestDefaultRetryCountKey = @"pb_retry_count";

static NSString *ESNetworkRequestApiDesc(NSDictionary *apiParams) {
    if (![apiParams isKindOfClass:[NSDictionary class]]) {
        return @"unknown";
    }
    NSString *serviceName = apiParams[ESNetworkServiceNameKey];
    NSString *apiName = apiParams[ESNetworkApiNameKey];
    if (serviceName.length == 0 && apiName.length == 0) {
        return @"unknown";
    }
    return [NSString stringWithFormat:@"%@/%@",
            serviceName.length > 0 ? serviceName : @"-",
            apiName.length > 0 ? apiName : @"-"];
}

static NSString *ESNetworkRequestKeysDesc(NSDictionary *dict) {
    if (![dict isKindOfClass:[NSDictionary class]] || dict.count == 0) {
        return @"[]";
    }
    NSArray *keys = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[obj1 description] compare:[obj2 description]];
    }];
    return [NSString stringWithFormat:@"%@", keys];
}

@interface ESNetworkRequestManager() <NSURLSessionDelegate>

@property (nonatomic, strong)NSMutableArray<ESNetworkRequestServiceTask *> *requestList;
@property (nonatomic, strong)dispatch_queue_t requestQueue;
@property (nonatomic, strong)NSMutableDictionary *pbRetryInfo;
@property (nonatomic, assign)pthread_rwlock_t lock;

@property (nonatomic, strong) NSURLSession *shareSession;
@property (nonatomic, assign) NSInteger downloadThreadLimit;

@property (nonatomic, strong)dispatch_queue_t downloadQueue;
@property (nonatomic, strong)dispatch_semaphore_t downloadSemaphoreLock;

+ (instancetype)sharedInstance;

- (void)appendRequest:(ESNetworkRequestServiceTask *)request;
- (void)removeRequest:(ESNetworkRequestServiceTask *)request;

@end

@implementation ESNetworkRequestManager

+ (instancetype)sharedInstance {
    static ESNetworkRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.requestQueue = dispatch_queue_create("ES_Network_Request_Queue", DISPATCH_QUEUE_SERIAL);
        self.requestList = [NSMutableArray array];
        self.pbRetryInfo = [NSMutableDictionary dictionary];
        pthread_rwlock_init(&_lock, NULL);
        
        self.downloadQueue = dispatch_queue_create("ES_Download_Queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)appendRequest:(ESNetworkRequestServiceTask *)request {
    dispatch_async(self.requestQueue, ^{
        if (request) {
            [self.requestList addObject:request];
        }
    });
}

- (void)removeRequest:(ESNetworkRequestServiceTask *)request {
    dispatch_async(self.requestQueue, ^{
        if (request) {
            [self.requestList removeObject:request];
        }
    });
}

- (NSURLSession *)shareSession {
    if (!_shareSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _shareSession = [NSURLSession sessionWithConfiguration:config];
    }
    return _shareSession;
}

+ (NSURLSession *)shareSession {
    return ESNetworkRequestManager.sharedInstance.shareSession;
}

+ (void)setDownloadThreadMaxCount:(NSInteger)threadMaxCount {
    [ESNetworkRequestManager sharedInstance].downloadSemaphoreLock = dispatch_semaphore_create(threadMaxCount);
}

#pragma mark -

+ (NSInteger)sendRequest:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkRequestServiceTask *requestTask = [ESNetworkRequestServiceTask new];
    requestTask.modelName = modelName;
    requestTask.successBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendRequest:path
                      method:method
                 queryParams:queryParams
                      header:headerParams
                        body:bodyParams];
    ESDLog(@"[Network] enqueue raw request id:%ld method:%@ path:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           method,
           path,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    return requestTask.requestId;
}

+ (NSInteger)sendRequest:(NSString *)baseUrl
                    path:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkRequestServiceTask *requestTask = [ESNetworkRequestServiceTask new];
    requestTask.modelName = modelName;
    requestTask.successBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendRequest:baseUrl
                        path:path
                      method:method
                 queryParams:queryParams
                      header:headerParams
                        body:bodyParams];
    ESDLog(@"[Network] enqueue raw request id:%ld method:%@ base:%@ path:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           method,
           baseUrl,
           path,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    return requestTask.requestId;
}

+ (NSInteger)sendCallRequestWithServiceName:(NSString *)serviceName
                                  apiName:(NSString *)apiName
                            queryParams:(NSDictionary * _Nullable)queryParams
                               header:(NSDictionary * _Nullable)headerParams
                                   body:(NSDictionary * _Nullable)bodyParams
                              modelName:(NSString * _Nullable)modelName
                                successBlock:(ESRequestServiceSuccessBlock)successBlock
                                  failBlock:(ESRequestServiceFailBlock)failBlock {
    return [self sendCallRequest:@{ ESNetworkServiceNameKey : ESSafeString(serviceName),
                                    ESNetworkApiNameKey     : ESSafeString(apiName)
                                  }
              queryParams:queryParams
                   header:headerParams
                     body:bodyParams
                modelName:modelName
             successBlock:successBlock
                failBlock:failBlock];
}

+ (NSInteger)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkCallRequestServiceTask *requestTask = [ESNetworkCallRequestServiceTask new];
    requestTask.modelName = modelName;
    requestTask.successBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendCallRequest:apiParams
                     queryParams:queryParams
                          header:headerParams
                            body:bodyParams];
    ESDLog(@"[Network] enqueue call request id:%ld api:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           ESNetworkRequestApiDesc(apiParams),
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    return requestTask.requestId;
}

+ (NSInteger)sendCallUploadRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
               filePath:(NSString *)filePath
                successBlock:(ESRequestServiceSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkServiceUploadTask *requestTask = [ESNetworkServiceUploadTask new];
//    requestTask.modelName = modelName;
    requestTask.successBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendCallRequest:apiParams
                     queryParams:queryParams
                          header:headerParams
                            body:bodyParams
                        filePath:filePath];
    ESDLog(@"[Network] enqueue upload(file) id:%ld api:%@ file:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           ESNetworkRequestApiDesc(apiParams),
           filePath.lastPathComponent,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    return requestTask.requestId;
}

+ (NSInteger)sendCallUploadRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
                        data:(NSData *)data
                successBlock:(ESRequestServiceSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkServiceUploadTask *requestTask = [ESNetworkServiceUploadTask new];
//    requestTask.modelName = modelName;
    requestTask.successBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendCallRequest:apiParams
                     queryParams:queryParams
                          header:headerParams
                            body:bodyParams
                        data:data];
    ESDLog(@"[Network] enqueue upload(data) id:%ld api:%@ dataLength:%lu queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           ESNetworkRequestApiDesc(apiParams),
           (unsigned long)data.length,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    return requestTask.requestId;
}

+ (NSInteger)downloadRequestWithQueryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
                      method:(NSString *)method
                successBlock:(ESRequestServiceDownloadSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkRequestDownloadTask *requestTask = [ESNetworkRequestDownloadTask new];
    requestTask.downloadSuccessBlock = successBlock;
    requestTask.failBlock = failBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendDownloadRequestWithQueryParams:queryParams
                              header:headerParams
                                body:bodyParams
                              method:method];
    ESDLog(@"[Network] enqueue download id:%ld method:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           method,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    
    return requestTask.requestId;
}

+ (NSInteger)sendCallDownloadRequest:(NSDictionary *)apiParams
             queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
             targetPath:(NSString *)targetPath
                status:(ESRequestServiceStatusBlock)statusBlock
                successBlock:(ESRequestServiceDownloadSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock {
    ESNetworkRequestCallDownloadTask *requestTask = [ESNetworkRequestCallDownloadTask new];
    requestTask.downloadSuccessBlock = successBlock;
    requestTask.failBlock = failBlock;
    requestTask.statusUpdateBlock = statusBlock;
    
    [[ESNetworkRequestManager sharedInstance] appendRequest:requestTask];
    [requestTask sendCallDownloadRequest:apiParams
                             queryParams:queryParams
                              header:headerParams
                                body:bodyParams
                              targetPath:targetPath
    ];
    ESDLog(@"[Network] enqueue call download id:%ld api:%@ target:%@ queryKeys:%@ bodyKeys:%@",
           (long)requestTask.requestId,
           ESNetworkRequestApiDesc(apiParams),
           targetPath.lastPathComponent,
           ESNetworkRequestKeysDesc(queryParams),
           ESNetworkRequestKeysDesc(bodyParams));
    
    return requestTask.requestId;
}

+ (void)cancelRequestById:(NSInteger)requestId {
    dispatch_async([ESNetworkRequestManager sharedInstance].requestQueue, ^{
        ESNetworkRequestServiceTask *task = [self getRequestTaskById:requestId];
        if (task) {
            [task cancel];
            [[ESNetworkRequestManager sharedInstance] removeRequest:task];
            ESDLog(@"[Network] cancel request id:%ld", (long)requestId);
        }
    });
}

+ (ESNetworkRequestServiceStatus)requestTaskStatusWithId:(NSInteger)requestId {
    ESNetworkRequestServiceTask *task = [self getRequestTaskById:requestId];
    if (!task) {
        return ESNetworkRequestServiceStatus_Unknow;
    }
    return task.status;
}

+ (ESNetworkRequestServiceTask *)getRequestTaskById:(NSInteger)requestId {
    if (requestId == ESRequestID_InVailed) {
        return nil;
    }

    ESNetworkRequestServiceTask *requestTask = nil;
    NSArray *taskList = [ESNetworkRequestManager sharedInstance].requestList;
    for (ESNetworkRequestServiceTask *task in taskList) {
        if (task.requestId == requestId) {
            requestTask = task;
            break;
        }
    }
    return requestTask;
}


@end
