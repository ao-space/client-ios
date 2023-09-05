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
//  ESMiniProgramManager+ESCache.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletManager+ESCache.h"
#import  <SSZipArchive/SSZipArchive.h>
#import "ESUserDefaults.h"
#import "ESBoxManager.h"

static NSString * const ESCacheFileDocumentName = @"ESAppletCache";

@implementation ESAppletManager (ESCache)

- (NSString * _Nullable)getCacheZipFilePathWithAppleId:(NSString *)appletId {
    if (appletId.length <= 0) {
        NSAssert(appletId.length <= 0, @"invailed apple id!");
        return nil;
    }
    NSString *fileName = [NSString stringWithFormat: @"%@.zip", appletId];
    return [[self cacheFileDocument] stringByAppendingPathComponent:fileName];
}

- (NSString * _Nullable)getCacheUnzipFilePathWithAppleId:(NSString *)appletId {
    if (appletId.length <= 0) {
        NSAssert(appletId.length <= 0, @"invailed apple id!");
        return nil;
    }
    return [[self cacheFileDocument] stringByAppendingPathComponent:appletId];
}

- (NSString * _Nullable)getCacheAppletIndexPageDirWithAppletId:(NSString *)appletId {
    if (appletId.length <= 0) {
        NSAssert(appletId.length <= 0, @"invailed apple id!");
        return nil;
    }
    NSString *indexFilePath = [self getCacheAppletIndexPageWithAppletId:appletId];
    NSString *indexFileDir = [indexFilePath stringByDeletingLastPathComponent];
    BOOL isDir;
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:indexFileDir isDirectory:&isDir];
    
    return  (fileExist && isDir) ? indexFileDir : nil;
}

- (NSString * _Nullable)getCacheAppletIndexPageWithAppletId:(NSString *)appletId {
    if (appletId.length <= 0) {
        NSAssert(appletId.length <= 0, @"invailed apple id!");
        return nil;
    }
    NSString *unZipPath = [self getCacheUnzipFilePathWithAppleId:appletId];
    NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:unZipPath];
    
    if (fileOrDocs.count <= 0) {
        return nil;
    }
     __block NSString *indexFileSubpath;
    [fileOrDocs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:@"index.html"]) {
            indexFileSubpath = obj;
            *stop = YES;
        }
    }];
   
    NSString *indexFilePath = [unZipPath stringByAppendingPathComponent:ESSafeString(indexFileSubpath)];
    if (![[NSFileManager defaultManager] fileExistsAtPath:indexFilePath]) {
        return nil;
    }
    return indexFilePath;
}

- (NSString *)cacheFileDocument {
    NSString *basePath = [[self applicationDocumentDirectory] stringByAppendingPathComponent:ESBoxManager.activeBox.uniqueKey];
    return [basePath stringByAppendingPathComponent:ESCacheFileDocumentName];
}

- (NSString *)applicationDocumentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)addAppletCacheWithId:(NSString *)appletId
                appletVerion:(NSString *)appletVersion
            downloadFilePath:(NSString *)filePath {
    
    NSString *cacheFileDocument = [self cacheFileDocument];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFileDocument]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFileDocument
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    NSString *unzipPath = [self getCacheUnzipFilePathWithAppleId:appletId];
    if (unzipPath.length <= 0) {
        return NO;
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:unzipPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:filePath toDestination:unzipPath];
    if (unZipSuccess) {
        [[ESUserDefaults standardUserDefaults] setObject:ESSafeString(appletVersion) forKey:ESSafeString(appletId)];
    }
    return unZipSuccess;
}

- (BOOL)removeAppletCacheWithId:(NSString *)appletId {
    NSString *unzipPath = [self getCacheUnzipFilePathWithAppleId:appletId];
    if (unzipPath.length <= 0) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:unzipPath]) {
        return NO;
    }
    NSError *removeError;
    [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:&removeError];
    if (removeError == nil) {
        // 清空安装版本的缓存
        [[ESUserDefaults standardUserDefaults] setObject:nil forKey:ESSafeString(appletId)];

    }
    return removeError == nil;
}

- (NSString * _Nullable)currentInstalledAppletVersionWithId:(NSString *)appletId {
    if (appletId.length <= 0) {
        return nil;
    }
    
    return [[ESUserDefaults standardUserDefaults] objectForKey:appletId];
}
@end
