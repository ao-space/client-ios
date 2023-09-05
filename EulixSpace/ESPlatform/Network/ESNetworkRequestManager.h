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
//  ESNetworkRequestManager.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNetworkRequestServiceTask.h"
#import "ESNetworkRequestDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESNetworkRequestManager : NSObject

+ (NSInteger)sendRequest:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock;

+ (NSInteger)sendRequest:(NSString *)baseUrl
                    path:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock;

+ (NSInteger)sendCallRequestWithServiceName:(NSString *)serviceName
                                    apiName:(NSString *)apiName
                                queryParams:(NSDictionary * _Nullable)queryParams
                                     header:(NSDictionary * _Nullable)headerParams
                                       body:(NSDictionary * _Nullable)bodyParams
                                  modelName:(NSString * _Nullable)modelName
                               successBlock:(ESRequestServiceSuccessBlock)successBlock
                                  failBlock:(ESRequestServiceFailBlock)failBlock;

+ (NSInteger)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
          modelName:(NSString * _Nullable)modelName
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock;

+ (NSInteger)sendCallUploadRequest:(NSDictionary *)apiParams
                queryParams:(NSDictionary *)queryParams
                   header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
               filePath:(NSString *)filePath
            successBlock:(ESRequestServiceSuccessBlock)successBlock
               failBlock:(ESRequestServiceFailBlock)failBlock;

+ (NSInteger)sendCallUploadRequest:(NSDictionary *)apiParams
                queryParams:(NSDictionary *)queryParams
                   header:(NSDictionary *)headerParams
                       body:(NSDictionary *)bodyParams
                       data:(NSData *)data
                successBlock:(ESRequestServiceSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock;


+ (NSInteger)downloadRequestWithQueryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
                      method:(NSString *)method
                successBlock:(ESRequestServiceDownloadSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock;


+ (NSInteger)sendCallDownloadRequest:(NSDictionary *)apiParams
             queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
             targetPath:(NSString *)targetPath
                status:(ESRequestServiceStatusBlock)statusBlock
                successBlock:(ESRequestServiceDownloadSuccessBlock)successBlock
                   failBlock:(ESRequestServiceFailBlock)failBlock;

+ (void)setDownloadThreadMaxCount:(NSInteger)threadLimit;

+ (void)cancelRequestById:(NSInteger)requestId;
+ (ESNetworkRequestServiceStatus)requestTaskStatusWithId:(NSInteger)requestId;

@end

NS_ASSUME_NONNULL_END
