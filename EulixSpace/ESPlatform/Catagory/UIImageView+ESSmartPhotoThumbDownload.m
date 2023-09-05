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
//  UIImageView+ESSmartPhotoThumbDownload.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIImageView+ESSmartPhotoThumbDownload.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import <SDWebImage/SDWebImage.h>
#import  <SSZipArchive/SSZipArchive.h>
#import <objc/runtime.h>
#import "ESThumbLoadThreadManager.h"

typedef NS_ENUM(NSUInteger, ESSmartPhotoThumbType) {
    ESSmartPhotoThumbTypeCover,
    ESSmartPhotoThumbTypeCompress,
    ESSmartPhotoThumbTypeOriginal,
};

@implementation UIImageView (ESSmartPhotoThumbDownload)

- (void)es_setImageWithUuid:(NSString *)uuid placeholderImageName:(nullable NSString *)placeholderName {
    [self es_setImageWithUuid:uuid placeholderImageName:placeholderName imageType:ESSmartPhotoThumbTypeCover completion:nil];
}

- (void)es_setCompressImageWithUuid:(NSString *)uuid placeholderImageName:(nullable NSString *)placeholderName {
    [self es_setImageWithUuid:uuid placeholderImageName:placeholderName imageType:ESSmartPhotoThumbTypeCompress completion:nil];
}

- (void)es_setCompressImageWithUuid:(NSString *)uuid placeholderImageName:(nullable NSString *)placeholderName completion:(void(^)(BOOL isSuccess))completion {
    [self es_setImageWithUuid:uuid placeholderImageName:placeholderName imageType:ESSmartPhotoThumbTypeCompress completion:completion];
}

- (void)es_setImageWithUuid:(NSString *)uuid
       placeholderImageName:(nullable NSString *)placeholderName
                  imageType:(ESSmartPhotoThumbType)type
                 completion:(void(^)(BOOL isSuccess))completion {
    self.image = (placeholderName.length > 0 ? [UIImage imageNamed:placeholderName] : nil);

    if (uuid.length <= 0) {
        if (completion) {
            completion (NO);
        }
        return;
    }
    
    NSString *uuidPath = [self cacheFullPathWithUuid:uuid imageType:type];
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString: ESSafeString(uuidPath)]];
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
    if (cacheImage) {
        self.image = cacheImage;
        if (completion) {
            completion (YES);
        }
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:uuidPath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:uuidPath];
        [[SDImageCache sharedImageCache] storeImage:image forKey:uuidPath toDisk:YES completion:^{
                
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            if (completion) {
                completion (YES);
            }
        });
        return;
    }
   
    weakfy(self)
    dispatch_async([ESThumbLoadThreadManager shareInstance].requestQueue, ^{
        strongfy(self)
        [self loadThumbWithUUid:uuid imageType:type completion:completion];
    });
}

- (void)loadThumbWithUUid:(NSString *)uuid
              imageType:(ESSmartPhotoThumbType)type
             completion:(void(^)(BOOL isSuccess))completion {
    dispatch_semaphore_wait([ESThumbLoadThreadManager shareInstance].requestSemaphoreLock, DISPATCH_TIME_FOREVER);

    NSString *picZipCachePath = [self cacheZipPathWithUuid:uuid imageType:type];
    [self setEs_uuid:uuid];
    weakfy(self)
    [ESNetworkRequestManager sendCallDownloadRequest:@{@"serviceName" : @"eulixspace-file-service",
                                                       @"apiName" : @"album_thumbs", }
                                         queryParams:@{
                                                        @"userId" : ESSafeString([ESAccountInfoStorage userId])
                                                        }
                                              header:@{}
                                                body:@{@"uuids" : @[uuid],
                                                       @"type" : @(type)
                                                     }
                                          targetPath:picZipCachePath
                                              status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                         }
                                        successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
        dispatch_semaphore_signal([ESThumbLoadThreadManager shareInstance].requestSemaphoreLock);

       strongfy(self)
        NSString *unZipDir = [self cacheDirWithUuid:uuid imageType:type];
        NSString *uuidPath = [self cacheFullPathWithUuid:uuid imageType:type];
        NSError *error;
        BOOL unZipSuccess = [SSZipArchive unzipFileAtPath:picZipCachePath toDestination:unZipDir overwrite:YES password:nil error:&error];
        if (unZipSuccess == NO) {
            if (completion) {
                ESPerformBlockOnMainThread(^{
                completion (NO);
                });
            }
            return;
        }
        
        NSArray *fileOrDocs = [[NSFileManager defaultManager] subpathsAtPath:unZipDir];
        if (fileOrDocs.count > 0) {
            __block NSString *subPath;
            [fileOrDocs enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![path containsString:@"zip"]) {
                    subPath = path;
                    *stop = YES;
                }
            }];
            if (subPath.length <= 0) {
                if (completion) {
                    ESPerformBlockOnMainThread(^{
                    completion (NO);
                    });
                }
                return;
            }
            NSString *fullPath = [unZipDir stringByAppendingPathComponent:ESSafeString(subPath)];
            NSError *error;
            NSString *picCachePath = [self cacheFullPathWithUuid:uuid imageType:type];
            [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:picCachePath error:&error];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picZipCachePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:picZipCachePath error:nil];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:uuidPath];
            if (image == nil) {
                    if (completion) {
                        ESPerformBlockOnMainThread(^{
                        completion (NO);
                        });
                    }
                return;
            }
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString: ESSafeString(uuidPath)]];
            [[SDImageCache sharedImageCache] storeImage:image forKey:key toDisk:YES completion:^{
                    
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.es_uuid isEqualToString:ESSafeString(uuid)]) {
                    self.image = image;
                    if (completion) {
                        completion (YES);
                    }
                }
            });
        }
        
                                          }
                                           failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal([ESThumbLoadThreadManager shareInstance].requestSemaphoreLock);
//                                            __strong typeof (weakSelf) self = weakSelf;
        if (completion) {
            ESPerformBlockOnMainThread(^{
            completion (NO);
            });
        }
                                            }];
}


- (NSString *)cacheZipPathWithUuid:(NSString *)uuid imageType:(ESSmartPhotoThumbType)imageType {
    NSString *fullPath = [self cacheFullPathWithUuid:uuid imageType:imageType];
    return [fullPath stringByAppendingString:@".zip" ];
}

- (NSString *)cacheFullPathWithUuid:(NSString *)uuid imageType:(ESSmartPhotoThumbType)imageType {
    NSString *fullPath = [self cacheDirWithUuid:uuid imageType:imageType];
    return [fullPath stringByAppendingPathComponent:uuid];
}

- (NSString *)cacheDirWithUuid:(NSString *)uuid imageType:(ESSmartPhotoThumbType)imageType {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%ld/%@",[self defaultCacheLocation], imageType, uuid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

- (NSString *)defaultCacheLocation {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return  [NSString stringWithFormat:@"%@/%@/%@", paths.firstObject, @"Default_Thumb_Cache", [ESAccountInfoStorage userUniqueKey]];
}

- (NSString *)es_uuid {
    return objc_getAssociatedObject(self, @selector(es_uuid));
}

- (void)setEs_uuid:(NSString *)uuid {
    objc_setAssociatedObject(self, @selector(es_uuid),
                             uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
