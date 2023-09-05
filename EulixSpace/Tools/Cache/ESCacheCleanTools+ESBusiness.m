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
//  ESCacheCleanTools+ESBusiness.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCacheCleanTools+ESBusiness.h"
#import "ESLocalPath.h"
#import "ESAppletManager+ESCache.h"
#import "ESSmarPhotoCacheManager.h"
#import <SDWebImage/SDImageCache.h>
#import "ESFileDefine.h"
#import "ESCacheInfoDBManager.h"

@implementation ESBusinessCacheInfoItem
- (void)setSize:(NSInteger)size {
    _size = size;
    _sizeString = FileSizeString(_size, YES);
}

@end

@implementation ESCacheCleanTools (ESBusiness)

+ (NSString *)fileCachePath {
    NSString *documentDirectory = ESLocalPath.documentDirectory;
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [NSString stringWithFormat:@"%@/%@/", documentDirectory, @"eulix.xyz"];
    return path;
}

+ (NSString *)contactCachePath {
    NSString *path = [[ESAppletManager shared] cacheFileDocument];
    return path;
}

+ (NSString *)smartPhotoPath {
    NSString *path = [ESSmarPhotoCacheManager defaultCacheLocation];
    return path;
}

+ (void)businessCacheSizeWithCompletion:(void (^)(NSString *totalSize, NSArray<ESBusinessCacheInfoItem *> *cacheInfoList))completion {
    __block ESBusinessCacheInfoItem *fileCacheInfoItem = [ESBusinessCacheInfoItem new];
    __block ESBusinessCacheInfoItem *appletCacheInfoItem = [ESBusinessCacheInfoItem new];
    __block ESBusinessCacheInfoItem *smartPhotoCacheInfoItem = [ESBusinessCacheInfoItem new];
    __block ESBusinessCacheInfoItem *sdCacheInfoItem = [ESBusinessCacheInfoItem new];
    __block ESBusinessCacheInfoItem *tempCacheInfoItem = [ESBusinessCacheInfoItem new];

//    NSString *documentDirectory = ESLocalPath.documentDirectory;
//    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    __block NSInteger totalSize = 0;
    dispatch_group_t group = dispatch_group_create();
    NSString *filePath = [self fileCachePath];
    dispatch_group_enter(group);
    [self getFileSize:filePath
           completion:^(NSInteger size) {
               totalSize += size;
        fileCacheInfoItem.size = size;
        fileCacheInfoItem.sizeString = FileSizeString(size, YES);
        fileCacheInfoItem.cachePath = filePath;
        fileCacheInfoItem.caheType = ESBusinessCacheInfoTypeFile;
               dispatch_group_leave(group);
           }];


    NSString *appletPath = [self contactCachePath];
    dispatch_group_enter(group);
    [self getFileSize:appletPath
           completion:^(NSInteger size) {
               totalSize += size;
                appletCacheInfoItem.size = size;
                appletCacheInfoItem.sizeString = FileSizeString(size, YES);
                appletCacheInfoItem.cachePath = appletPath;
                appletCacheInfoItem.caheType = ESBusinessCacheInfoTypeApplet;
               dispatch_group_leave(group);
           }];
  
    dispatch_group_enter(group);
    NSString *smartPhotoPath = [self smartPhotoPath];
    [self getFileSize:smartPhotoPath
           completion:^(NSInteger size) {
               totalSize += size;
                smartPhotoCacheInfoItem.size = size;
                smartPhotoCacheInfoItem.sizeString = FileSizeString(size, YES);
                smartPhotoCacheInfoItem.cachePath = smartPhotoPath;
                smartPhotoCacheInfoItem.caheType = ESBusinessCacheInfoTypePhoto;
               dispatch_group_leave(group);
           }];

    dispatch_group_enter(group);
    NSString *tmpDirectory = NSTemporaryDirectory();
    [self getFileSize:tmpDirectory
           completion:^(NSInteger size) {
               totalSize += size;
        tempCacheInfoItem.size = size;
        tempCacheInfoItem.sizeString = FileSizeString(size, YES);
        tempCacheInfoItem.cachePath = tmpDirectory;
        tempCacheInfoItem.caheType = ESBusinessCacheInfoTypeOther;
               dispatch_group_leave(group);
           }];
    
    dispatch_group_enter(group);
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger size) {
        totalSize += size;
        sdCacheInfoItem.size = size;
        sdCacheInfoItem.sizeString = FileSizeString(size, YES);
        sdCacheInfoItem.cachePath = [SDImageCache defaultDiskCacheDirectory];
        sdCacheInfoItem.caheType = ESBusinessCacheInfoTypeSDImageCache;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
           NSInteger fileCachePlusSize = [[ESCacheInfoDBManager shared] cacheSizeByType:ESBusinessCacheInfoTypeFile];
            fileCacheInfoItem.size += fileCachePlusSize;
            tempCacheInfoItem.size += sdCacheInfoItem.size;
            
            completion(FileSizeString(totalSize, YES), @[fileCacheInfoItem, smartPhotoCacheInfoItem,  appletCacheInfoItem, tempCacheInfoItem]);
        }
    });
}

+ (void)clearCacheByType:(ESBusinessCacheInfoType)type
              completion:(dispatch_block_t)completion {
    if (type == ESBusinessCacheInfoTypeOther) {
        NSString *tmpDirectory = NSTemporaryDirectory();
        [[NSFileManager.defaultManager contentsOfDirectoryAtPath:tmpDirectory error:nil] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [NSFileManager.defaultManager removeItemAtPath:[tmpDirectory stringByAppendingPathComponent:obj] error:nil];
        }];
        
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{

        }];
        
        if(completion) {
            completion();
        }
        return;
    }
    
    if (type == ESBusinessCacheInfoTypeApplet) {
        NSString *tmpDirectory = [[ESAppletManager shared] cacheFileDocument];
        [[NSFileManager.defaultManager contentsOfDirectoryAtPath:tmpDirectory error:nil] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj,
                                                                                                                      NSUInteger idx,
                                                                                                                      BOOL *_Nonnull stop) {
            [NSFileManager.defaultManager removeItemAtPath:[tmpDirectory stringByAppendingPathComponent:obj] error:nil];
        }];
        if(completion) {
            completion();
        }
        return;
    }
    
    if (type == ESBusinessCacheInfoTypeFile) {
        NSString *filePath = [self fileCachePath];
        [[NSFileManager.defaultManager contentsOfDirectoryAtPath:filePath error:nil] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj,
                                                                                                                  NSUInteger idx,
                                                                                                                  BOOL *_Nonnull stop) {
            NSError *error;
            [NSFileManager.defaultManager removeItemAtPath:[filePath stringByAppendingPathComponent:obj] error:&error];
        }];
        
        NSArray<ESCacheInfoItem *> *fileItems = [[ESCacheInfoDBManager shared] getCaheInfoFromDBType:ESBusinessCacheInfoTypeFile];
        [fileItems enumerateObjectsUsingBlock:^(ESCacheInfoItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *localPathString = [NSString stringWithFormat:@"%@/%@",cachesPath, item.path];
            
            NSError *error;
            [NSFileManager.defaultManager removeItemAtPath:localPathString error:&error];
        }];
        
        [[ESCacheInfoDBManager shared] deleteCacheDBDataByType:ESBusinessCacheInfoTypeFile];

        if(completion) {
            completion();
        }
        return;
    }
    
    if (type == ESBusinessCacheInfoTypePhoto) {
        NSString *smartPhotoPath = [self smartPhotoPath];
        [[NSFileManager.defaultManager contentsOfDirectoryAtPath:smartPhotoPath error:nil] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj,
                                                                                                                        NSUInteger idx,
                                                                                                                        BOOL *_Nonnull stop) {
            [NSFileManager.defaultManager removeItemAtPath:[smartPhotoPath stringByAppendingPathComponent:obj] error:nil];
        }];
        
        NSArray<ESCacheInfoItem *> *items = [[ESCacheInfoDBManager shared] getCaheInfoFromDBType:ESBusinessCacheInfoTypePhoto];
        [items enumerateObjectsUsingBlock:^(ESCacheInfoItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *localPathString = [NSString stringWithFormat:@"%@/%@",cachesPath, item.path];
            
            NSError *error;
            [NSFileManager.defaultManager removeItemAtPath:localPathString error:&error];
        }];
        
        
        [[ESCacheInfoDBManager shared] deleteCacheDBDataByType:ESBusinessCacheInfoTypePhoto];
        if(completion) {
            completion();
        }
        return;
    }
    
    if (type == ESBusinessCacheInfoTypeSDImageCache) {
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            if(completion) {
                completion();
            }
        }];
      
        return;
    }
}

@end



