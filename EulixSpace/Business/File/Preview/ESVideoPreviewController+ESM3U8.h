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
//  ESVideoPreviewController+ESM3U8.h
//  EulixSpace
//
//  Created by KongBo on 2022/12/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVideoPreviewController.h"

NS_ASSUME_NONNULL_BEGIN

//VOD-200 是可以播放， VOD-4001 是H265编码不支持，

typedef void (^ESCheckVODSupportCompletionBlock)(NSString *uuid, BOOL support, NSError * _Nullable error);

typedef void (^ESFetchM3U8CompletionBlock)(NSString *uuid, NSString * _Nullable lanM3u8Path,  NSString * _Nullable wanM3u8Path, NSError * _Nullable error);

@interface ESVideoPreviewController (ESM3U8)

- (void)checkVODSupportWithUuid:(NSString *)uuid compeltionBlock:(ESCheckVODSupportCompletionBlock)compeltionBlock;

- (void)fetchM3U8FilesWithUuid:(NSString *)uuid retyCount:(NSInteger)count compeltionBlock:(ESFetchM3U8CompletionBlock)compeltionBlock;

@end

NS_ASSUME_NONNULL_END
