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
//  ESFileInfoPub+ESTool.h
//  EulixSpace
//
//  Created by dazhou on 2023/5/11.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESFileInfoPub.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESFileInfoPub (ESTool)

/**
 Get save dir, not mean the file already downloaded.
 */
- (NSString *)getOriginalFileSaveDir;

/**
 Get save path, not mean the file already downloaded.
 */
- (NSString *)getOriginalFileSavePath;


/**
 If a non-nil value is returned, it means that the file data exists locally
 */
- (NSString *)localOriginalFilePath;

/**
 Determine whether there is data for this file locally
 */
- (BOOL)hasLocalOriginalFile;

+ (NSString *)defaultCacheDir;

+ (NSString *)shareCacheDir;

@end

NS_ASSUME_NONNULL_END
