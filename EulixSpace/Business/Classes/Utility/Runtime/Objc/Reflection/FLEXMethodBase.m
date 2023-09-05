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
//  FLEXMethodBase.m
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXMethodBase.h"


@implementation FLEXMethodBase

#pragma mark Initializers

+ (instancetype)buildMethodNamed:(NSString *)name withTypes:(NSString *)typeEncoding implementation:(IMP)implementation {
    return [[self alloc] initWithSelector:sel_registerName(name.UTF8String) types:typeEncoding imp:implementation];
}

- (id)initWithSelector:(SEL)selector types:(NSString *)types imp:(IMP)imp {
    NSParameterAssert(selector); NSParameterAssert(types); NSParameterAssert(imp);
    
    self = [super init];
    if (self) {
        _selector = selector;
        _typeEncoding = types;
        _implementation = imp;
        _name = NSStringFromSelector(self.selector);
    }
    
    return self;
}

- (NSString *)selectorString {
    return _name;
}

#pragma mark Overrides

- (NSString *)description {
    if (!_flex_description) {
        _flex_description = [NSString stringWithFormat:@"%@ '%@'", _name, _typeEncoding];
    }

    return _flex_description;
}

@end
