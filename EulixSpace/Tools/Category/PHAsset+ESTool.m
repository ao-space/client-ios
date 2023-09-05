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
//  PHAsset+ESTool.m
//  ESTool
//
//  Created by Ye Tao on 2021/9/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLocalPath.h"
#import "PHAsset+ESTool.h"

@implementation PHAsset (ESTool)

- (NSString *)es_originalFilename {
//    if ([self respondsToSelector:@selector(filename)]) {
//        NSString *some = [self valueForKey:@"filename"];
//        if (some.length > 0) {
//            return some;
//        }
//    }
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:self];
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypeVideo || assetRes.type == PHAssetResourceTypePhoto) {
            return assetRes.originalFilename;
        }
    }
    return nil;
}

- (void)es_requestData:(void (^)(NSData *imageData, NSString *filename))resultHandler {
    [self es_requestData:nil resultHandler:resultHandler];
}

- (void)es_requestData:(PHImageRequestOptions *)options
         resultHandler:(void (^)(NSData *imageData, NSString *filename))resultHandler {
    if (!options) {
        options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = NO;
    }
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self
                                                             options:options
                                                       resultHandler:^(NSData *_Nullable imageData,
                                                                       NSString *_Nullable dataUTI,
                                                                       UIImageOrientation orientation,
                                                                       NSDictionary *_Nullable info) {
                                                           if (resultHandler) {
                                                               resultHandler(imageData, self.es_originalFilename);
                                                           }
                                                       }];
}

//- (void)es_writeData:(void (^)(NSString *path, NSString *filename))resultHandler {
//    NSString *shortPath = [NSString randomCacheLocationWithName:self.es_originalFilename];
//    [self es_writeData:shortPath.fullCachePath resultHandler:resultHandler];
//}

- (UInt64)es_fileSize {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:self];
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypeVideo || assetRes.type == PHAssetResourceTypePhoto) {
            return [[assetRes valueForKey:@"fileSize"] unsignedLongLongValue];
        }
    }
    return 0;
}

- (void)es_readThumbData:(void (^)(UIImage *thumb))resultHandler {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self
                                                      targetSize:CGSizeMake(120, 120)
                                                     contentMode:PHImageContentModeDefault
                                                         options:options
                                                   resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                       if (resultHandler) {
                                                           resultHandler(result);
                                                       }
                                                   }];
}

- (void)es_writeData:(NSString *)path resultHandler:(void (^)(NSString *path, bool isEdited, NSString *es_originalFilename))resultHandler {
    NSArray<PHAssetResource *> *assetResources = [PHAssetResource assetResourcesForAsset:self];
    __block BOOL isEdited = NO;
    [assetResources enumerateObjectsUsingBlock:^(PHAssetResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == PHAssetResourceTypeAdjustmentData) {
            isEdited = YES;
            *stop = YES;
        }
    }];
    
    if (isEdited) {
        [self wirteEditedData:path resources:assetResources resultHandler:resultHandler];
    } else {
        [self writeOrignialData:path resources:assetResources resultHandler:resultHandler];
    }
}

- (void)wirteEditedData:(NSString *)path resources:(NSArray<PHAssetResource *> *)assetResources resultHandler:(void (^)(NSString *path, BOOL isEdited, NSString *es_originalFilename))resultHandler {
    __block BOOL success = NO;
    PHContentEditingInputRequestOptions * opt = [PHContentEditingInputRequestOptions new];
    opt.networkAccessAllowed = YES;
    [self requestContentEditingInputWithOptions:opt completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        if (self.mediaType == PHAssetMediaTypeImage) {
            NSData * data = [NSData dataWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            success = [data writeToFile:path atomically:YES];
        } else if (self.mediaType == PHAssetMediaTypeVideo) {
            if ([contentEditingInput respondsToSelector:@selector(videoURL)]) {
                NSString * fileURLString = [contentEditingInput valueForKey:@"videoURL"];
                NSError * error;
                success = [[NSFileManager defaultManager] copyItemAtPath:fileURLString toPath:path error:&error];
                if (error) {
                    ESDLog(@"[上传下载] copy edit source failed:%@", error);
                }
            }
        }
        
        if (!success) {
            [self writeOrignialData:path resources:assetResources resultHandler:resultHandler];
            return;
        }
        
        if (resultHandler) {
            resultHandler(path, YES, self.es_originalFilename);
        }
    }];
}

- (void)writeOrignialData:(NSString *)path resources:(NSArray<PHAssetResource *> *)assetResources resultHandler:(void (^)(NSString *path, bool isEdited, NSString *es_originalFilename))resultHandler {
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypeVideo || assetRes.type == PHAssetResourceTypePhoto) {
            PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
            options.networkAccessAllowed = YES;
            [PHAssetResourceManager.defaultManager writeDataForAssetResource:assetRes
                                                                      toFile:[NSURL fileURLWithPath:path]
                                                                     options:options
                                                           completionHandler:^(NSError *_Nullable error) {
                                                               if (resultHandler) {
                                                                   resultHandler(error == nil ? path : nil, NO, self.es_originalFilename);
                                                               }
                                                           }];
            break;
        }
    }
}

- (NSString *)es_duration {
    long time = self.duration;
    int second = (int)(time % 60);
    int minute = (int)(time / 60 % 60);
    int hour = (int)(time / 3600);
    if (hour) {
        return [NSString stringWithFormat:@"%i:%02i:%02i", hour, minute, second];
    }
    return [NSString stringWithFormat:@"%02i:%02i", minute, second];
}

@end
