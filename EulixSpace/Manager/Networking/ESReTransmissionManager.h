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
//  ESReTransmissionManager.h
//  EulixSpace
//
//  Created by dazhou on 2022/6/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESReTransmissionManager : NSObject

+ (instancetype)Instance;

// 发送请求时，进行记录
- (void)addTransmission:(NSString *)key;
// 判断是否还能再次发送
- (BOOL)canTrans:(NSString *)key max:(int)maxNum increment:(BOOL)increment;
// 任务结束时，移除请求记录
- (void)removeTransission:(NSString *)key;


- (int)addFailedEvent:(NSString *)key distance:(int)distance max:(int)max;
- (BOOL)failedEventIsResume:(NSString *)key distance:(int)distance;
- (BOOL)failedEventIsResume:(NSString *)key distance:(int)distance max:(int)max;
@end

NS_ASSUME_NONNULL_END
