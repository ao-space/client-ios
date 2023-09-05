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
//  ESCacheCleanTools+ESBusiness.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCacheCleanTools.h"
#import "ESCacheInfoItem.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESBusinessCacheInfoItem : NSObject

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, copy) NSString *sizeString;

@property (nonatomic, copy) NSString *cachePath;
@property (nonatomic, assign) ESBusinessCacheInfoType caheType;

@end


@interface ESCacheCleanTools (ESBusiness)

+ (void)businessCacheSizeWithCompletion:(void (^)(NSString *totalSize, NSArray<ESBusinessCacheInfoItem *> *cacheInfoList))completion;

+ (void)clearCacheByType:(ESBusinessCacheInfoType)type completion:(dispatch_block_t)completion;

+ (NSString *)fileCachePath;

@end

NS_ASSUME_NONNULL_END
