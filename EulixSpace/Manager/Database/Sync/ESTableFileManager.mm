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
//  ESTableFileManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTableFileManager.h"
#import "ESAccountManager.h"
#import "ESBoxManager.h"
#import "ESDatabaseManager+CURD.h"
#import "ESTableFileInfo.h"
#import "ESSyncApi.h"
#import <YCEasyTool/NSArray+YCTools.h>

@interface ESTableFileManager()
@end

@implementation ESTableFileManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)trySync {
    [self trySync:nil];
}

- (void)trySync:(void (^)(NSDictionary<NSNumber *, ESTableFileInfo *> *data))onSync {
    [self sync:onSync];
}

- (void)trySyncByCreateAndModify:(void (^)(NSDictionary<NSNumber *, id> *createDict, NSDictionary<NSNumber *, id> *modifyDict))onSync {
    ESTableFileInfo *latest = [ESTableFileInfo query:nil limit:1].firstObject;
    ESSyncApi *api = [ESSyncApi new];
    [api spaceV1ApiSyncSyncedGetWithTimestamp:latest.operationAt ?: @(0)
                                     deviceId:ESBoxManager.deviceId
                                         path:nil
                            completionHandler:^(ESRspGetListRspData *output, NSError *error) {
        if (output && output.results && output.results.fileList && output.results.fileList.count > 0) {
            NSArray<ESFileInfoPub>* fileList = output.results.fileList;
            NSArray<ESTableFileInfo *> *data = [fileList yc_mapWithBlock:^id(NSUInteger idx, ESFileInfoPub *obj) {
                return [[ESTableFileInfo alloc] initWithDictionary:obj.toDictionary error:nil];
            }];
            [ESDatabaseManager.manager save:data];
        }
        
        if (onSync) {
            NSArray<ESTableFileInfo *> *data = [ESTableFileInfo query:ESAccountManager.manager.currentAccount.autoUploadPath limit:-1];
            NSMutableDictionary *createDict = NSMutableDictionary.dictionary;
            NSMutableDictionary *modifyDict = NSMutableDictionary.dictionary;

            [data enumerateObjectsUsingBlock:^(ESTableFileInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                modifyDict[obj.modifyAt] = @"";
                createDict[obj.createdAt] = @"";
            }];
            
            onSync(createDict, modifyDict);
        }
    }];
}

- (void)sync:(void (^)(NSDictionary<NSNumber *, ESTableFileInfo *> *data))onSync {
    ESTableFileInfo *latest = [ESTableFileInfo query:nil limit:1].firstObject;
    ESSyncApi *api = [ESSyncApi new];
    [api spaceV1ApiSyncSyncedGetWithTimestamp:latest.operationAt ?: @(0)
                                     deviceId:ESBoxManager.deviceId
                                         path:nil
                            completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                [self save:output.results.fileList onSync:onSync];
                            }];
}


- (void)resetSync:(void (^)(NSDictionary<NSNumber *, ESTableFileInfo *> *data))onSync {
    ESSyncApi *api = [ESSyncApi new];
    [api spaceV1ApiSyncSyncedGetWithTimestamp:@(0)
                                     deviceId:ESBoxManager.deviceId
                                         path:nil
                            completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                [ESTableFileInfo clearTable];
                                [self save:output.results.fileList onSync:onSync];
                            }];
}

- (NSDictionary *)allFileInSyncDir {
    NSArray<ESTableFileInfo *> *data = [ESTableFileInfo query:ESAccountManager.manager.currentAccount.autoUploadPath limit:-1];
    NSMutableDictionary *dict = NSMutableDictionary.dictionary;
    [data enumerateObjectsUsingBlock:^(ESTableFileInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dict[obj.createdAt] = obj;
    }];
    return dict;
}

- (void)save:(NSArray<ESFileInfoPub *> *)fileList onSync:(void (^)(NSDictionary<NSNumber *, ESTableFileInfo *> *data))onSync {
    if (fileList.count == 0) {
        if (onSync) {
            onSync([self allFileInSyncDir]);
        }
        return;
    }
    NSArray<ESTableFileInfo *> *data = [fileList yc_mapWithBlock:^id(NSUInteger idx, ESFileInfoPub *obj) {
        return [[ESTableFileInfo alloc] initWithDictionary:obj.toDictionary error:nil];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ESDatabaseManager.manager save:data];
        if (onSync) {
            onSync([self allFileInSyncDir]);
        }
    });
}

@end
