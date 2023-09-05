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
//  ESAppletResponseBaseListAppletInfoRes.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESObject.h"

#import "ESAppletInfoResModel.h"
@protocol ESAppletInfoResModel;
@class ESAppletInfoResModel;

NS_ASSUME_NONNULL_BEGIN

@interface ESAppletResponseBaseListAppletInfoRes : ESObject

/* 返回码，格式为 GW-xxx。 [optional]
 */
@property(nonatomic) NSString* code;
/* 错误信息中的上下文信息，用于通过 MessageFormat 格式化 message。 [optional]
 */
@property(nonatomic) NSArray<NSObject*>* context;
/* 错误信息，格式为 MessageFormat： {0} xx {1}， 参考：https://docs.oracle.com/javase/8/docs/api/java/text/MessageFormat.html 。 [optional]
 */
@property(nonatomic) NSString* message;
/* 请求标识 id，用于跟踪业务请求过程。 [optional]
 */
@property(nonatomic) NSString* requestId;

@property(nonatomic) NSArray<ESAppletInfoResModel>* results;

@end

NS_ASSUME_NONNULL_END
