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
//  ESImageLoader.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESImageLoader.h"
#import "ESFileDefine.h"
#import "ESLocalPath.h"
#import "ESRealCallRequest.h"
#import "ESTransferManager.h"
#import <SDWebImage/SDWebImage.h>

@implementation ESImageLoader

+ (void)load {
    SDWebImageManager.defaultImageLoader = [ESImageLoader new];
}

- (BOOL)canRequestImageForURL:(nullable NSURL *)url
                      options:(SDWebImageOptions)options
                      context:(nullable SDWebImageContext *)context {
    if ([url.path hasPrefix:@"/thumb/"] && [url.query hasPrefix:@"size="]) {
        return YES;
    }
    return NO;
}

- (nullable id<SDWebImageOperation>)requestImageWithURL:(nullable NSURL *)url
                                                options:(SDWebImageOptions)options
                                                context:(nullable SDWebImageContext *)context
                                               progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                              completed:(nullable SDImageLoaderCompletedBlock)completedBlock {
    NSString *uuid = [url.path componentsSeparatedByString:@"/"].lastObject;
    NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
    __block NSString *name;
    __block NSString *size;
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                        NSUInteger idx,
                                                        BOOL *_Nonnull stop) {
        if ([obj.name isEqualToString:@"name"]) {
            name = obj.value.stringByRemovingPercentEncoding;
        } else if ([obj.name isEqualToString:@"size"]) {
            size = obj.value;
        }
    }];
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.serviceName = @"eulixspace-filepreview-service";
    request.apiName = @"download_thumbnails";
    request.queries = @{@"uuid": uuid, @"size": size};
    NSString *targetPath = ThumbnailPathForFileUUIDAndName(uuid, name).fullCachePath;
    NSURL *local = [NSURL fileURLWithPath:targetPath];
    return (id<SDWebImageOperation>)[ESNetworking.shared downloadRequest:request
        targetPath:targetPath
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
            if (progressBlock) {
                progressBlock(totalBytes, totalBytesExpected, local);
            }
        }
        callback:^(NSURL *output, NSError *error) {
            NSData *imageData = [NSData dataWithContentsOfFile:targetPath];
            if (output && imageData) {
                UIImage *image = SDImageLoaderDecodeImageData(imageData, url, options, context);
                if (completedBlock) {
                    dispatch_main_async_safe(^{
                        completedBlock(image, imageData, error, YES);
                    });
                }
            } else {
                if (completedBlock) {
                    dispatch_main_async_safe(^{
                        completedBlock(nil, nil, error, NO);
                    });
                }
            }
        }];
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(SDWebImageOptions)options
                            context:(nullable SDWebImageContext *)context {
    return NO;
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url error:(nonnull NSError *)error {
    return [self shouldBlockFailedURLWithURL:url error:error options:0 context:nil];
}

- (BOOL)canRequestImageForURL:(nullable NSURL *)url {
    return [self canRequestImageForURL:url options:0 context:nil];
}

@end
