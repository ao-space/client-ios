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
//  ESFileDefine.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESFileDefine_h
#define ESFileDefine_h

#import <UIKit/UIKit.h>

extern NSUInteger const kPerByteInKilo;

typedef NS_ENUM(NSUInteger, ESFileViewSelectionMode) {
    ESFileViewSelectionModeOut,
    ESFileViewSelectionModeIn,
};

@class ESFileInfoPub;
@protocol ESFileViewProtocol <NSObject>

@optional

@property (nonatomic, strong) NSArray<ESFileInfoPub *> *children;

@property (nonatomic, copy) void (^selectedFolder)(ESFileInfoPub *folder);

- (void)enterSelectionMode;

- (void)leaveSelectionMode;

- (void)selectedAll:(BOOL)all;

- (void)reloadData;

@end

extern NSString *FileSizeString(UInt64 length, BOOL showUnit);
extern NSString *FileSizeString1(UInt64 length, BOOL showUnit);
extern NSString * CapacitySizeString(UInt64 length, UInt64 base, BOOL showUnit);
extern NSString * es_NetworkSpeedString(CGFloat value);

extern UIImage *IconForFile(id fileOrFileName);

extern UIImage *IconForShareFile(id fileOrFileName);

///File type
extern BOOL IsImageForFile(ESFileInfoPub *file);

extern BOOL IsVideoForFile(ESFileInfoPub *file);

extern BOOL IsMediaForFile(ESFileInfoPub *file);

///Content Type

extern NSString *ContentTypeForPathExtension(NSString *extension);

///Local
extern BOOL LocalFileExist(ESFileInfoPub *file);

extern NSString *LocalPathForFile(ESFileInfoPub *file);
///Local
extern BOOL LocalFileExist(ESFileInfoPub *file);

///压缩图
extern NSString *CompressedPathForFile(ESFileInfoPub *file);

extern BOOL CompressedImageExist(ESFileInfoPub *file);

//缩略图
extern NSString *ThumbnailPathForFile(ESFileInfoPub *file);

extern NSString *ThumbnailPathForFileUUIDAndName(NSString *uuid, NSString *name);

extern BOOL ThumbnailImageExist(ESFileInfoPub *file);

///生成文件的缩略图地址,
extern NSString *ThumbnailUrlForFile(ESFileInfoPub *file, CGSize size);

///预览
extern BOOL UnsupportFileForPreview(ESFileInfoPub *file);

@class ESPicModel;
extern BOOL UnsupportFilePhotoForPreview(ESPicModel *pic);

#endif /* ESFileDefine_h */


