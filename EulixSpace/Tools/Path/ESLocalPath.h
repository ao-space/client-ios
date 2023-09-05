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
//  ESLocalPath.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "NSString+ESTool.h"
#import <Foundation/Foundation.h>

@interface ESLocalPath : NSObject

+ (void)createDirectoryStandard;

@property (class, nonatomic, copy, readonly) NSString *documentDirectory;

@property (class, nonatomic, copy, readonly) NSString *cacheDirectory;

@property (class, nonatomic, copy, readonly) NSString *applicationSupportDirectory;

@end

@interface NSString (ESLocalPath)

@property (class, nonatomic, copy, readonly) NSString *defaultCacheLocation;

@property (nonatomic, copy, readonly) NSString *fullCachePath;
@property (nonatomic, copy, readonly) NSString *shareCacheFullPath;

@property (nonatomic, copy, readonly) NSString *URLEncode;

+ (NSString *)cacheLocationWithDir:(NSString *)dir;

+ (NSString *)randomCacheLocationWithName:(NSString *)name;

+ (NSString *)assetCacheLocation:(NSString *)localIdentifier name:(NSString *)name;

- (void)clearCachePath;

- (id)jsonObject;

@end
