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
//  FLEXRuntimeClient.h
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXSearchToken.h"
@class FLEXMethod;

/// Accepts runtime queries given a token.
@interface FLEXRuntimeClient : NSObject

@property (nonatomic, readonly, class) FLEXRuntimeClient *runtime;

/// Called automatically when \c FLEXRuntime is first used.
/// You may call it again when you think a library has
/// been loaded since this method was first called.
- (void)reloadLibrariesList;

/// You must call this method on the main thread
/// before you attempt to call \c copySafeClassList.
+ (void)initializeWebKitLegacy;

/// Do not call unless you absolutely need all classes. This will cause
/// every class in the runtime to initialize itself, which is not common.
/// Before you call this method, call \c initializeWebKitLegacy on the main thread.
- (NSArray<Class> *)copySafeClassList;

- (NSArray<Protocol *> *)copyProtocolList;

/// An array of strings representing the currently loaded libraries.
@property (nonatomic, readonly) NSArray<NSString *> *imageDisplayNames;

/// "Image name" is the path of the bundle
- (NSString *)shortNameForImageName:(NSString *)imageName;
/// "Image name" is the path of the bundle
- (NSString *)imageNameForShortName:(NSString *)imageName;

/// @return Bundle names for the UI
- (NSMutableArray<NSString *> *)bundleNamesForToken:(FLEXSearchToken *)token;
/// @return Bundle paths for more queries
- (NSMutableArray<NSString *> *)bundlePathsForToken:(FLEXSearchToken *)token;
/// @return Class names
- (NSMutableArray<NSString *> *)classesForToken:(FLEXSearchToken *)token
                                      inBundles:(NSMutableArray<NSString *> *)bundlePaths;
/// @return A list of lists of \c FLEXMethods where
/// each list corresponds to one of the given classes
- (NSArray<NSMutableArray<FLEXMethod *> *> *)methodsForToken:(FLEXSearchToken *)token
                                                    instance:(NSNumber *)onlyInstanceMethods
                                                   inClasses:(NSArray<NSString *> *)classes;

@end
