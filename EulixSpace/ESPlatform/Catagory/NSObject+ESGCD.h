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
//  NSObject+ESGCD.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ES_GLOBAL_DEFAULT_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

typedef void (^ESObjectBlock)(void);

// 主线程中执行 block，没有同步异步要求
void ESPerformBlockOnMainThread(ESObjectBlock block);

// 在主线程中执行
void ESPerformBlockAsynOnMainThread(ESObjectBlock block);

// 在主线程中执行
void ESPerformBlockSynOnMainThread(ESObjectBlock block);

//  默认优先级DISPATCH_QUEUE_PRIORITY_DEFAULT, 会在global queue中执行
void ESPerformBlockAsyn(ESObjectBlock block);

// 在主线程中执行
void ESPerformBlockOnMainThreadAfterDelay(NSTimeInterval seconds, ESObjectBlock block);

//  默认优先级, 会在global queue中执行
void ESPerformBlockAfterDelay(NSTimeInterval seconds, ESObjectBlock block);

// 会在global queue中执行
void ESPerformBlockAsynWithPriorityAndWait(dispatch_queue_priority_t priority, BOOL wait, ESObjectBlock block);

//自己定制
void ESPerformBlockAsynAfterDelayInQueue(dispatch_queue_t queue, NSTimeInterval seconds, ESObjectBlock block);
