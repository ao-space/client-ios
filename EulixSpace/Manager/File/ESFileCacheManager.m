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
//  ESFileCacheManager.m
//  EulixSpace
//
//  Created by qu on 2021/9/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//
#import "ESFileCacheManager.h"
#import "ESDatabaseManager.h"
#import "ESFileDataList.h"
#import <YCEasyTool/NSArray+YCTools.h>

@interface ESFileCacheManager ()
@end

@implementation ESFileCacheManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)saveFileList:(NSArray *)fileDataArray {
    if (fileDataArray.count == 0) {
        return YES;
    }
    NSMutableArray *tmp = [fileDataArray yc_mapWithBlock:^id(NSUInteger idx, id obj) {
        return [[ESFileDataList alloc] initWithDictionary:[obj toDictionary] error:nil];
    }];

    BOOL result = [[ESDatabaseManager manager] insertObjects:tmp into:kESDatabaseFilelist];
    return result;
}

- (NSArray<ESFileInfoPub *> *)getFileListDataCategory:(NSString *)category {
    NSArray *array = [[ESDatabaseManager manager] getFilesByUids:kESDatabaseFilelist withClass:ESFileDataList.class category:category];

    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (ESFileDataList *info in array) {
        ESFileInfoPub *model = [[ESFileInfoPub alloc] initWithDictionary:info.toDictionary error:nil];
        [tmp addObject:model];
    }
    return tmp;
}

- (BOOL)deleteObjectsFromTable {
    BOOL result = [[ESDatabaseManager manager] deleteObjectsFromTable:kESDatabaseFilelist];

    return result;
}

@end
