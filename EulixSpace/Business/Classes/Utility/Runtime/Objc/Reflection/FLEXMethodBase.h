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
//  FLEXMethodBase.h
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>


/// A base class for methods which encompasses those that may not
/// have been added to a class yet. Useful on it's own for adding
/// methods to a class, or building a new class from the ground up.
@interface FLEXMethodBase : NSObject {
@protected
    SEL      _selector;
    NSString *_name;
    NSString *_typeEncoding;
    IMP      _implementation;
    
    NSString *_flex_description;
}

/// Constructs and returns an \c FLEXSimpleMethod instance with the given name, type encoding, and implementation.
+ (instancetype)buildMethodNamed:(NSString *)name withTypes:(NSString *)typeEncoding implementation:(IMP)implementation;

/// The selector of the method.
@property (nonatomic, readonly) SEL      selector;
/// The selector string of the method.
@property (nonatomic, readonly) NSString *selectorString;
/// Same as selectorString.
@property (nonatomic, readonly) NSString *name;
/// The type encoding of the method.
@property (nonatomic, readonly) NSString *typeEncoding;
/// The implementation of the method.
@property (nonatomic, readonly) IMP      implementation;

/// For internal use
@property (nonatomic) id tag;

@end
