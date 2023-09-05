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
//  ESPhotoUploadManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoUploadManager.h"
#import "ESAlbumModifyModule.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESSmartPhotoAsyncManager.h"

@interface ESPhotoUploadManager () <ESTransferManagerProtocl>

@property (nonatomic, strong) NSMutableArray *uploadFinishedPicList;
@property (nonatomic, copy) dispatch_block_t delayInvokeBlock;

@end

@implementation ESPhotoUploadManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)startService {
    [[ESTransferManager manager] addTaskStatusObserver:[ESPhotoUploadManager shareInstance]];
}

- (void)notifyUploadTransferTaskComplete:(ESTransferTask *)task {
    if (task.isDownloadTask == YES || task.state != ESTransferStateCompleted) {
        return;
    }
    //是上传task

    [[ESSmartPhotoAsyncManager shared] tryAsyncData];
}

@end

