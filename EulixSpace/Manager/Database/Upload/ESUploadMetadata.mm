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
//  ESUploadMetadata.mm
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUploadMetadata.h"
#import "ESAccountManager.h"
#import "ESDatabaseManager+CURD.h"
#import "ESFileHandleManager.h"
#import "ESLocalPath.h"
#import "ESUploadEntity.h"
#import "ESUploadMetadata+WCTTableCoding.h"
#import "NSDate+Format.h"
#import "PHAsset+ESTool.h"
#import <SDWebImage/SDWebImageManager.h>

@interface ESUploadMetadata ()

@property (nonatomic, strong) UIImage *thumb;

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation ESUploadMetadata

WCDB_IMPLEMENTATION(ESUploadMetadata)

WCDB_SYNTHESIZE(ESUploadMetadata, creationDate)
WCDB_SYNTHESIZE(ESUploadMetadata, modificationDate)
WCDB_SYNTHESIZE(ESUploadMetadata, assetLocalIdentifier)
//WCDB_SYNTHESIZE(ESUploadMetadata, originalFilename)

WCDB_SYNTHESIZE(ESUploadMetadata, localDataFile)
//WCDB_SYNTHESIZE(ESUploadMetadata, fileName)
WCDB_SYNTHESIZE(ESUploadMetadata, sessionTaskIdentifier)
WCDB_SYNTHESIZE(ESUploadMetadata, requestId)
//WCDB_SYNTHESIZE(ESUploadMetadata, size)

WCDB_SYNTHESIZE(ESUploadMetadata, status)
WCDB_SYNTHESIZE(ESUploadMetadata, ocId)
WCDB_SYNTHESIZE(ESUploadMetadata, taskUUID)
WCDB_SYNTHESIZE(ESUploadMetadata, taskType)

WCDB_SYNTHESIZE(ESUploadMetadata, multipart)
WCDB_SYNTHESIZE(ESUploadMetadata, betag)
WCDB_SYNTHESIZE(ESUploadMetadata, uploadId)
WCDB_SYNTHESIZE(ESUploadMetadata, folderId)
WCDB_SYNTHESIZE(ESUploadMetadata, folderPath)
WCDB_SYNTHESIZE(ESUploadMetadata, partSize)
WCDB_SYNTHESIZE(ESUploadMetadata, uploadedOffset)

WCDB_MULTI_PRIMARY_DESC(ESUploadMetadata, "metadata", assetLocalIdentifier)
WCDB_MULTI_PRIMARY(ESUploadMetadata, "metadata", taskType)

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"thumb",
        @"asset",
        @"progress",
        @"uploadDate",
        @"fileName",
        @"originalFilename",
        @"size",
    ];
}

- (NSInteger)businessId {
    //业务来源id， 默认为0， 1-来源相册同步
    if (_businessId != 0) {
        return _businessId;
    }
    return [self.taskType isEqualToString:kESUploadMetadataTypeAutoUpload] ? ESUploadEntityBusinessSync : ESUploadEntityBusinessDefault;
}

+ (instancetype)fromAsset:(PHAsset *)asset type:(NSString *)type {
    ESUploadMetadata *data = [ESUploadMetadata new];
    data.assetLocalIdentifier = asset.localIdentifier;
    data.creationDate = asset.creationDate.timeIntervalSince1970 * 1000;
    data.modificationDate = asset.modificationDate.timeIntervalSince1970 * 1000;
    data.originalFilename = [asset es_originalFilename];
    data.fileName = data.originalFilename;
    data.taskType = type;

    ///同步的文件名不一样
    if ([data.taskType isEqualToString:kESUploadMetadataTypeAutoUpload]) {
        NSString *format = @"YYYYMMdd_hhmmssSSS";
        NSString *ext = [data.originalFilename componentsSeparatedByString:@"."].lastObject;
        data.fileName = [NSString stringWithFormat:@"%@_iOS.%@", [asset.creationDate stringFromFormat:format], ext];
    }

    data.size = [asset es_fileSize];
    data.asset = asset;

    return data;
}

+ (instancetype)newFromAsset:(PHAsset *)asset type:(NSString *)type {
    ESUploadMetadata *data = [ESUploadMetadata new];
    data.assetLocalIdentifier = asset.localIdentifier;
    data.creationDate = asset.creationDate.timeIntervalSince1970 * 1000;
    data.modificationDate = asset.modificationDate.timeIntervalSince1970 * 1000;
//    data.fileName = data.originalFilename;
    data.taskType = type;

    data.asset = asset;
    return data;
}

- (NSString *)fileName {
    ///同步的文件名不一样
    if ([_taskType isEqualToString:kESUploadMetadataTypeAutoUpload]) {
        NSString *format = @"YYYYMMdd_hhmmssSSS";
        NSString *ext = [self.originalFilename componentsSeparatedByString:@"."].lastObject;
        
        if (_asset != nil) {
            _fileName = [NSString stringWithFormat:@"%@_iOS.%@", [_asset.creationDate stringFromFormat:format], ext];
        } else {
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[ESSafeString(_assetLocalIdentifier)] options:nil].lastObject;
            _fileName = [NSString stringWithFormat:@"%@_iOS.%@", [asset.creationDate stringFromFormat:format], ext];
        }
      
        return _fileName;
    }
    
    if (_fileName.length > 0 && ![_fileName containsString:@"null"]) {
        return _fileName;
    }
  
    if (_asset != nil) {
        _fileName = [_asset es_originalFilename];
        return _fileName;
    }
    
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[ESSafeString(_assetLocalIdentifier)] options:nil].lastObject;
    if (asset != nil) {
        _fileName = [asset es_originalFilename];
        return _fileName;
    }
    
    if (self.localDataFile) {
        _fileName = self.localDataFile.lastPathComponent;
        return _fileName;
    }

    return nil;
}

- (NSString *)originalFilename {
    if (_originalFilename.length > 0 && ![_originalFilename containsString:@"null"]) {
        return _originalFilename;
    }

    if (_asset != nil) {
        _originalFilename = [_asset es_originalFilename];
        return _originalFilename;
    }
    
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[ESSafeString(_assetLocalIdentifier)] options:nil].lastObject;
    if (asset != nil) {
        _originalFilename = [asset es_originalFilename];
        return _originalFilename;
    }

    return nil;
}

- (UInt64)size {
    if (_size > 0) {
        return _size;
    }

    if (_asset != nil) {
        _size = [_asset es_fileSize];
        return _size;
    }
    
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[ESSafeString(_assetLocalIdentifier)] options:nil].lastObject;
    if (asset != nil) {
        _size = [asset es_fileSize];
        return _size;
    }
    
    if (self.localDataFile) {
        NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:self.localDataFile error:nil];
        _size = [attrs fileSize];
        return _size;
    }
   
    return 0;
}


+ (instancetype)fromFile:(NSString *)filePath {
    ESUploadMetadata *data = [ESUploadMetadata new];
    data.taskType = kESUploadMetadataTypeTransfer;
    data.fileName = filePath.lastPathComponent;
    data.localDataFile = filePath;
    NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil];
    data.size = [attrs fileSize];

    return data;
}

- (void)writeDataToSandbox:(void (^)(NSString *path))completion {
    if (!self.assetLocalIdentifier) {
     //   [self calculateBetag];
        if (completion) {
            completion(self.localDataFile);
        }
        return;
    }
    NSString *filePath = [NSString assetCacheLocation:self.assetLocalIdentifier name:self.originalFilename].fullCachePath;
    self.localDataFile = filePath;
    NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil];
    if (self.size > 0 && [attrs fileSize] == self.size) {
        //沙盒里有数据
//        [self calculateBetag];
        if (completion) {
            completion(self.localDataFile);
        }

        return;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.assetLocalIdentifier] options:nil];
    if (result.count == 0) {
        completion(nil);
        return;
    }
    PHAsset *asset = result[0];
    [asset es_writeData:filePath
          resultHandler:^(NSString *path, BOOL isEdited, NSString *es_originalFilename) {
        NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil];
        self.isEdited = isEdited;
        self.size = [attrs fileSize];
        [self save];
//        [self calculateBetag];
        if (completion) {
            completion(self.localDataFile);
        }
    }];
}

/* 此处没有计算 betag 的必要，原因有：
 1. betag 的计算方式已发生过调整，下面这种方式仅对不大于4M的文件才能计算到正确结果
 2. 此处调用方式为同步类型，若是大文件，会比较耗时
 */
//- (void)calculateBetag {
//    if (self.betag.length > 0) {
//        return;
//    }
//    self.betag = [ESFileHandleManager.manager betagOfFile:self.localDataFile];
//}

- (void)callResult:(ESRspUploadRspBody *)result error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) {
            self.callback(result, error);
        }
    });
}

- (void)setThumb:(UIImage *)thumb {
    _thumb = thumb;
}

- (void)loadThumbImage:(void (^)(UIImage *thumb))completion {
    if(self.assetLocalIdentifier.length < 1){
        UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:self.noPermissionthumbnailPath];
        if (completion) {
            completion(thumbnailImage);
        }
        return;
    }
    if (self.thumb.size.width != 0) {
        if (completion) {
            completion(self.thumb);
        }
        return;
    }
    NSString * key = self.assetLocalIdentifier;
    if (self.isEdited) {
        key = [NSString stringWithFormat:@"%@_%ld",key, self.modificationDate];
    }
    id<SDImageCache> imageCache = SDWebImageManager.sharedManager.imageCache;
    [imageCache queryImageForKey:key
                         options:(SDWebImageOptions)0
                         context:nil
                      completion:^(UIImage *_Nullable image,
                                   NSData *_Nullable data,
                                   SDImageCacheType cacheType) {
                          if (image) {
                              self.thumb = image;
                              if (completion) {
                                  completion(self.thumb);
                              }
                              return;
                          }
                          if (!self.asset) {
                              [self reloadAsset];
                          }
                          if (![self.asset.localIdentifier isEqualToString:self.assetLocalIdentifier]) {
                              if (completion) {
                                  completion(nil);
                              }
                              return;
                          }
                          [self.asset es_readThumbData:^(UIImage *thumb) {
                              self.thumb = thumb;
                              [imageCache storeImage:thumb
                                           imageData:nil
                                              forKey:key
                                           cacheType:SDImageCacheTypeAll
                                          completion:^{

                                          }];
                              if (completion) {
                                  completion(self.thumb);
                              }
                          }];
                      }];
}

- (void)reloadAsset {
    if (!self.assetLocalIdentifier) {
        return;
    }
    self.asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.assetLocalIdentifier] options:nil].firstObject;
}

#pragma mark - 数据库操作

- (void)save {
    [ESDatabaseManager.manager save:@[self]];
}

- (BOOL)remove {
    [self.localDataFile clearCachePath];
    WCTDelete *remove = [ESDatabaseManager.manager delete:ESUploadMetadata.class];
    [remove where:(ESUploadMetadata.assetLocalIdentifier == self.assetLocalIdentifier && ESUploadMetadata.taskType == self.taskType)];
    return [remove execute];
}

+ (BOOL)deleteMetadata:(NSArray<NSNumber *> *)statuses type:(NSString *)type {
    WCTDelete *remove = [ESDatabaseManager.manager delete:ESUploadMetadata.class];
    WCTCondition condition = ESUploadMetadata.taskType == type;
    if (statuses) {
        WCTCondition statusesCondition = 0 == 1;
        for (NSNumber *status in statuses) {
            statusesCondition = statusesCondition || ESUploadMetadata.status == status.integerValue;
        }
        condition = condition && statusesCondition;
    }
    [remove where:condition];
    return [remove execute];
}

+ (void)clearTable:(NSString *)type {
    WCTDelete *remove = [ESDatabaseManager.manager delete:ESUploadMetadata.class];
    [remove where:ESUploadMetadata.taskType == type];
    [remove execute];
}

+ (void)resetToWaitUpload:(NSString *)type {
    NSArray<ESUploadMetadata *> *metadatas = [self metadata:@[@(ESUploadMetadataStatusInUpload), @(ESUploadMetadataStatusUploading)] limit:-1 type:type];
    [metadatas enumerateObjectsUsingBlock:^(ESUploadMetadata *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.status = ESUploadMetadataStatusWaitUpload;
    }];
    [ESDatabaseManager.manager save:metadatas];
}

+ (NSArray<ESUploadMetadata *> *)metadata:(NSArray<NSNumber *> *)statuses limit:(NSInteger)limit type:(NSString *)type {
    WCTSelect *select = [ESDatabaseManager.manager select:ESUploadMetadata.class];
    WCTCondition condition = ESUploadMetadata.taskType == type;
    if (statuses) {
        WCTCondition statusesCondition = 0 == 1;
        for (NSNumber *status in statuses) {
            statusesCondition = statusesCondition || ESUploadMetadata.status == status.integerValue;
        }
        condition = condition && statusesCondition;
    }
    [select where:condition];
    if (limit > 0) {
        [select limit:limit];
    }
    return select.allObjects;
}

+ (NSArray<ESUploadMetadata *> *)autoUploadMetadata:(NSArray<NSNumber *> *)statuses limit:(NSInteger)limit {
    return [self metadata:statuses limit:limit type:kESUploadMetadataTypeAutoUpload];
}

+ (ESUploadMetadata *)metadataWhere:(NSString *)assetLocalIdentifier type:(NSString *)type {
    WCTSelect *select = [ESDatabaseManager.manager select:ESUploadMetadata.class];
    [select where:(ESUploadMetadata.assetLocalIdentifier == assetLocalIdentifier && ESUploadMetadata.taskType == type)];
    return select.allObjects.firstObject;
}

#pragma mark - Lazy Load

- (NSString *)taskUUID {
    if (!_taskUUID) {
        _taskUUID = NSUUID.UUID.UUIDString.lowercaseString;
    }
    return _taskUUID;
}

- (BOOL)isEqual:(ESUploadMetadata *)object {
    if ([object isKindOfClass:[self class]]) {
        return [self.betag isEqualToString:object.betag]
        && [self.fileName isEqualToString:object.fileName];
    }
    return NO;
}

@end
