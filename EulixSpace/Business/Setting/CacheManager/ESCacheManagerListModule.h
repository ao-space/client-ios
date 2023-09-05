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
//  ESCacheManagerListModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseTableListModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESCacheManagerListModule : ESBaseTableListModule

@property (nonatomic, copy) dispatch_block_t selectedUpdateBlock;
@property (nonatomic, copy) dispatch_block_t cleanFinishBlock;

@property (nonatomic, readonly) NSInteger selectedCount;
@property (nonatomic, readonly) NSString *canCleanCacheSize;

- (void)loadCacheData:(NSArray *)cacheInfoList totalSize:(NSString *)totalSize;
- (void)cleanSelectedCache:(void(^)(NSString *cleanSize))completionBlock;
- (void)cleanAllCache:(NSString *)cleanSize block:(void(^)(NSString *cleanSize))completionBlock;

@end

NS_ASSUME_NONNULL_END
