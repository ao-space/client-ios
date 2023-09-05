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
//  ESPreviewItem.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPreviewItem.h"
#import "ESFileDefine.h"
#import "ESLocalPath.h"
#import "ESFileInfoPub.h"
#import <SDWebImage/SDWebImage.h>

@interface ESPreviewItem ()

@property (nonatomic, assign) BOOL origin;

@property (nonatomic, copy) NSURL *previewItemURL;

@property (nonatomic, copy) NSString *previewItemTitle;

@end

@implementation ESPreviewItem

+ (instancetype)itemWithFile:(ESFileInfoPub *)file {
    ESPreviewItem *item = [ESPreviewItem new];
    if (LocalFileExist(file)) {
        item.origin = YES;
        item.previewItemURL = [NSURL fileURLWithPath:LocalPathForFile(file).fullCachePath];
    } else if (CompressedImageExist(file)) {
        ///压缩图
        item.previewItemURL = [NSURL fileURLWithPath:CompressedPathForFile(file).fullCachePath];
    } else {
        if (IsImageForFile(file)) {
            NSString *thumbnailPath = ThumbnailPathForFile(file).fullCachePath;
            item.previewItemURL = [NSURL fileURLWithPath:ThumbnailPathForFile(file).fullCachePath];
            if (![NSFileManager.defaultManager fileExistsAtPath:thumbnailPath]) {
                SDImageCache *imageCache = (SDImageCache *)SDWebImageManager.sharedManager.imageCache;
                NSString *path = [imageCache.diskCache cachePathForKey:ThumbnailUrlForFile(file, CGSizeZero)];
                NSError *error;
                [NSFileManager.defaultManager copyItemAtPath:path toPath:thumbnailPath error:&error];
                if (error) {
                    item.previewItemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cloud_image_default" ofType:@"png"]];
                }
            }
        }else{
            item.origin = YES;
            item.previewItemURL = [NSURL fileURLWithPath:LocalPathForFile(file).fullCachePath];
        }
    }
    item.previewItemTitle = file.name;
    return item;
}

+ (instancetype)itemWithFile:(ESFileInfoPub *)file urlStr:(NSURL *)urlStr{
    ESPreviewItem *item = [ESPreviewItem new];
    if (LocalFileExist(file)) {
        item.origin = YES;
       // item.previewItemURL = [NSURL fileURLWithPath:LocalPathForFile(file).fullCachePath];
        item.previewItemURL = urlStr;
    } else if (CompressedImageExist(file)) {
        ///压缩图
        item.previewItemURL = [NSURL fileURLWithPath:CompressedPathForFile(file).fullCachePath];
    } else {
        if (IsImageForFile(file)) {
            NSString *thumbnailPath = ThumbnailPathForFile(file).fullCachePath;
            item.previewItemURL = [NSURL fileURLWithPath:ThumbnailPathForFile(file).fullCachePath];
            if (![NSFileManager.defaultManager fileExistsAtPath:thumbnailPath]) {
                SDImageCache *imageCache = (SDImageCache *)SDWebImageManager.sharedManager.imageCache;
                NSString *path = [imageCache.diskCache cachePathForKey:ThumbnailUrlForFile(file, CGSizeZero)];
                NSError *error;
                [NSFileManager.defaultManager copyItemAtPath:path toPath:thumbnailPath error:&error];
                if (error) {
                    item.previewItemURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cloud_image_default" ofType:@"png"]];
                }
            }
        }else{
            item.origin = YES;
            item.previewItemURL = urlStr;
        }
    }
    item.previewItemTitle = file.name;
    return item;
}
@end
