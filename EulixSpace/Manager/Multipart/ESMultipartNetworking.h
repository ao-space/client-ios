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
// Created by Ye Tao on 2021/12/2.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESUploadMetadata.h"
#import <Foundation/Foundation.h>

@class ESUploadMetadata, ESFileInfo, ESRspCompleteMultipartTaskRsp;
@interface ESMultipartNetworking : NSObject

- (void)create:(ESUploadMetadata *)metadata completionBlock:(void (^)(id, NSError *))completionBlock;

- (void)completeUploadId:(NSString *)uploadId completionBlock:(void (^)(id, NSError *))completionBlock;

- (void)completeUploadListUUID:(NSString *)uploadId completionBlock:(void (^)(id, NSError *))completionBlock;

+ (ESUploadRspBody *)transferUploadResult:(ESFileInfo *)file;
+ (ESRspUploadRspBody *)transferModel:(ESRspCompleteMultipartTaskRsp *)data;
@end
