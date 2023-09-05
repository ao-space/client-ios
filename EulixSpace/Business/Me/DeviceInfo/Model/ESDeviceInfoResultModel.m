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
//  ESDeviceInfoResultModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceInfoResultModel.h"
#import <YYModel/YYModel.h>

@implementation ESServiceInfoResultModel

@end

@implementation ESServiceDetailResultModel

@end

@implementation ESDeviceInfoResultModel

// 声明自定义类参数类型
+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"serviceVersion" : [ESServiceInfoResultModel class],
           @"serviceDetail" : [ESServiceDetailResultModel class]
         };
}

@end
