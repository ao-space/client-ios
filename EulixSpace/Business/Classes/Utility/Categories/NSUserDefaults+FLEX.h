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
//  NSUserDefaults+FLEX.h
//  FLEX
//
//  Created by Tanner on 3/10/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

// Only use these if the getters and setters aren't good enough for whatever reason
extern NSString * const kFLEXDefaultsToolbarTopMarginKey;
extern NSString * const kFLEXDefaultsiOSPersistentOSLogKey;
extern NSString * const kFLEXDefaultsHidePropertyIvarsKey;
extern NSString * const kFLEXDefaultsHidePropertyMethodsKey;
extern NSString * const kFLEXDefaultsHidePrivateMethodsKey;
extern NSString * const kFLEXDefaultsShowMethodOverridesKey;
extern NSString * const kFLEXDefaultsHideVariablePreviewsKey;
extern NSString * const kFLEXDefaultsNetworkObserverEnabledKey;
extern NSString * const kFLEXDefaultsNetworkHostDenylistKey;
extern NSString * const kFLEXDefaultsDisableOSLogForceASLKey;
extern NSString * const kFLEXDefaultsRegisterJSONExplorerKey;

/// All BOOL preferences are NO by default
@interface NSUserDefaults (FLEX)

- (void)flex_toggleBoolForKey:(NSString *)key;

@property (nonatomic) double flex_toolbarTopMargin;

@property (nonatomic) BOOL flex_networkObserverEnabled;
// Not actually stored in defaults, but written to a file
@property (nonatomic) NSArray<NSString *> *flex_networkHostDenylist;

/// Whether or not to register the object explorer as a JSON viewer on launch
@property (nonatomic) BOOL flex_registerDictionaryJSONViewerOnLaunch;

/// The last selected screen in the network observer
@property (nonatomic) NSInteger flex_lastNetworkObserverMode;

/// Disable os_log and re-enable ASL. May break Console.app output.
@property (nonatomic) BOOL flex_disableOSLog;
@property (nonatomic) BOOL flex_cacheOSLogMessages;

@property (nonatomic) BOOL flex_explorerHidesPropertyIvars;
@property (nonatomic) BOOL flex_explorerHidesPropertyMethods;
@property (nonatomic) BOOL flex_explorerHidesPrivateMethods;
@property (nonatomic) BOOL flex_explorerShowsMethodOverrides;
@property (nonatomic) BOOL flex_explorerHidesVariablePreviews;

@end
