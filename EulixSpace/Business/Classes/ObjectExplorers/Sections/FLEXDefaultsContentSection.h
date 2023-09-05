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
//  FLEXDefaultsContentSection.h
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXCollectionContentSection.h"
#import "FLEXObjectInfoSection.h"

@interface FLEXDefaultsContentSection : FLEXCollectionContentSection <FLEXObjectInfoSection>

/// Uses \c NSUserDefaults.standardUserDefaults
+ (instancetype)standard;
+ (instancetype)forDefaults:(NSUserDefaults *)userDefaults;

/// Whether or not to filter out keys not present in the app's user defaults file.
///
/// This is useful for filtering out some useless keys that seem to appear
/// in every app's defaults but are never actually used or touched by the app.
/// Only applies to instances using \c NSUserDefaults.standardUserDefaults.
/// This is the default for any instance using \c standardUserDefaults, so
/// you must opt-out in those instances if you don't want this behavior.
@property (nonatomic) BOOL onlyShowKeysForAppPrefs;

@end
