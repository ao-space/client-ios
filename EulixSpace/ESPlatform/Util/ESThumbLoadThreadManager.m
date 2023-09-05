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
//  ESThumbLoadThreadManager.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/6.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESThumbLoadThreadManager.h"

@interface ESThumbLoadThreadManager ()

@property (nonatomic, strong)dispatch_queue_t requestQueue;
@property (nonatomic, strong)dispatch_semaphore_t requestSemaphoreLock;

@end

@implementation ESThumbLoadThreadManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create("ESThumbLoadThread_Queue", DISPATCH_QUEUE_CONCURRENT);
        self.requestSemaphoreLock = dispatch_semaphore_create(6);
    }
    return self;
}

@end
