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
//  FLEXObjectRef.h
//  FLEX
//
//  Created by Tanner Bennett on 7/24/18.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLEXObjectRef : NSObject

/// Reference an object without affecting its lifespan or or emitting reference-counting operations.
+ (instancetype)unretained:(__unsafe_unretained id)object;
+ (instancetype)unretained:(__unsafe_unretained id)object ivar:(NSString *)ivarName;

/// Reference an object and control its lifespan.
+ (instancetype)retained:(id)object;
+ (instancetype)retained:(id)object ivar:(NSString *)ivarName;

/// Reference an object and conditionally choose to retain it or not.
+ (instancetype)referencing:(__unsafe_unretained id)object retained:(BOOL)retain;
+ (instancetype)referencing:(__unsafe_unretained id)object ivar:(NSString *)ivarName retained:(BOOL)retain;

+ (NSArray<FLEXObjectRef *> *)referencingAll:(NSArray *)objects retained:(BOOL)retain;
/// Classes do not have a summary, and the reference is just the class name.
+ (NSArray<FLEXObjectRef *> *)referencingClasses:(NSArray<Class> *)classes;

/// For example, "NSString 0x1d4085d0" or "NSLayoutConstraint _object"
@property (nonatomic, readonly) NSString *reference;
/// For instances, this is the result of -[FLEXRuntimeUtility summaryForObject:]
/// For classes, there is no summary.
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly, unsafe_unretained) id object;

/// Retains the referenced object if it is not already retained
- (void)retainObject;
/// Releases the referenced object if it is already retained
- (void)releaseObject;

@end
