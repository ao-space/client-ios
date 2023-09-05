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
//  ESTransferProgress.h
//  EulixSpace
//
//  Created by dazhou on 2023/3/2.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESTransferProgress : NSObject

// 这次写入的数量
@property (nonatomic, assign, readonly) int64_t bytes;
// 已传输的数量
@property (nonatomic, assign, readonly) int64_t totalBytes;
// 文件的总大小
@property (nonatomic, assign, readonly) int64_t totalBytesExpected;
// 传输进度
@property (nonatomic, readonly) CGFloat progress;


- (BOOL)onUpdateProgress:(int64_t)bytes totalBytes:(int64_t)totalBytes totalBytesExpected:(int64_t)totalBytesExpected;

- (void)addFragmentSpeed:(float)speed;
// 获取当前任务的传输速度
- (NSString *)getTaskSpeed:(int)concurrent;

@end

NS_ASSUME_NONNULL_END
