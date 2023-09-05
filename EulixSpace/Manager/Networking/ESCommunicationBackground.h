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
//  ESCommunicationBackground.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESCallRequest;
@class UIApplication;
@class ESUploadEntity;
@class ESRealCallRequest;
@interface ESCommunicationBackground : NSObject <NSURLSessionDelegate>

+ (instancetype)shared;

- (NSURLSessionUploadTask *)uploadFile:(NSString *)path
                             serverUrl:(NSString *)serverUrl
                                entity:(ESUploadEntity *)entity
                           realRequest:(ESRealCallRequest *)realRequest
                           callRequest:(ESCallRequest *)callRequest
                               session:(NSURLSession *)session
                     completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block;

@end
