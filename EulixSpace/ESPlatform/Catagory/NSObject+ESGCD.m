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
//  NSObject+ESGCD.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "NSObject+ESGCD.h"

void ESPerformBlockOnMainThread(ESObjectBlock block) {
    if ([NSThread isMainThread]) {
        if (block) block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void ESPerformBlockAsynOnMainThread(ESObjectBlock block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void ESPerformBlockSynOnMainThread(ESObjectBlock block)
{
    if ([NSThread isMainThread]) {
        if (block) block();
    }else{
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void ESPerformBlockAsyn(ESObjectBlock block)
{
    dispatch_async(ES_GLOBAL_DEFAULT_QUEUE, block);
}

void ESPerformBlockOnMainThreadAfterDelay(NSTimeInterval seconds, ESObjectBlock block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void ESPerformBlockAfterDelay(NSTimeInterval seconds, ESObjectBlock block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, ES_GLOBAL_DEFAULT_QUEUE, block);
}


void ESPerformBlockAsynWithPriorityAndWait(dispatch_queue_priority_t priority, BOOL wait, ESObjectBlock block)
{
    dispatch_queue_t queue = dispatch_get_global_queue(priority, 0);
    if (wait) {
        dispatch_sync(queue, block);
    }else{
        dispatch_async(queue, block);
    }
}

void ESPerformBlockAsynAfterDelayInQueue(dispatch_queue_t queue, NSTimeInterval seconds, ESObjectBlock block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, queue, block);
}

