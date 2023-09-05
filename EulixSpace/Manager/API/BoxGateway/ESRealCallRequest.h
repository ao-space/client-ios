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
//  ESRealCallRequest.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESRealCallRequest : NSObject

@property (nonatomic, copy) NSString *requestId;

@property (nonatomic, copy) NSString *serviceName;

@property (nonatomic, copy) NSString *apiName;

@property (nonatomic, copy) NSString *apiVersion;

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *queries;

@property (nonatomic, copy) NSDictionary *entity;

@property (nonatomic, readonly) NSString *json;

@end

NS_ASSUME_NONNULL_END
