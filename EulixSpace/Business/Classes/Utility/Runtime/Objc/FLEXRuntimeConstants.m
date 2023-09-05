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
//  FLEXRuntimeConstants.m
//  FLEX
//
//  Created by Tanner on 3/11/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntimeConstants.h"

const unsigned int kFLEXNumberOfImplicitArgs = 2;

NSString *const kFLEXPropertyAttributeKeyTypeEncoding = @"T";
NSString *const kFLEXPropertyAttributeKeyBackingIvarName = @"V";
NSString *const kFLEXPropertyAttributeKeyReadOnly = @"R";
NSString *const kFLEXPropertyAttributeKeyCopy = @"C";
NSString *const kFLEXPropertyAttributeKeyRetain = @"&";
NSString *const kFLEXPropertyAttributeKeyNonAtomic = @"N";
NSString *const kFLEXPropertyAttributeKeyCustomGetter = @"G";
NSString *const kFLEXPropertyAttributeKeyCustomSetter = @"S";
NSString *const kFLEXPropertyAttributeKeyDynamic = @"D";
NSString *const kFLEXPropertyAttributeKeyWeak = @"W";
NSString *const kFLEXPropertyAttributeKeyGarbageCollectable = @"P";
NSString *const kFLEXPropertyAttributeKeyOldStyleTypeEncoding = @"t";
