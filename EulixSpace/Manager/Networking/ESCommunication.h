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
//  ESCommunication.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESCallRequest;
@class ESRealCallRequest;
@class UIApplication;
@class ESUploadEntity;
@class AFHTTPSessionManager;
@interface ESCommunication : NSObject <NSURLSessionDelegate>

+ (instancetype)shared;

- (AFHTTPSessionManager *)getSessionManager;

- (AFHTTPSessionManager *)getSessionWWanManager;

- (AFHTTPSessionManager *)getSessionWWanManager4Lan;

- (NSURLSessionUploadTask *)uploadFile:(NSString *)path
                             serverUrl:(NSString *)serverUrl
                                entity:(ESUploadEntity *)entity
                           realRequest:(ESRealCallRequest *)realRequest
                           callRequest:(ESCallRequest *)callRequest
                        sessionManager:(AFHTTPSessionManager *)sessionManager
                     completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end
