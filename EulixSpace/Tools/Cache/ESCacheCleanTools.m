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
//  ESCacheCleanTools.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCacheCleanTools.h"
#import "ESFileDefine.h"
#import "ESLocalPath.h"
#import <SDWebImage/SDImageCache.h>

@implementation ESCacheCleanTools

+ (NSArray *)subDoc {
    return @[@"eulix.xyz", @"Logs"];
}

+ (NSArray *)subCache {
    return @[@"com.apple.WebKit.GPU", @"com.apple.WebKit.WebContent"];
}

+ (void)clearAllCache {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;

    [self.subDoc enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/", documentDirectory, obj];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    }];
    [self.subCache enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/", cachesDirectory, obj];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    }];
    NSString *tmpDirectory = NSTemporaryDirectory();
    [[NSFileManager.defaultManager contentsOfDirectoryAtPath:tmpDirectory error:nil] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [NSFileManager.defaultManager removeItemAtPath:[tmpDirectory stringByAppendingPathComponent:obj] error:nil];
    }];

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{

    }];
}

+ (void)clearCacheForTest {
    [self clearAllCache];
    NSArray * cacheArr = @[@""];
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    [cacheArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/", cachesDirectory, obj];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    }];
}

+ (void)cacheSizeWithCompletion:(void (^)(NSString *size))completion {
    NSString *documentDirectory = ESLocalPath.documentDirectory;
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    __block NSInteger totalSize = 0;
    dispatch_group_t group = dispatch_group_create();
    [self.subDoc enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/", documentDirectory, obj];
        dispatch_group_enter(group);
        [self getFileSize:path
               completion:^(NSInteger size) {
                   totalSize += size;
                   dispatch_group_leave(group);
               }];
    }];

    [self.subCache enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/", cachesDirectory, obj];
        dispatch_group_enter(group);
        [self getFileSize:path
               completion:^(NSInteger size) {
                   totalSize += size;
                   dispatch_group_leave(group);
               }];
    }];
    dispatch_group_enter(group);
    NSString *tmpDirectory = NSTemporaryDirectory();
    [self getFileSize:tmpDirectory
           completion:^(NSInteger size) {
               totalSize += size;
               dispatch_group_leave(group);
           }];

    dispatch_group_enter(group);
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger size) {
        totalSize += size;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(FileSizeString(totalSize, YES));
        }
    });
}

+ (void)getFileSize:(NSString *)directoryPath completion:(void (^)(NSInteger size))completion {
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        if (completion) {
            completion(0);
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 获取文件夹下所有的子路径,包含子路径的子路径
        NSArray *subPaths = [mgr subpathsAtPath:directoryPath];

        NSInteger totalSize = 0;

        for (NSString *subPath in subPaths) {
            // 获取文件全路径
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];

            // 判断隐藏文件
            if ([filePath containsString:@".DS"])
                continue;

            // 判断是否文件夹
            BOOL isDirectory;
            // 判断文件是否存在,并且判断是否是文件夹
            BOOL isExist = [mgr fileExistsAtPath:filePath isDirectory:&isDirectory];
            if (!isExist || isDirectory)
                continue;

            // 获取文件属性
            // attributesOfItemAtPath:只能获取文件尺寸,获取文件夹不对,
            NSDictionary *attr = [mgr attributesOfItemAtPath:filePath error:nil];

            // 获取文件尺寸
            NSInteger fileSize = [attr fileSize];

            totalSize += fileSize;
        }

        // 计算完成回调(为了避免计算大的文件夹,比较耗时,如果直接返回结果,控制器跳转的时候回产生卡顿,所以采用block回调的方式)
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(totalSize);
            }
        });
    });
}

+ (void)reset {
    [self clearAllCache];
    [self clearContentsInDirectory:ESLocalPath.cacheDirectory];
    [self clearContentsInDirectory:ESLocalPath.documentDirectory];
}

+ (void)clearContentsInDirectory:(NSString *)directory {
    NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:directory error:nil];
    [contents enumerateObjectsUsingBlock:^(NSString *_Nonnull obj,
                                           NSUInteger idx,
                                           BOOL *_Nonnull stop) {
        NSString *path = [directory stringByAppendingPathComponent:obj];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    }];
}

@end
