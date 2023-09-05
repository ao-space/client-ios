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
//  ESLanTransferManager.h
//  EulixSpace
//
//  Created by dazhou on 2023/2/2.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTransferDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class ESCallRequest;
@class UIApplication;
@class ESUploadEntity;
@class ESRealCallRequest;
@interface ESLanTransferManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

+ (instancetype)shared;


- (NSURLSessionUploadTask *)uploadFile:(NSString *)filePath
                                  host:(NSString *)host
                                 query:(NSDictionary *)query
                                 token:(NSString *)token
                              progress:(ESProgressHandler)progress
                     completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (NSURLSessionDownloadTask *)downloadFile:(NSString *)filePath
                                      host:(NSString *)host
                                     query:(NSDictionary *)query
                                    header:(NSDictionary *)header
                                  progress:(ESProgressHandler)progress
                         completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;


- (BOOL)hasCertData;
- (void)reqCertIfNot;

@end

NS_ASSUME_NONNULL_END
