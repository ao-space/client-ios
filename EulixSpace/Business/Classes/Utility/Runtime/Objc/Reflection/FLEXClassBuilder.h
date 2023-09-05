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
//  FLEXClassBuilder.h
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/3/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLEXIvarBuilder, FLEXMethodBase, FLEXProperty, FLEXProtocol;


#pragma mark FLEXClassBuilder
@interface FLEXClassBuilder : NSObject

@property (nonatomic, readonly) Class workingClass;

/// Begins constructing a class with the given name.
///
/// This new class will implicitly inherits from \c NSObject with \c 0 extra bytes.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name;
/// Begins constructing a class with the given name and superclass.
/// @discussion Calls \c -allocateClass:superclass:extraBytes: with \c 0 extra bytes.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name superclass:(Class)superclass;
/// Begins constructing a new class object with the given name and superclass.
/// @discussion Pass \c nil to \e superclass to create a new root class.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name superclass:(Class)superclass extraBytes:(size_t)bytes;
/// Begins constructing a new root class object with the given name and \c 0 extra bytes.
/// @discussion Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateRootClass:(NSString *)name;
/// Use this to modify existing classes. @warning You cannot add instance variables to existing classes.
+ (instancetype)builderForClass:(Class)cls;

/// @return Any methods that failed to be added.
- (NSArray<FLEXMethodBase *> *)addMethods:(NSArray<FLEXMethodBase *> *)methods;
/// @return Any properties that failed to be added.
- (NSArray<FLEXProperty *> *)addProperties:(NSArray<FLEXProperty *> *)properties;
/// @return Any protocols that failed to be added.
- (NSArray<FLEXProtocol *> *)addProtocols:(NSArray<FLEXProtocol *> *)protocols;
/// @warning Adding Ivars to existing classes is not supported and will always fail.
- (NSArray<FLEXIvarBuilder *> *)addIvars:(NSArray<FLEXIvarBuilder *> *)ivars;

/// Finalizes construction of a new class.
/// @discussion Once a class is registered, instance variables cannot be added.
/// @note Raises an exception if called on a previously registered class.
- (Class)registerClass;
/// Uses \c objc_lookupClass to determine if the working class is registered.
@property (nonatomic, readonly) BOOL isRegistered;

@end


#pragma mark FLEXIvarBuilder
@interface FLEXIvarBuilder : NSObject

/// Consider using the \c FLEXIvarBuilderWithNameAndType() macro below. 
/// @param name The name of the Ivar, such as \c \@"_value".
/// @param size The size of the Ivar. Usually \c sizeof(type). For objects, this is \c sizeof(id).
/// @param alignment The alignment of the Ivar. Usually \c log2(sizeof(type)).
/// @param encoding The type encoding of the Ivar. For objects, this is \c \@(\@encode(id)), and for others it is \c \@(\@encode(type)).
+ (instancetype)name:(NSString *)name size:(size_t)size alignment:(uint8_t)alignment typeEncoding:(NSString *)encoding;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *encoding;
@property (nonatomic, readonly) size_t   size;
@property (nonatomic, readonly) uint8_t  alignment;

@end


#define FLEXIvarBuilderWithNameAndType(nameString, type) [FLEXIvarBuilder \
    name:nameString \
    size:sizeof(type) \
    alignment:log2(sizeof(type)) \
    typeEncoding:@(@encode(type)) \
]
