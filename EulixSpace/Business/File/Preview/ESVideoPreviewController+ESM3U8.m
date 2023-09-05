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
//  ESVideoPreviewController+ESM3U8.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVideoPreviewController+ESM3U8.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import  <SSZipArchive/SSZipArchive.h>
#import "ESWXFileShareManager.h"

@implementation ESVideoPreviewController (ESM3U8)

- (void)checkVODSupportWithUuid:(NSString *)uuid compeltionBlock:(ESCheckVODSupportCompletionBlock)compeltionBlock {
    if (uuid.length <= 0) {
        if (compeltionBlock) {
            compeltionBlock(uuid, NO, [NSError errorWithDomain:ESNetWorkErrorDomain
                                                          code:NSNetworkErrorParams
                                                      userInfo:@{ESNetworkErrorUserInfoMessageKey : @"api 参数错误"}]);
        }
        return;
    }
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"aospace-media-vod-service"
                                                    apiName:@"check"
                                                queryParams:@{ @"uuid" : ESSafeString(uuid),
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                    if (compeltionBlock) {
                                                        compeltionBlock(uuid, YES, nil);
                                                    }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    if (compeltionBlock) {
                                                        compeltionBlock(uuid, NO, error);
                                                    }
                                                }];
}


- (void)fetchM3U8FilesWithUuid:(NSString *)uuid retyCount:(NSInteger)retyCount compeltionBlock:(ESFetchM3U8CompletionBlock)compeltionBlock {
    if (uuid.length <= 0) {
        if (compeltionBlock) {
            compeltionBlock(uuid, nil, nil, [NSError errorWithDomain:ESNetWorkErrorDomain
                                                                code:NSNetworkErrorParams
                                                            userInfo:@{ESNetworkErrorUserInfoMessageKey : @"api 参数错误"}]);
        }
        return;
    }
    
    NSString *fileZipCachePath = [self cacheZipPathWithUuid:uuid];
    __weak typeof(self) weakSelf = self;
    [ESNetworkRequestManager sendCallDownloadRequest:@{@"serviceName" : @"aospace-media-vod-service",
                                                       @"apiName" : @"m3u8_file", }
                                         queryParams:@{@"uuid" : ESSafeString(uuid),
                                                        }
                                              header:@{}
                                                body:@{}
                                          targetPath:fileZipCachePath
                                              status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                         }
                                        successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
        __strong typeof (weakSelf) self = weakSelf;
        NSString *unZipDir = [self cacheDirWithUuid:uuid];
        NSError *error;
        BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:fileZipCachePath toDestination:unZipDir overwrite:YES password:nil error:&error];
        ESDLog(@"fetchM3U8FilesWithUuid unzipFileAtPath error: %@  --- unZipSuccess %d" , error, unZipSuccess);
        if (unZipSuccess == NO) {
           
            if (retyCount <= 0 && compeltionBlock) {
                ESPerformBlockSynOnMainThread(^{
                    compeltionBlock(uuid, nil, nil, [NSError errorWithDomain:ESNetWorkErrorDomain
                                                                        code:NSNetworkErrorResponseParse
                                                                    userInfo:@{ESNetworkErrorUserInfoMessageKey : @"解压失败"}]);
                });
                return;
            }
            if (retyCount > 0) {
                [self fetchM3U8FilesWithUuid:uuid retyCount:(retyCount - 1) compeltionBlock:compeltionBlock];
            }
            return;
        }
        
        NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:unZipDir];
        if (fileOrDocs.count > 0) {
            __block NSString *lanSubPath;
            __block NSString *wanSubPath;
            [fileOrDocs enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([path containsString:@"index-lan.m3u8"]) {
                    lanSubPath = path;
                }
                
                if ([path containsString:@"wan"]) {
                    wanSubPath = path;
                }
                
                if (lanSubPath.length > 0 && wanSubPath.length > 0) {
                    *stop = YES;
                }
            }];
            
            if (lanSubPath.length <= 0 || wanSubPath.length <= 0) {
                if (compeltionBlock) {
                    ESPerformBlockSynOnMainThread(^{
                        compeltionBlock(uuid, nil, nil, [NSError errorWithDomain:ESNetWorkErrorDomain
                                                                            code:NSNetworkErrorResponseParse
                                                                        userInfo:@{ESNetworkErrorUserInfoMessageKey : @"缺失m3u8文件"}]);
                    });
                }
                return;
            }
           
            if ([[NSFileManager defaultManager] fileExistsAtPath:fileZipCachePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:fileZipCachePath error:nil];
            }
            NSString *lanfullPath = [unZipDir stringByAppendingPathComponent:ESSafeString(lanSubPath)];
            NSString *wanfullPath = [unZipDir stringByAppendingPathComponent:ESSafeString(wanSubPath)];
            
            @autoreleasepool {
                NSString *lanContent = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:lanfullPath] encoding:NSUTF8StringEncoding];
                NSString *wanContent = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:wanfullPath] encoding:NSUTF8StringEncoding];
                ESDLog(@"[ESM3U8] lanContent: %@ \n", lanContent);
                ESDLog(@"[ESM3U8] wanContent: %@ \n", wanContent);
            }

            ESPerformBlockSynOnMainThread(^{
                if (compeltionBlock) {
                    compeltionBlock(uuid, lanfullPath, wanfullPath, nil);
                }
            });
        }
        
                                          }
                                           failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (compeltionBlock) {
            ESPerformBlockSynOnMainThread(^{
                compeltionBlock(uuid, nil, nil, error);
            });
        }
                                            }];

}

- (NSString *)cacheZipPathWithUuid:(NSString *)uuid {
    NSString *fullPath = [self cacheFullPathWithUuid:uuid];
    return [fullPath stringByAppendingString:@".zip" ];
}

- (NSString *)cacheFullPathWithUuid:(NSString *)uuid {
    NSString *fullPath = [self cacheDirWithUuid:uuid];
    return [fullPath stringByAppendingPathComponent:uuid];
}

- (NSString *)cacheDirWithUuid:(NSString *)uuid {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",[self defaultCacheLocation], uuid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

- (NSString *)defaultCacheLocation {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return  [NSString stringWithFormat:@"%@/%@", paths.firstObject, @"Default_M3U8_Cache"];
}

@end
