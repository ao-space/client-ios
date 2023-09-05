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
//  FLEXRuntimeKeyPath.m
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXRuntimeKeyPath.h"
#import "FLEXRuntimeClient.h"

@interface FLEXRuntimeKeyPath () {
    NSString *flex_description;
}
@end

@implementation FLEXRuntimeKeyPath

+ (instancetype)empty {
    static FLEXRuntimeKeyPath *empty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FLEXSearchToken *any = FLEXSearchToken.any;

        empty = [self new];
        empty->_bundleKey = any;
        empty->flex_description = @"";
    });

    return empty;
}

+ (instancetype)bundle:(FLEXSearchToken *)bundle
                 class:(FLEXSearchToken *)cls
                method:(FLEXSearchToken *)method
            isInstance:(NSNumber *)instance
                string:(NSString *)keyPathString {
    FLEXRuntimeKeyPath *keyPath  = [self new];
    keyPath->_bundleKey = bundle;
    keyPath->_classKey  = cls;
    keyPath->_methodKey = method;

    keyPath->_instanceMethods = instance;

    // Remove irrelevant trailing '*' for equality purposes
    if ([keyPathString hasSuffix:@"*"]) {
        keyPathString = [keyPathString substringToIndex:keyPathString.length];
    }
    keyPath->flex_description = keyPathString;
    
    if (bundle.isAny && cls.isAny && method.isAny) {
        [FLEXRuntimeClient initializeWebKitLegacy];
    }

    return keyPath;
}

- (NSString *)description {
    return flex_description;
}

- (NSUInteger)hash {
    return flex_description.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[FLEXRuntimeKeyPath class]]) {
        FLEXRuntimeKeyPath *kp = object;
        return [flex_description isEqualToString:kp->flex_description];
    }

    return NO;
}

@end
