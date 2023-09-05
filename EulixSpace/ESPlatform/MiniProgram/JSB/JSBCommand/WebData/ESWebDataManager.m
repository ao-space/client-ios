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
//  ESWebDataStorage.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESWebDataManager.h"
#import <YYCache/YYCache.h>
#import "ESBoxManager.h"
#import "ESAccountManager.h"

@interface ESWebDataStorage : NSObject

@property (nonatomic, strong) YYCache *cache;
@property (nonatomic, readonly) NSString *name;

@end

@implementation ESWebDataStorage

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _cache = [YYCache cacheWithName:name];
    }
    return self;
}

- (NSString *)name {
    return _cache.name;
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

static NSString * const ESWebDataStorageNameListKey = @"ESWebDataStorageNameListKey";


@interface ESWebDataManager ()

@property (nonatomic, strong) ESWebDataStorage *currentWebDataStorage;
@property (nonatomic, copy) NSString *appletId;

@end

@implementation ESWebDataManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)cacheForAppletId:(NSString *)appletId {
    ESWebDataManager *webDataManager = [ESWebDataManager shared];
    NSString *appletCacheName = [NSString stringWithFormat:@"%@-%@", ESBoxManager.activeBox.uniqueKey, appletId];
    if ( ![webDataManager.currentWebDataStorage.name isEqualToString:appletCacheName]) {
        webDataManager.currentWebDataStorage = [[ESWebDataStorage alloc] initWithName:appletCacheName];
    }
    return webDataManager;
}

- (NSArray <NSString *> *)webdataStorageNameList {
    return [[NSUserDefaults standardUserDefaults] objectForKey:ESWebDataStorageNameListKey];
}

- (NSString *)currentCacheName {
    NSString *appletCacheName = [NSString stringWithFormat:@"%@-%@", ESBoxManager.activeBox.uniqueKey, self.appletId];
    return appletCacheName;
}

- (ESWebDataStorage *)currentWebDataStorage {
    if (!_currentWebDataStorage || ![_currentWebDataStorage.name isEqualToString:[self currentCacheName]]) {
        _currentWebDataStorage = [[ESWebDataStorage alloc] initWithName:[self currentCacheName]];
    }

    return _currentWebDataStorage;
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [self.currentWebDataStorage setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [self.currentWebDataStorage objectForKey:key];
}

- (void)clear {
    [self.currentWebDataStorage clear];
}
@end



