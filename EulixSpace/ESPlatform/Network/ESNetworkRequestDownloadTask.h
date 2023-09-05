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
//  ESNetworkRequestDownloadTask.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestServiceTask.h"
#import "ESNetworkCallRequestServiceTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESRequestServiceDownloadSuccessBlock)(NSInteger requestId, NSURL *location);
typedef void (^ESRequestServiceStatusBlock)(NSInteger requestId, ESNetworkRequestServiceStatus status);

@interface ESNetworkRequestDownloadTask : ESNetworkRequestServiceTask

@property (nonatomic, copy) ESRequestServiceDownloadSuccessBlock downloadSuccessBlock;

- (void)sendDownloadRequestWithQueryParams:(NSDictionary *)queryParams
                                   header:(NSDictionary *)headerParams
                                     body:(NSDictionary *)bodyParams
                                   method:(NSString *)method;

@end


@interface ESNetworkRequestCallDownloadTask : ESNetworkCallRequestServiceTask

@property (nonatomic, copy) ESRequestServiceDownloadSuccessBlock downloadSuccessBlock;
@property (nonatomic, copy) ESRequestServiceStatusBlock statusUpdateBlock;


- (void)sendCallDownloadRequest:(NSDictionary *)apiParams
                    queryParams:(NSDictionary *)queryParams
                         header:(NSDictionary *)headerParams
                           body:(NSDictionary *)bodyParams
                     targetPath:(NSString * _Nullable)targetPath;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
