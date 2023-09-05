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
//  ESDiskCacheManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskCacheManager.h"

@implementation ESDiskCacheManager

+ (NSString *)cacheEncryptLocationWithPath:(NSString *)path {
    return [ESSafeString(path) stringByAppendingString:@".encrypt" ];
}

+ (NSString *)cacheLocationWithSubDir:(NSString *)subDir name:(NSString *)name {
    NSString *pathDir = [self cacheLocationWithSubDirPath:subDir];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", pathDir, name];

    return fullPath;
}

+ (NSString *)randomCacheLocationWithName:(NSString *)name {
    NSString *subDir = [NSString stringWithFormat:@"tmp/%@", NSUUID.UUID.UUIDString.lowercaseString];
    return [self cacheLocationWithSubDir:subDir name:name];
}

+ (NSString *)cacheLocationWithSubDirPath:(NSString *)subDirPath {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/",[self defaultCacheLocation], subDirPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

+ (NSString *)defaultCacheLocation {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return  [NSString stringWithFormat:@"%@/%@", paths.firstObject, self.customDir];
}

+ (void)clearCachePath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    NSString *dir = [path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil].count == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

+ (NSString *)customDir {
    return @"defalutCache";
}

@end
