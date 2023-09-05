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
//  ESNetworkCallRequestServiceTask.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestServiceTask.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const ESNetworkApiNameKey;
FOUNDATION_EXTERN NSString *const ESNetworkServiceNameKey;
FOUNDATION_EXTERN NSString *const ESNetworkApiVersionsKey;

@interface ESNetworkCallRequestServiceTask : ESNetworkRequestServiceTask

- (void)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams;
@end

NS_ASSUME_NONNULL_END
