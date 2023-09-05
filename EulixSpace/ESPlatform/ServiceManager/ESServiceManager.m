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
//  ESServiceManager.m
//  EulixSpace
//
//  Created by KongBo on 2023/5/10.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESServiceManager.h"
#import "ESCache.h"

static NSString * const ESUserUniqueKey = @"ESBoxUserUniqueKey";

@interface ESServiceManager ()

@property (nonatomic, strong) NSArray<id<ESServiceModuleProtocol>> *serviceModuleList;

@end

@implementation ESServiceManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)startOrResetAllServicesWithBox:(ESBoxItem *)item {
    if (item == nil) {
        return;
    }
 
    [[ESServiceManager shared] startOrResetAllServicesWithBox:item];
}

- (void)startOrResetAllServicesWithBox:(ESBoxItem *)item {
    if (self.serviceModuleList.count <= 0) {
        [self registerServices];
    }
    
    NSString *userKey = [item uniqueKey];
    if (self.cachedUserUniqueKey.length <= 0  ||
        [self.cachedUserUniqueKey isEqualToString:ESSafeString(userKey)]) {
        [self startServices];
    } else {
        [self resetService];
    }
    
    [self setUserUniqueKey:ESSafeString(userKey)];
}

- (void)startServices {
    ESDLog(@"[ESServiceManager]  [startServices] %@", self.serviceModuleList);

    [self.serviceModuleList enumerateObjectsUsingBlock:^(id<ESServiceModuleProtocol>  _Nonnull serviceModule, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([serviceModule respondsToSelector:@selector(startService)]) {
            [serviceModule startService];
        }
    }];
}

- (void)resetService {
    ESDLog(@"[ESServiceManager]  [resetService] %@", self.serviceModuleList);

    [self.serviceModuleList enumerateObjectsUsingBlock:^(id<ESServiceModuleProtocol>  _Nonnull serviceModule, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([serviceModule respondsToSelector:@selector(resetService)]) {
            [serviceModule resetService];
        }
    }];
}

- (NSString *)cachedUserUniqueKey {
   NSString *userUniqueKey = [[ESCache defaultCache] objectForKey:ESUserUniqueKey];
    return userUniqueKey;
}

- (void)setUserUniqueKey:(NSString *)userUniqueKey {
    [[ESCache defaultCache] setObject:userUniqueKey forKey:ESUserUniqueKey];
}

- (void)registerServices {
    NSArray *registerServiceClassList = [self registerServiceClassList];
    NSMutableArray *serviceModuleTempList = [NSMutableArray array];
    [registerServiceClassList enumerateObjectsUsingBlock:^(NSString *serviceClassName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![serviceClassName isKindOfClass:[NSString class]]) {
            return;
        }
        
        if (serviceClassName.length <= 0) {
            return;
        }
        
        Class serviceClass = NSClassFromString(serviceClassName);
        if (!serviceClass) {
            return;
        }
        
        id<ESServiceModuleProtocol> serviceObject;
        if ([serviceClass respondsToSelector:@selector(newServiceInstance)]) {
            serviceObject = (id<ESServiceModuleProtocol>)[serviceClass newServiceInstance];
        } else {
            serviceObject = (id<ESServiceModuleProtocol>)[serviceClass new];
        }
        if (!([serviceObject respondsToSelector:@selector(startService)] && [serviceObject respondsToSelector:@selector(resetService)])) {
            return;
        }
        [serviceModuleTempList addObject:serviceObject];
    }];
    self.serviceModuleList = [serviceModuleTempList copy];
}

- (NSArray<NSString *> *)registerServiceClassList {
    return @[@"ESSmartPhotoAsyncManager",
             @"ESTransferManager"];
}

@end
