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
//  ESLocalPath.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLocalPath.h"
#import "ESFileInfoPub+ESTool.h"

@implementation ESLocalPath

+ (NSString *)applicationSupportDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (NSString *)documentDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (NSString *)cacheDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (void)createDirectoryStandard {
}

@end

@implementation NSString (ESLocalPath)

+ (NSString *)cacheLocationWithDir:(NSString *)dir {
    NSString *tmpDir = [NSString stringWithFormat:@"%@%@/", [self defaultCacheLocation], dir];
    NSString *fullPath = tmpDir.fullCachePath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return tmpDir;
}

+ (NSString *)cacheLocationWithName:(NSString *)name {
    NSString *tmpDir = [NSString stringWithFormat:@"/%@/", name];
    NSString *fullPath = tmpDir.fullCachePath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return tmpDir;
}

+ (NSString *)randomCacheLocationWithName:(NSString *)name {
    NSString *dir = [NSString stringWithFormat:@"tmp/%@", NSUUID.UUID.UUIDString.lowercaseString];
    return [NSString stringWithFormat:@"%@%@", [self cacheLocationWithName:dir], name];
}

+ (NSString *)defaultCacheLocation {
//    return [ESFileInfoPub defaultCacheDir];
    return [self cacheLocationWithName:@"eulix.xyz"];
}

//不做数据隔离路径
- (NSString *)shareCacheFullPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self]) {
        return self;
    }
    
    NSString *slash = @"/";
    if ([self hasPrefix:slash]) {
        slash = @"";
    }
    NSString *fullCachePath_ =  [NSString stringWithFormat:@"%@%@%@", [ESFileInfoPub shareCacheDir], slash, self];
    NSArray *split = [fullCachePath_ componentsSeparatedByString:@"/"];
    NSString *dir = [fullCachePath_ stringByReplacingOccurrencesOfString:split.lastObject withString:@""];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullCachePath_;
}

- (NSString *)fullCachePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self]) {
        return self;
    }
    
    NSString *slash = @"/";
    if ([self hasPrefix:slash]) {
        slash = @"";
    }
    NSString *fullCachePath_ =  [NSString stringWithFormat:@"%@%@%@", [ESFileInfoPub defaultCacheDir], slash, self];
    return fullCachePath_;
}

- (NSString *)fixPath:(NSString *)fullPath {
    NSRange range = [fullPath rangeOfString:@"Documents"];
    if (range.length == 0) {
        return nil;
    }
    NSString *shortPath = [fullPath substringFromIndex:NSMaxRange(range)];
    return shortPath.fullCachePath;
}

- (void)clearCachePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self]) {
        [[NSFileManager defaultManager] removeItemAtPath:self error:nil];
    }
    NSString *dir = [self stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil].count == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

+ (NSString *)assetCacheLocation:(NSString *)localIdentifier name:(NSString *)name {
    localIdentifier = [localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return [NSString stringWithFormat:@"%@%@", [NSString cacheLocationWithDir:localIdentifier], name];
}

+ (void)clearCacheLocationWithName:(NSString *)name {
    NSString *path = [self cacheLocationWithName:name].fullCachePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (NSDictionary *)jsonObject {
    if (self.length == 0) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error) {
        return nil;
    }
    return object;
}

static NSMutableCharacterSet *_escapeSet;

- (NSString *)URLEncode {
    if (!_escapeSet) {
        _escapeSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [_escapeSet removeCharactersInString:@"+;&=$,"];
    }
    NSString *result = [self stringByRemovingPercentEncoding] ?: self;
    NSString *name = result.lastPathComponent;
    NSRange rangeOfQuestion = [result rangeOfString:@"?"];
    if (rangeOfQuestion.location != NSNotFound) {
        NSString *trimString = [result substringToIndex:rangeOfQuestion.location];
        name = trimString.lastPathComponent;
    }
    if (name) {
        NSString *encodeName = [name stringByAddingPercentEncodingWithAllowedCharacters:_escapeSet];
        return [result stringByReplacingOccurrencesOfString:name withString:encodeName];
    }
    return [result stringByAddingPercentEncodingWithAllowedCharacters:_escapeSet];
}

@end
