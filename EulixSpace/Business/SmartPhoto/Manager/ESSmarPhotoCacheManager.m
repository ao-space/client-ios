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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmarPhotoCacheManager.h"
#import  <SSZipArchive/SSZipArchive.h>
#import "ESAccountInfoStorage.h"

@implementation ESSmarPhotoCacheManager

+ (NSString * _Nullable)unZipCachePath:(NSString *)picZipCachePath
                         pic:(ESPicModel *)pic {
    NSString *picCachePath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
    if ([[NSFileManager defaultManager] fileExistsAtPath:picCachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:picCachePath error:nil];
    }
    NSString *picCacheDir = [ESSmarPhotoCacheManager cacheDirWithPic:pic];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:picCacheDir]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:picCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
    NSError *error;
    BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:picZipCachePath toDestination:picCacheDir overwrite:YES password:nil error:&error];
    if (unZipSuccess) {
        NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:picCacheDir];
        if (fileOrDocs.count > 0) {
            __block NSString *subPath;
            [fileOrDocs enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![path containsString:@"zip"]) {
                    subPath = path;
                    *stop = YES;
                }
            }];
            if (subPath.length <= 0) {
                return nil;
            }
            NSString *fullPath = [picCacheDir stringByAppendingPathComponent:ESSafeString(subPath)];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:picCachePath error:&error];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picZipCachePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:picZipCachePath error:nil];
            }
            if (!error) {
                return picCachePath;
            }
        }
    }
    return nil;
}

+ (NSString *)cacheEncryptPathWithPic:(ESPicModel *)pic {
    NSString *fullPath = [self cachePathWithPic:pic];
    return [fullPath stringByAppendingString:@".encrypt" ];
}

+ (NSString *)cacheDirWithPic:(ESPicModel *)pic {
    NSString *picName = pic.name;
    if (pic.name.length <= 0) {
        picName = [NSString stringWithFormat:@"%@.png",pic.uuid];
    }
    NSString *fullPath = [self cacheLocationWithSubDir:pic.uuid name:pic.name];
    return [fullPath stringByDeletingLastPathComponent];
}

+ (NSString *)cachePathWithPic:(ESPicModel *)pic {
    NSString *picName = pic.name;
    if (pic.name.length <= 0) {
        picName = [NSString stringWithFormat:@"%@.png",pic.uuid];
    }
    
    NSString *fullPath = [self cacheLocationWithSubDir:pic.uuid name:picName];
    return fullPath;
}

+ (NSString *)compressCachePathWithPic:(ESPicModel *)pic {
    NSString *picName = pic.name;
    if (pic.name.length <= 0) {
        picName = [NSString stringWithFormat:@"%@.png",pic.uuid];
    }
    NSString *fullPath = [self cacheLocationWithSubDir:pic.uuid name:[NSString stringWithFormat:@"compress_%@", picName]];
    return fullPath;
}

+ (NSString *)cacheZipPathWithPic:(ESPicModel *)pic {
    NSString *fullPath = [self cachePathWithPic:pic];
    return [fullPath stringByAppendingString:@".zip" ];
}

#pragma mark 批量处理

+ (void)unZipCachePath:(NSString *)picDayZipCachePath
               picList:(NSArray<ESPicModel *> *)picList {
    NSString *picsUnZipDir = [picDayZipCachePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:picsUnZipDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:picsUnZipDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:picDayZipCachePath toDestination:picsUnZipDir overwrite:YES password:nil error:&error];
    ESDLog(@"#### download success unZipSuccess picDayZipCachePath: %@  -- error: %@",  picDayZipCachePath, error);
    if (!unZipSuccess) {
        return;
    }
    
    NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:picsUnZipDir];
    if (fileOrDocs.count > 0) {
        [picList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *picCachePath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
            if ([fileOrDocs containsObject:ESSafeString(pic.uuid)]) {
                NSString *fullPath = [picsUnZipDir stringByAppendingPathComponent:ESSafeString(pic.uuid)];
                NSError *error;
                BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:picCachePath];
                if (!exist) {
                    [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:picCachePath error:&error];
                }
                ESDLog(@"#### download success %@  %d -- error: %@",picCachePath, exist, error);
            }
        }];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:picDayZipCachePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:picDayZipCachePath error:nil];
        }
    }
}

+ (void)unZipCompressPicCachePath:(NSString *)picDayZipCachePath
                          picList:(NSArray<ESPicModel *> *)picList {
    NSString *picsUnZipDir = [picDayZipCachePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:picsUnZipDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:picsUnZipDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:picDayZipCachePath toDestination:picsUnZipDir overwrite:YES password:nil error:&error];
    ESDLog(@"#### download success unZipSuccess picDayZipCachePath: %@  -- error: %@",  picDayZipCachePath, error);
    if (!unZipSuccess) {
        return;
    }
    
    NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:picsUnZipDir];
    if (fileOrDocs.count > 0) {
        [picList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *picCachePath = [ESSmarPhotoCacheManager compressCachePathWithPic:pic];
            if ([fileOrDocs containsObject:ESSafeString(pic.uuid)]) {
                NSString *fullPath = [picsUnZipDir stringByAppendingPathComponent:ESSafeString(pic.uuid)];
                NSError *error;
                BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:picCachePath];
                if (!exist) {
                    [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:picCachePath error:&error];
                }
                ESDLog(@"#### download success %@  %d -- error: %@",picCachePath, exist, error);
            }
        }];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:picDayZipCachePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:picDayZipCachePath error:nil];
        }
    }
}

+ (NSString *)cacheZipPathWithDate:(NSString *)day {
    NSString *fullPath = [self cacheLocationWithSubDir:day name:day];
    return [fullPath stringByAppendingString:@".zip" ];
}

+ (NSString *)cacheZipPathWithAlbumId:(NSString *)albumId {
    NSString *fullPath = [self cacheLocationWithSubDir:albumId name:albumId];
    return [fullPath stringByAppendingString:@".zip" ];
}

+ (NSString *)customDir {
    return [NSString stringWithFormat:@"%@-%@",@"smart_photo", ESSafeString([ESAccountInfoStorage userUniqueKey])];
}

+ (void)clearCache {
    NSString *dir = [self defaultCacheLocation];
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil].count > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}
@end
