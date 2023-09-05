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
//  ESSmartPhotoAsyncManager.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESSmartPhotoAsyncType) {
    ESSmartPhotoAsyncTypeFirstLoad, // 第一次加载
    ESSmartPhotoAsyncTypeIncrement, //增量更新
};

@protocol ESSmartPhotoAsyncUpdateProtocol <NSObject>

- (void)asyncUpdate:(ESSmartPhotoAsyncType)type asyncFinish:(BOOL)asyncFinish hasNewContent:(BOOL)hasNewContent;

@end

NS_ASSUME_NONNULL_BEGIN
typedef void (^ESSmartPhotoAsyncBlock)(BOOL finish, BOOL hasCount);

@interface ESSmartPhotoAsyncManager : NSObject

@property (nonatomic, copy) ESSmartPhotoAsyncBlock updateBlock;
@property (nonatomic, readonly)NSOperationQueue *picRequestQueue;
@property (nonatomic, readonly)dispatch_queue_t requestHandleQueue;

+ (instancetype)shared;

+ (instancetype)newServiceInstance;
- (void)startService;
- (void)resetService;

- (void)tryAsyncData;

- (void)addAsyncUpdateObserver:(id)observer;
- (void)forceReloadData;

- (BOOL)isFirstLoaded;
- (void)resetFirstLoaded;

- (void)loadAlbumsInfo:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
