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
//  ESNetworkRequestDownloadTask.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestDownloadTask.h"
#import "ESBoxManager.h"
#import "ESNetworkRequestManager.h"
#import "ESGatewayManager.h"
#import "ESAES.h"
#import "ESNetworkCallRequestServiceTask.h"
#import "ESFileHandleManager.h"
#import "AFURLSessionManager.h"
#import "ESDiskCacheManager.h"
#import "ESLocalNetworking.h"

@interface ESNetworkRequestManager ()

@property (nonatomic, strong)dispatch_queue_t downloadQueue;
@property (nonatomic, strong)dispatch_semaphore_t downloadSemaphoreLock;

+ (instancetype)sharedInstance;
+ (NSURLSession *)shareSession;

- (void)appendRequest:(ESNetworkRequestServiceTask *)request;
- (void)removeRequest:(ESNetworkRequestServiceTask *)request;

@end

@interface ESNetworkRequestServiceTask ()

- (void)setQueryParams:(NSDictionary *)queryParams withUrlComponents:(NSURLComponents *)components;

- (void)addHeaderParams:(NSDictionary *)headerParams withRequest:(NSMutableURLRequest *)mRequest;

- (void)addCommonHeaderParams:(NSDictionary *)headerParams  withRequest:(NSMutableURLRequest *)mRequest;

- (void)addBodyParams:(NSDictionary *)bodyParams withRequest:(NSMutableURLRequest *)mRequest;

@end


@implementation ESNetworkRequestDownloadTask

- (void)sendDownloadRequestWithQueryParams:(NSDictionary *)queryParams
                                    header:(NSDictionary *)headerParams
                                      body:(NSDictionary *)bodyParams
                                    method:(NSString *)method {
    NSString *userDomain = ESBoxManager.activeBox.info.userDomain;
    NSString *url = [NSString stringWithFormat:@"http://%@/space/v1/api/gateway/download",userDomain];

    if (ESBoxManager.activeBox != nil &&
        ESBoxManager.activeBox.localHost.length > 0 &&
        ESBoxManager.activeBox.enableInternetAccess == NO) {
        userDomain = ESBoxManager.activeBox.localHost;
        url = [NSString stringWithFormat:@"%@/space/v1/api/gateway/download",userDomain];
    }
    
    NSString * lanHost = [[ESLocalNetworking shared] getLanHost];
    if ([ESLocalNetworking shared].reachableBox && lanHost) {
        url = [NSString stringWithFormat:@"%@/space/v1/api/gateway/download",lanHost];
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    
    [self setQueryParams:queryParams withUrlComponents:components];
    
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    [self addHeaderParams:headerParams withRequest:mRequest];
    [self addBodyParams:bodyParams withRequest:mRequest];
    [mRequest setHTTPMethod: (method ?: @"POST")];
    
    [[[NSURLSession sharedSession] downloadTaskWithRequest:mRequest
                                         completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self handleLocationUrl:location response:response error:error];
    }] resume];
}

- (void)handleLocationUrl:(NSURL *)url response:(NSURLResponse *)response error:(NSError * _Nullable)error {
    if (!self.successBlock || !self.failBlock) {
        return;
    }
    if (error) {
        [self callbackFailWithRequestId:self.requestId response:response error:error];
        return;
    }
    [self callbackSuccessWithRequestId:self.requestId response:url];
}

- (void)callbackSuccessWithRequestId:(NSInteger)reuqestId
                            response:(NSURL *)locationUrl {
    ESDLog(@"requestTaskContext: %@  \n callbackSuccessWithRequestId: %ld \n response: %@ \n", self.taskContext, (long)reuqestId, locationUrl);
    self.status = ESNetworkRequestServiceStatus_Finish;
    ESPerformBlockAsynOnMainThread(^{
        self.downloadSuccessBlock(reuqestId , locationUrl);
        [ESNetworkRequestManager.sharedInstance removeRequest:self];
    });
}

@end


@interface ESNetworkCallRequestServiceTask ()

@property (nonatomic, strong) ESTokenItem *token;

- (NSDictionary *)makeCallBodyWithApiParams:(NSDictionary *)apiParams
                       queryParams:(NSDictionary *)queryParams
                          header:(NSDictionary *)headerParams
                              body:(NSDictionary *)bodyParams
                                      token:(ESTokenItem *)token;
@end

@interface ESNetworkRequestCallDownloadTask ()

@property (nonatomic, copy) NSString *targetPath;

@end


@implementation ESNetworkRequestCallDownloadTask

- (void)sendCallDownloadRequest:(NSDictionary *)apiParams
                    queryParams:(NSDictionary *)queryParams
                         header:(NSDictionary *)headerParams
                           body:(NSDictionary *)bodyParams
                     targetPath:(NSString * _Nullable)targetPath {
    self.targetPath = targetPath;

    if (ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock) {
        dispatch_async(ESNetworkRequestManager.sharedInstance.downloadQueue, ^{
            dispatch_semaphore_wait(ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock, DISPATCH_TIME_FOREVER);
            [super sendCallRequest:apiParams queryParams:queryParams header:headerParams body:bodyParams];
        });
    } else {
        [super sendCallRequest:apiParams queryParams:queryParams header:headerParams body:bodyParams];
    }
}

- (void)sendCallRequest:(NSDictionary *)apiParams
               queryParams:(NSDictionary *)queryParams
                  header:(NSDictionary *)headerParams
                      body:(NSDictionary *)bodyParams
                     token:(ESTokenItem *)token {
    ESDLog(@"apiParams : %@  \n queryParams: %@ \n  headerParams: %@ \n bodyParams: %@ \n token: %@ \n ", apiParams, queryParams, headerParams, bodyParams, token);
    NSDictionary *callBody = [self makeCallBodyWithApiParams:apiParams queryParams:queryParams header:headerParams body:bodyParams token:token];
    [self sendDownloadRequestWithQueryParams:nil header:nil body:callBody token:token];
}

- (void)sendDownloadRequestWithQueryParams:(NSDictionary *)queryParams
                                    header:(NSDictionary *)headerParams
                                      body:(NSDictionary *)bodyParams
                                     token:(ESTokenItem *)token {
    NSString *userDomain = ESBoxManager.activeBox.info.userDomain;
    NSString *url = [NSString stringWithFormat:@"http://%@/space/v1/api/gateway/download",userDomain];

    if (ESBoxManager.activeBox != nil &&
        ESBoxManager.activeBox.localHost.length > 0 &&
        ESBoxManager.activeBox.enableInternetAccess == NO) {
        userDomain = ESBoxManager.activeBox.localHost;
        url = [NSString stringWithFormat:@"%@/space/v1/api/gateway/download",userDomain];
    }
    
    //NSString *url = @"http://g398hmrn.dev-space.eulix.xyz/space/v1/api/gateway/applet/down";
//    NSString *url = [NSString stringWithFormat:@"http://%@/space/v1/api/gateway/download",userDomain];
    
    NSString * lanHost = [[ESLocalNetworking shared] getLanHost];
    if ([ESLocalNetworking shared].reachableBox && lanHost) {
        url = [NSString stringWithFormat:@"%@/space/v1/api/gateway/download",lanHost];
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    
    [self setQueryParams:queryParams withUrlComponents:components];
    
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    [self addHeaderParams:headerParams withRequest:mRequest];
    [self addBodyParams:bodyParams withRequest:mRequest];
    [mRequest setHTTPMethod: @"POST"];
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:mRequest
                                         completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock) {
//            dispatch_async(ESNetworkRequestManager.sharedInstance.downloadQueue, ^{
                dispatch_semaphore_signal(ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock);
                [self handleLocationUrl:location.absoluteString response:response error:error token:token];
//            });
        } else {
            [self handleLocationUrl:location.absoluteString response:response error:error token:token];
        }
    }];
    
    NSInteger requestId = downloadTask.taskIdentifier;
    self.taskContext = [[ESNetworkRequestTaskContext alloc] initWithTaskId:requestId];
    self.taskContext.requestId = requestId;
    self.taskContext.queryParams = queryParams;
    self.taskContext.headerParams = headerParams;
    self.taskContext.bodyParams = bodyParams;

    self.requestId = requestId;
    self.taskId = requestId;
    
    self.status = ESNetworkRequestServiceStatus_Running;
    [downloadTask resume];
}

- (void)handleLocationUrl:(NSString *)url response:(NSURLResponse *)response error:(NSError * _Nullable)error token:(ESTokenItem *)token {
    if (!self.downloadSuccessBlock || !self.failBlock) {
        return;
    }
    if (error) {
        [self callbackFailWithRequestId:self.requestId response:response error:error];
        return;
    }
    [self callbackSuccessWithRequestId:self.requestId response:url token:token];
}

- (void)callbackSuccessWithRequestId:(NSInteger)reuqestId
                            response:(NSString *)locationUrl
                               token:(ESTokenItem *)token {
    ESDLog(@"requestTaskContext: %@  \n callbackSuccessWithRequestId: %ld \n response: %@ \n", self.taskContext, (long)reuqestId, locationUrl);
    self.status = ESNetworkRequestServiceStatus_Finish;
    NSString *decryptTargetPath = self.targetPath.length > 0 ? self.targetPath :
                                   [ESDiskCacheManager randomCacheLocationWithName:[NSString stringWithFormat:@"%ld", random()]];
    NSString *fixLocationUrl = [locationUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [ESFileHandleManager.manager decryptFile:fixLocationUrl target:decryptTargetPath key:token.secretKey iv:token.secretIV];

//    ESPerformBlockAsynOnMainThread(^{
        self.downloadSuccessBlock(reuqestId , [NSURL fileURLWithPath:self.targetPath]);
        [ESNetworkRequestManager.sharedInstance removeRequest:self];
//    });
}

- (void)setStatus:(ESNetworkRequestServiceStatus)status {
    [super setStatus: status];
    if (self.statusUpdateBlock) {
        self.statusUpdateBlock(self.requestId, self.status);
    }
}

- (void)cancel {
    if (self.sessionTask.state == NSURLSessionTaskStateRunning) {
        [self.sessionTask cancel];
    }

    self.status = ESNetworkRequestServiceStatus_Cancel;
    if (ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock) {
        dispatch_semaphore_signal(ESNetworkRequestManager.sharedInstance.downloadSemaphoreLock);
    }
}


@end

