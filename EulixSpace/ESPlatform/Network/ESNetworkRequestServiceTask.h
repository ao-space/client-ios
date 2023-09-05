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
//  ESNetworkRequestServiceTask.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNetworkRequestTaskContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ESNetworkRequestServiceStatus) {
    ESNetworkRequestServiceStatus_Default,
    ESNetworkRequestServiceStatus_Start,
    ESNetworkRequestServiceStatus_Running,
    ESNetworkRequestServiceStatus_Cancel,
    ESNetworkRequestServiceStatus_Finish,
    ESNetworkRequestServiceStatus_Unknow
};

typedef NSInteger NSNetworkErrorCode;

FOUNDATION_EXTERN NSErrorDomain const ESNetWorkErrorDomain;
FOUNDATION_EXTERN NSNetworkErrorCode const NSNetworkErrorParams;
FOUNDATION_EXTERN NSNetworkErrorCode const NSNetworkErrorResponseStructure;
FOUNDATION_EXTERN NSNetworkErrorCode const NSNetworkErrorResponseBusiness;
FOUNDATION_EXTERN NSNetworkErrorCode const NSNetworkErrorResponseParse;

FOUNDATION_EXTERN NSString *const ESNetworkErrorUserInfoMessageKey;
FOUNDATION_EXTERN NSString *const ESNetworkErrorUserInfoResposeCodeKey;
FOUNDATION_EXTERN NSString *const ESNetworkErrorUserInfoResposeResultKey;

FOUNDATION_EXTERN NSString *const ESNetworkErrorSystemNeedUpdateCode;

typedef void (^ESRequestServiceSuccessBlock)(NSInteger requestId, id _Nullable response);
typedef void (^ESRequestServiceFailBlock)(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface ESNetworkRequestServiceTask : NSObject

@property (nonatomic, copy) ESRequestServiceSuccessBlock successBlock;
@property (nonatomic, copy) ESRequestServiceFailBlock failBlock;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, assign) NSInteger requestId;

@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, strong) ESNetworkRequestTaskContext *taskContext;
@property (atomic, assign) NSInteger retryCount;
@property (nonatomic, assign) ESNetworkRequestServiceStatus status;
@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

- (void)sendRequest:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams;


- (void)sendRequest:(NSString *)baseUrl
               path:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams;


- (void)parseResponseData:(NSData *)data reponse:(NSURLResponse * _Nullable)response;

- (void)cancel;


- (void)callbackSuccessWithRequestId:(NSInteger)reuqestId
                            response:(id)response;

- (void)callbackFailWithRequestId:(NSInteger)requestId
                         response:(NSURLResponse * _Nullable)response
                            error:(NSError *_Nullable)error;

- (BOOL)returnCodeIsSuccess:(id)code;

@end

NS_ASSUME_NONNULL_END
