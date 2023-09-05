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
//  ESGatewayClient.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESApiClient.h"

@class ESBoxItem;
@interface ESApiClient (AOP)

/// 从盒子信息中生成该盒子请求所需的ApiClient
/// ！！！如果要访问某个盒子，最好使用这个方法创建盒子对应的ApiClient
/// @param box 盒子信息
+ (instancetype)es_box:(ESBoxItem *)box;

@end
