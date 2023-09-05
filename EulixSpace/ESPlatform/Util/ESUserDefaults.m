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
//  ESUserDefaults.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUserDefaults.h"
#import <YYCache/YYCache.h>

@interface ESUserDefaults ()

@property (nonatomic, strong) YYCache *cache;
@property (readwrite, nonatomic, strong) NSLock *lock;

@end

@implementation ESUserDefaults

+ (instancetype)standardUserDefaults {
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
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (nullable id)objectForKey:(ESUserDefaultsKey)key {
    return [self defaultObjectForKey:key];
}

- (nullable id)defaultObjectForKey:(ESUserDefaultsKey)key {
    __block id obj = nil;
    [self performBlockInLock:^{
        obj = [self.cache objectForKey:key];
    }];
    return obj;
}

- (NSInteger)integerForKey:(ESUserDefaultsKey)key {
    id obj = [self defaultObjectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)obj).integerValue;
    } else if ([obj isKindOfClass:[NSString class]]) {
        return ((NSString *)obj).integerValue;
    }
    
    return 0;
}

- (float)floatForKey:(ESUserDefaultsKey)key {
    id obj = [self defaultObjectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)obj).floatValue ;
    } else if ([obj isKindOfClass:[NSString class]]) {
        return ((NSString *)obj).floatValue;
    }
    return 0;
}

- (double)doubleForKey:(ESUserDefaultsKey)key {
    id obj = [self defaultObjectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)obj).doubleValue ;
    } else if ([obj isKindOfClass:[NSString class]]) {
        return ((NSString *)obj).doubleValue;
    }
    return 0;
}

- (BOOL)boolForKey:(ESUserDefaultsKey)key {
    id obj = [self defaultObjectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)obj).integerValue == 0 ? NO : YES ;
    } else if ([obj isKindOfClass:[NSString class]]) {
        return [(NSString *)obj isEqualToString:@"1"] || [(NSString *)obj isEqualToString:@"YES"] || [((NSString *)obj).lowercaseString isEqualToString:@"true"] ? YES : NO;
    }
    return NO;
}

- (NSURL *)URLForKey:(ESUserDefaultsKey)key {
    id obj = [self defaultObjectForKey:key];
    
    if ([obj isKindOfClass:[NSURL class]]) {
        return (NSURL *)obj;
    }
    
    if ([obj isKindOfClass:[NSString class]]) {
        return [[self class] compatibleURLWithString:obj];
    }

    return nil;
}

+ (NSURL *)compatibleURLWithString:(NSString *)string {
    if (string.length == 0) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:string];
    if (URL == nil) {
        URL = [NSURL fileURLWithPath:string];
    }
    
    return URL;
}

- (void)setObject:(nullable id)value forKey:(ESUserDefaultsKey)key {
    if (key == nil) return;
    
    [self performBlockInLock:^{
        if (value == nil) {
            [self.cache removeObjectForKey:key];
        } else {
            [self.cache setObject:value forKey:key];
        }
    }];
}

- (void)setInteger:(NSInteger)value forKey:(ESUserDefaultsKey)key {
    return [self setObject:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(ESUserDefaultsKey)key {
    return [self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(ESUserDefaultsKey)key {
    return [self setObject:@(value) forKey:key];
}

- (void)setBool:(BOOL)value forKey:(ESUserDefaultsKey)key {
    return [self setObject:@(value) forKey:key];
}

- (void)performBlockInLock:(dispatch_block_t)block {
    [self.lock lock];
    block();
    [self.lock unlock];
}

- (void)clear {
    [_cache removeAllObjects];
}

@end
