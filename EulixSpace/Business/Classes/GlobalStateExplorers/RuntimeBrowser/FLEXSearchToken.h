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
//  FLEXSearchToken.h
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TBWildcardOptions) {
    TBWildcardOptionsNone   = 0,
    TBWildcardOptionsAny    = 1,
    TBWildcardOptionsPrefix = 1 << 1,
    TBWildcardOptionsSuffix = 1 << 2,
};

/// A token may contain wildcards at one or either end,
/// but not in the middle of the token (as of now).
@interface FLEXSearchToken : NSObject

+ (instancetype)any;
+ (instancetype)string:(NSString *)string options:(TBWildcardOptions)options;

/// Will not contain the wildcard (*) symbol
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) TBWildcardOptions options;

/// Opposite of "is ambiguous"
@property (nonatomic, readonly) BOOL isAbsolute;
@property (nonatomic, readonly) BOOL isAny;
/// Still \c isAny, but checks that the string is empty
@property (nonatomic, readonly) BOOL isEmpty;

@end
