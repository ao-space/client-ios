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
//  FLEXProtocolBuilder.h
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/4/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLEXProperty, FLEXProtocol, Protocol;

@interface FLEXProtocolBuilder : NSObject

/// Begins to construct a new protocol with the given name.
/// @discussion You must register the protocol with the
/// \c registerProtocol method before you can use it.
+ (instancetype)allocateProtocol:(NSString *)name;

/// Adds a property to a protocol.
/// @param property The property to add.
/// @param isRequired Whether the property is required to implement the protocol.
- (void)addProperty:(FLEXProperty *)property isRequired:(BOOL)isRequired;
/// Adds a property to a protocol.
/// @param selector The selector of the method to add.
/// @param typeEncoding The type encoding of the method to add.
/// @param isRequired Whether the method is required to implement the protocol.
/// @param isInstanceMethod \c YES if the method is an instance method, \c NO if it is a class method.
- (void)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
       isRequired:(BOOL)isRequired
 isInstanceMethod:(BOOL)isInstanceMethod;
/// Makes the recieving protocol conform to the given protocol.
- (void)addProtocol:(Protocol *)protocol;

/// Registers and returns the recieving protocol, which was previously under construction.
- (FLEXProtocol *)registerProtocol;
/// Whether the protocol is still under construction or already registered.
@property (nonatomic, readonly) BOOL isRegistered;

@end
