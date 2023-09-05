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
//  ESFileInfoPub+ESTool.m
//  EulixSpace
//
//  Created by dazhou on 2023/5/11.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESFileInfoPub+ESTool.h"
#import "ESAccountInfoStorage.h"

@implementation ESFileInfoPub (ESTool)

- (NSString *)getOriginalFileSaveDir {
    NSString * fileDir = [NSString stringWithFormat:@"%@/%@/%@",
                                 [self.class baseDir],
                                 [self.class customDir],
                                 ESSafeString(self.uuid)];
    return fileDir;
}

- (NSString *)getOriginalFileSavePath {
    return [NSString stringWithFormat:@"%@/%@", [self getOriginalFileSaveDir], self.name];
}

- (NSString *)localOriginalFilePath {
    NSString * filePath = [self getOriginalFileSavePath];
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if (isExist && !isDir) {
        return filePath;
    }
    
    return nil;
}

- (BOOL)hasLocalOriginalFile {
    return [self localOriginalFilePath] != nil;
}

+ (NSString *)baseDir {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)customDir {
    return [NSString stringWithFormat:@"%@/%@",@"download", ESSafeString([ESAccountInfoStorage userUniqueKey])];
}

+ (NSString *)shareCustomDir {
    return [NSString stringWithFormat:@"%@/share",@"download"];
}

+ (NSString *)defaultCacheDir {
     NSString * fileDir = [NSString stringWithFormat:@"%@/%@",
                                 [self baseDir],
                                 [self customDir]] ;
    return fileDir;
}

+ (NSString *)shareCacheDir {
     NSString * fileDir = [NSString stringWithFormat:@"%@/%@",
                                 [self baseDir],
                                 [self shareCustomDir]] ;
    return fileDir;
}
@end
