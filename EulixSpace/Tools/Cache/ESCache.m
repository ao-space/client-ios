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
//  ESCache.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCache.h"
#import <YYCache/YYCache.h>

@interface ESCache ()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation ESCache

+ (instancetype)defaultCache {
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
        _cache = [YYCache cacheWithName:NSBundle.mainBundle.bundleIdentifier];
    }
    return self;
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [_cache setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [_cache objectForKey:key];
}

- (void)clear {
    [_cache removeAllObjects];
}

@end
