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
//  NSString+FLEX.h
//  FLEX
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXRuntimeConstants.h"

@interface NSString (FLEXTypeEncoding)

///@return whether this type starts with the const specifier
@property (nonatomic, readonly) BOOL flex_typeIsConst;
/// @return the first char in the type encoding that is not the const specifier
@property (nonatomic, readonly) FLEXTypeEncoding flex_firstNonConstType;
/// @return the first char in the type encoding after the pointer specifier, if it is a pointer
@property (nonatomic, readonly) FLEXTypeEncoding flex_pointeeType;
/// @return whether this type is an objc object of any kind, even if it's const
@property (nonatomic, readonly) BOOL flex_typeIsObjectOrClass;
/// @return the class named in this type encoding if it is of the form \c @"MYClass"
@property (nonatomic, readonly) Class flex_typeClass;
/// Includes C strings and selectors as well as regular pointers
@property (nonatomic, readonly) BOOL flex_typeIsNonObjcPointer;

@end

@interface NSString (KeyPaths)

- (NSString *)flex_stringByRemovingLastKeyPathComponent;
- (NSString *)flex_stringByReplacingLastKeyPathComponent:(NSString *)replacement;

@end
