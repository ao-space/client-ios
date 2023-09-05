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
//  ESTransferTask.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferTask.h"
#import "ESFileDefine.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESUploadMetadata.h"
#import "ESFileInfoPub.h"
#import <YYModel/YYModel.h>
#import "NSString+ESTool.h"
#import "ESFileHandleManager.h"
#import "ESTransferManager.h"
#import "NSDate+Format.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "NSArray+ESTool.h"
#import "ESFileInfoPub+ESTool.h"


@interface ESTransferTask ()

@property (nonatomic, strong) ESTransferProgress *progress;
@property (nonatomic, assign) ESTransferErrorState taskErrorState;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) UInt64 size;

@property (nonatomic, assign) UInt64 timestamp;
@property (nonatomic, assign) ESTransferState state;
@property (nonatomic, assign) ESTransferWay transferWay;

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL selectForDelectRecord;

///下载
@property (nonatomic, copy) NSString *localPath;

@property (nonatomic, copy) NSString *fileId;

@property (nonatomic, strong) ESFileInfoPub *file;
@property (nonatomic, strong) ESFileInfoPub * uploadFile;

//上传
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *requestId;

@property (nonatomic, copy) NSString *targetDir;

@property (nonatomic, copy) NSString *localIdentifier;
@property (nonatomic, strong) ESUploadMetadata *metadata;

@end

@implementation ESTransferTask

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [ESTransferTask yy_modelWithJSON:[self yy_modelToJSONObject]];
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"isCertificateFailed",
        @"isCalBetaging",
        @"selectForDelectRecord",
        
        @"downloadBeginTime",//  记录速度用的字段
        @"downloadEndTime",
        @"taskCreateTime",
        @"createMultiPartReqTime",
        @"createMultiPartRespTime",
        @"endMultiPartReqTime",
        @"endMultiPartRespTime" //  记录速度用的字段
    ];
}

+ (instancetype)taskWithFile:(ESFileInfoPub *)file visible:(BOOL)visible {
    ESTransferTask *task = [ESTransferTask new];
    task.file = file;
    task.fileId = file.uuid;
    task.name = file.name;
    task.size = file.size.unsignedLongLongValue;
    task.progress = [ESTransferProgress new];
    task.localPath = LocalPathForFile(file);
    task.state = ESTransferStateReady;
    task.visible = visible;
    return task;
}

+ (instancetype)taskWithMetaData:(ESUploadMetadata *)metadata {
    ESTransferTask *task = [self taskWithFilePath:metadata.localDataFile requestId:metadata.taskUUID targetDir:metadata.folderPath];
    task.metadata = metadata;
    task.localIdentifier = metadata.assetLocalIdentifier;
    task.taskCreateTime = [[NSDate date] timeIntervalSince1970];
    return task;
}

+ (instancetype)taskWithFilePath:(NSString *)filePath
                       requestId:(NSString *)requestId
                       targetDir:(NSString *)targetDir {
    ESTransferTask *task = [ESTransferTask new];
    task.filePath = filePath;
    task.requestId = requestId;
    task.targetDir = targetDir;
    task.name = filePath.lastPathComponent;
    task.size = [[NSFileManager.defaultManager attributesOfItemAtPath:filePath.fullCachePath error:nil] fileSize];
    task.progress = [ESTransferProgress new];
    task.state = ESTransferStateReady;
    task.visible = YES;
    return task;
}

- (instancetype)init {
    if (self = [super init]) {
        self.sliceModel = [[ESSliceModel alloc] init];
        self.downloadSliceModel = [[ESDownloadSliceModel alloc] init];
        self.taskObserverArr = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    
    return self;
}

- (void)setState:(ESTransferState)state {
    BOOL same = _state == state;
    _state = state;
    if (state == ESTransferStateCompleted && self.timestamp == 0) {
        self.timestamp = NSDate.date.timeIntervalSince1970;
    }
    if (!same) {
        [self callUpdateProgress];
    }
}

- (void)onUpdateProgress:(int64_t)bytes
              totalBytes:(int64_t)totalBytes
      totalBytesExpected:(int64_t)totalBytesExpected {
    BOOL update = [self.progress onUpdateProgress:bytes
                         totalBytes:totalBytes
                 totalBytesExpected:totalBytesExpected];
    if (update) {
        [self callUpdateProgress];
    }
}

- (NSString *)taskId {
    return self.fileId ?: self.requestId;
}

- (BOOL)isDownloadTask {
    return self.fileId != nil;
}

- (NSString *)description {
    return [self yy_modelToJSONString];
}

- (void)setVisible:(BOOL)visible {
    _visible = visible;
}

- (void)updateSelectForRecord:(BOOL)isSelected {
    dispatch_semaphore_t tmpSemaphore;
    if (self.isDownloadTask) {
        tmpSemaphore = self.downloadingSemaphore;
    } else {
        tmpSemaphore = self.uploadingSemaphore;
    }
        
    if (tmpSemaphore) {
        dispatch_semaphore_wait(tmpSemaphore, DISPATCH_TIME_FOREVER);
        self.selectForDelectRecord = isSelected;
        dispatch_semaphore_signal(tmpSemaphore);
    } else {
        self.selectForDelectRecord = isSelected;
    }
}

- (void)updateTimestamp {
    _timestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)callResult:(ESRspUploadRspBody *)result error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) {
            self.callback(result, error);
        }
    });
}

- (void)setUploadTaskSuspended {
    if (self.state != ESTransferStateCompleted) {
        [self updateUploadTaskState:ESTransferStateSuspended];
        [self setFragmentStateSuspended];
    }
}

- (CGFloat)getProgress {
    if (self.isDownloadTask) {
        if (self.downloadSliceModel.rangeArray.count == 1) {
            return self.progress.progress;
        }
        return [self.downloadSliceModel getDownloadProgress];
    }
    
    if (self.isMultipart) {
        int num = [self.sliceModel completedSliceNum];
        long total = self.sliceModel.dataArray.count;
        if (total > 0) {
            return num * 1.0 / total;
        }
        return 0;
    }
    
    return self.progress.progress;
}

// 获取任务的速度
- (NSString *)getTaskSpeed {
    int num = ESMaxSliceUploadNum;
    if (self.isDownloadTask) {
        num = ESMaxSliceDownloadNum;
    }
    return [self.progress getTaskSpeed:num];
}

- (void)callUpdateProgress {
    if (self.updateProgressBlock) {
        self.updateProgressBlock(self);
    }
}

- (void)updateTaskTransferWay:(ESTransferWay)way {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.transferWay = way;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.transferWay = way;
    }
}

- (BOOL)isMultipart {
    return self.size > MIN_SLICE_UNIT;
}

- (void)updatedTaskState {
    [[self.taskObserverArr allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(taskStateUpdated:)]) {
            [obj taskStateUpdated:self];
        }
    }];
}

- (void)addTaskObserver:(id<ESTaskProtocol>)item {
    [self.taskObserverArr addObject:item];
}

- (void)setUploadBetag:(NSString *)betag slice:(NSMutableArray *)sliceArr {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.metadata.betag = betag;
        self.sliceModel.fileBetag = betag;
        self.sliceModel.dataArray = sliceArr;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.metadata.betag = betag;
        self.sliceModel.fileBetag = betag;
        self.sliceModel.dataArray = sliceArr;
    }
}

- (void)updateUploadTaskState:(ESTransferState)state {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.state = state;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.state = state;
    }
}

- (void)updateUploadTaskErrorState:(ESTransferErrorState)state {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.taskErrorState = state;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.taskErrorState = state;
    }
    ESDLog(@"[上传下载] 上传的原文件丢失:%@", self.name);
}

- (void)updateUploadSliceState:(FileFragment *)item state:(ESTransferState)state {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        item.fragmentState = state;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        item.fragmentState = state;
    }
}

- (void)updateUploadSliceSpeed:(FileFragment *)item speed:(CGFloat)speed {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        item.fragmentSpeed = speed;
        [self.progress addFragmentSpeed:speed];
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        item.fragmentSpeed = speed;
        [self.progress addFragmentSpeed:speed];
    }
}

- (void)updateUploadMetadataStatue:(ESUploadMetadataStatus)status {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.metadata.status = status;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.metadata.status = status;
    }
}

- (void)updateUploadUploadId:(NSString *)uploadId {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        self.metadata.uploadId = uploadId;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        self.metadata.uploadId = uploadId;
    }
}

- (void)clearUploadRecord {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        [self doClearUploadRecord];
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        [self doClearUploadRecord];
    }
}

- (void)doClearUploadRecord {
    NSString *pathMd5 = [self getFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathMd5]) {
        [[NSFileManager defaultManager] removeItemAtPath:pathMd5 error:nil];
    }
}

- (void)updateUploadSliceTransferWay:(FileFragment *)item way:(ESTransferWay)way {
    if (self.uploadingSemaphore) {
        dispatch_semaphore_wait(self.uploadingSemaphore, DISPATCH_TIME_FOREVER);
        item.transferWay = way;
        dispatch_semaphore_signal(self.uploadingSemaphore);
    } else {
        item.transferWay = way;
    }
}

- (NSString *)getFilePath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [self.metadata.url md5Uppercase];
    NSString *pathMd5 =[NSString stringWithFormat:@"%@/%@",documentPath, path];
    return pathMd5;
}

- (NSString *)getFragmentFilePath:(FileFragment *)item {
    NSString *pathMd5 =[self getFilePath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",pathMd5, item.md5sum];
    return filePath;
}

- (NSString *)getEncryptFragmentFilePath:(FileFragment *)item {
    NSString *filePath = [self getFragmentFilePath:item];
    return [NSString stringWithFormat:@"%@.encrypt", filePath];
}


- (NSString *)encryptFragmentFile:(FileFragment *)item token:(ESTokenItem *)token {
    NSString * filePath = [self getFragmentFilePath:item];
    NSString *encryptFilePath = [self getEncryptFragmentFilePath:item];
    UInt64 cipherTextLength = [ESFileHandleManager.manager encryptFile:filePath target:encryptFilePath key:token.secretKey iv:token.secretIV];
    if (cipherTextLength == 0) {
        return nil;
    }
    return encryptFilePath;
}

- (BOOL)delFragmentFile:(FileFragment *)item {
    NSString * path = [self getFragmentFilePath:item];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return NO;
}

- (BOOL)delEncryptFragmentFile:(FileFragment *)item {
    NSString * path = [self getEncryptFragmentFilePath:item];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return NO;
}

- (void)setFragmentStateSuspended {
    [self.sliceModel.dataArray enumerateObjectsUsingBlock:^(FileFragment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.fragmentState != ESTransferStateCompleted) {
            obj.fragmentState = ESTransferStateSuspended;
        }
    }];
}

- (void)setUploadFragmentStateReady {
    [self.sliceModel.dataArray enumerateObjectsUsingBlock:^(FileFragment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.fragmentState != ESTransferStateCompleted) {
            obj.fragmentState = ESTransferStateReady;
        }
    }];
}

//
- (void)updateDownloadTaskState:(ESTransferState)state {
    if (self.downloadingSemaphore) {
        dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
        self.state = state;
        dispatch_semaphore_signal(self.downloadingSemaphore);
    } else {
        self.state = state;
    }
}

- (void)updateDownloadTaskErrorState:(ESTransferErrorState)state {
    if (self.downloadingSemaphore) {
        dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
        self.taskErrorState = state;
        dispatch_semaphore_signal(self.downloadingSemaphore);
    } else {
        self.taskErrorState = state;
    }
}

- (void)updateDownloadSliceState:(ESDownloadFragmentModel *)item state:(ESTransferState)state {
    if (self.downloadingSemaphore) {
        dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
        item.downloadFragmentState = state;
        dispatch_semaphore_signal(self.downloadingSemaphore);
    } else {
        item.downloadFragmentState = state;
    }
}

- (void)updateDownloadSliceSpeed:(ESDownloadFragmentModel *)item speed:(CGFloat)speed {
    if (self.downloadingSemaphore) {
        dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
        item.fragmentSpeed = speed;
        [self.progress addFragmentSpeed:speed];
        dispatch_semaphore_signal(self.downloadingSemaphore);
    } else {
        item.fragmentSpeed = speed;
        [self.progress addFragmentSpeed:speed];
    }
}

- (void)updateDownloadSliceTransferWay:(ESDownloadFragmentModel *)item way:(ESTransferWay)way {
    if (self.downloadingSemaphore) {
        dispatch_semaphore_wait(self.downloadingSemaphore, DISPATCH_TIME_FOREVER);
        item.downloadTransferWay = way;
        dispatch_semaphore_signal(self.downloadingSemaphore);
    } else {
        item.downloadTransferWay = way;
    }
}

- (NSString *)getFailedReason {
    if (self.taskErrorState == ESTransferErrorStateFileNotExist) {
        return NSLocalizedString(@"The original file has been lost", @"原文件已丢失");
    }
    if (self.isDownloadTask) {
        return NSLocalizedString(@"Download failed", @"下载失败，请重试");
    }
    
    return NSLocalizedString(@"task_upload_failed", @"上传失败");
}

- (void)setUploadResult:(ESUploadRspBody *)model {
    if (!model) {
        return;
    }
    ESFileInfoPub * file = [[ESFileInfoPub alloc] init];
    file.betag = model.betag;
    file.category = model.category;
    file.createdAt = model.createdAt;
    file.fileCount = model.fileCount;
    file.isDir = model.isDir;
    file.mime = model.mime;
    file.modifyAt = model.modifyAt;
    file.name = model.name;
    file.operationAt = model.operationAt;
    file.parentUuid = model.parentUuid;
    file.path = model.path;
    file.size = model.size;
    file.trashed = model.trashed;
    file.uuid = model.uuid;
    
    self.uploadFile = file;
}

- (void)setEndMultiPartRespTime:(NSTimeInterval)endMultiPartRespTime {
#ifdef DEBUG
    _endMultiPartRespTime = endMultiPartRespTime;
    if (endMultiPartRespTime < 1
        || self.createMultiPartReqTime < 1
        || self.createMultiPartRespTime < 1
        || self.endMultiPartReqTime< 1) {
        return;
    }
    
    CGFloat size = self.size / (1024.0 * 1024);
    CGFloat speed = size / (endMultiPartRespTime - self.createMultiPartReqTime);
    NSMutableString * mstr = [[NSMutableString alloc] initWithFormat:@"%@ [上传下载] 上传总记录:", [[NSDate date] stringFromFormat:@"MM-dd HH:mm:ss"]];
    [mstr appendFormat:@"名称:%@, ", self.name];
    [mstr appendFormat:@"分片大小:%d M, ", UploadFileFragmentMaxSize/(1024 * 1024)];
    [mstr appendFormat:@"分片并发数:%d, ", ESMaxSliceUploadNum];
    [mstr appendFormat:@"大小:%.2f M, ", size];
    [mstr appendFormat:@"上传速率:%.2f M/s, ", speed];
    [mstr appendFormat:@"上传耗时:%.2f s, ", (self.endMultiPartRespTime - self.createMultiPartReqTime)];
    [mstr appendFormat:@"创建分片任务耗时:%.3f s, ", self.createMultiPartRespTime - self.createMultiPartReqTime];
    [mstr appendFormat:@"合并分片任务耗时:%.3f s, ", self.endMultiPartRespTime - self.endMultiPartReqTime];
    [mstr appendFormat:@"betag计算与分片耗时:%.2f s, ", (self.createMultiPartReqTime - self.taskCreateTime)];
    [mstr appendFormat:@"全过程速率:%.2f M/s, ", size / (endMultiPartRespTime - self.taskCreateTime)];

    
    __block int httpNum = 0; __block int fileApiNum = 0;
    [self.sliceModel.dataArray enumerateObjectsUsingBlock:^(FileFragment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.transferWay == ESTransferWay_HTTP) {
            httpNum ++;
        } else if (obj.transferWay == ESTransferWay_HTTP_FILEAPI) {
            fileApiNum ++;
        }
    }];
    [mstr appendFormat:@"FILEAPI分片数:%d, HTTP分片数:%d", fileApiNum, httpNum];


    [[ESTransferManager manager] addTransferResult:mstr];
    ESDLog(mstr);
    
#endif
}



- (BOOL)isCompletedDownloadTask {
    __block BOOL result = YES;
    [self.downloadSliceModel.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadFragmentState != ESTransferStateCompleted) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)mergeDownloadData:(void (^)(NSURL * url))completedBlock {
    ESPerformBlockAsyn(^{
        NSString *downPath = [self.file getOriginalFileSaveDir];
        NSString *filePa = [self.file getOriginalFileSavePath];

        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downPath error:NULL];
        NSMutableArray *partDataArray = [NSMutableArray new];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            if ([str containsString:@"bytes"]) {
                if(![str containsString:@"encrypt"])
                    [partDataArray addObject:str];
            }
        }
        NSMutableArray *sortArray = [NSMutableArray new];
        if (partDataArray.count == 1) {
            sortArray = [partDataArray mutableCopy];
        }else{
            for (int i = 0; i < partDataArray.count; i++) {
                if (i == partDataArray.count - 1) {
                    NSString *start = [NSString stringWithFormat:@"%d",i* DownloadFileFragmentMaxSize];
                    long int fileSize = self.size;
                    NSString *end = [NSString stringWithFormat:@"%ld",fileSize -1];
                    NSString *str = [NSString stringWithFormat:@"bytes=%@-%@",start,end];
                    [sortArray addObject:str];
                }else{
                    NSString *start = [NSString stringWithFormat:@"%d",i* DownloadFileFragmentMaxSize];
                    NSString *end = [NSString stringWithFormat:@"%d",(i+1) * DownloadFileFragmentMaxSize - 1];
                    NSString *str = [NSString stringWithFormat:@"bytes=%@-%@",start,end];
                    [sortArray addObject:str];
                }
            }
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePa]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePa error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:filePa contents:nil attributes:nil];
        NSFileHandle * writerHandle = [NSFileHandle fileHandleForWritingAtPath:filePa];
        for (int i = 0; i < sortArray.count; i++) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",downPath,sortArray[i]];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];

            [writerHandle seekToEndOfFile];

            if (@available(iOS 13.0, *)) {
                NSError * error;
                [writerHandle writeData:fileData error:&error];
                if (error) {
                    ESDLog(@"[上传下载] %@ - fileHandle 合并下载任务数据 - 失败", self.name);
                    [writerHandle closeFile];
                    if (completedBlock) {
                        completedBlock(nil);
                    }
                    return;
                }
            } else {
                [writerHandle writeData:fileData];
            }
        }

        [writerHandle closeFile];
        ESDLog(@"[上传下载] - 合并下载任务数据 - 成功：%@", filePa);
        if (completedBlock) {
            completedBlock([NSURL fileURLWithPath:filePa]);
        }
    });
}

// 获取下载文件的路径
+ (NSString *)getDownloadFilePath:(ESFileInfoPub *)file {
    ESTransferTask * task = [ESTransferTask taskWithFile:file visible:NO];
    NSString * filePath = [task getDownloadFilePath];
    return filePath;
}

- (NSString *)getDownloadFilePathForUpload {
    return [self.uploadFile getOriginalFileSavePath];
}

- (NSString *)getDownloadFilePath {
    return [self.file getOriginalFileSavePath];
}

- (NSString *)getDownloadFragmentDir {
    NSString *downPath = [self.file getOriginalFileSaveDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:downPath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:downPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return downPath;
}

- (NSString *)getCacheDownloadFilePath {
    NSString *downPath = [self getDownloadFragmentDir];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",downPath, self.name];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        return filePath;
    }

    return nil;
}

- (void)createDownloadRangeFragments {
    long total = self.file.size.longLongValue/DownloadFileFragmentMaxSize + 1;

    for(int i = 1; i < total + 1; i++){
        UInt64 flag = i * DownloadFileFragmentMaxSize;
        UInt64 start, end;
        if(flag < self.file.size.longLongValue){
            if (i == 1) {
                start = 0;
                if (self.size < flag) {
                    end = self.size;
                }else{
                    end = flag - 1;
                }
            }else{
                int startFlag =(i-1) * DownloadFileFragmentMaxSize;
                start = startFlag;
                end = flag - 1;
            }
        }else{
            start = (i-1) * DownloadFileFragmentMaxSize;
            end = self.file.size.longLongValue - 1;
        }
        
        ESDownloadFragmentModel * item = [[ESDownloadFragmentModel alloc] init];
        item.range = [NSString stringWithFormat:@"bytes=%llu-%llu",start, end];
        item.size = end - start;
        item.index = i;
        
        [self.downloadSliceModel.rangeArray addObject:item];
    }
}

- (NSString *)getDownloadRangePath:(ESDownloadFragmentModel *)item {
    NSString *downPath = [self getDownloadFragmentDir];
    NSString * rangePath = [NSString stringWithFormat:@"%@/%@",downPath, item.range];
    return rangePath;
}

- (NSString *)getDownloadRangeEncryptPath:(ESDownloadFragmentModel *)item {
    NSString *encryptPath = [NSString stringWithFormat:@"%@.encrypt", [self getDownloadRangePath:item]];
    return encryptPath;
}

- (void)clearDownloadCache {
    NSString * downPath = [self getDownloadFragmentDir];
    BOOL directory = NO;
    BOOL isDir = [[NSFileManager defaultManager] fileExistsAtPath:downPath isDirectory:&directory];
    if (isDir) {
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:downPath error:&error];
        if (error) {
            ESDLog(@"[上传下载] 清除下载缓存失败");
        }
    }
}

- (void)callDownloadResult:(NSURL *)url error:(NSError *)error {
    if (self.downloadCallback) {
        self.downloadCallback(url, error);
    }
    if (self.downloadPreCallback) {
        self.downloadPreCallback(url, error);
    }
}

- (void)setDownloadFragmentStateSuspended {
    [self.downloadSliceModel.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadFragmentState != ESTransferStateCompleted) {
            obj.downloadFragmentState = ESTransferStateSuspended;
        }
    }];
}

- (void)setDownloadFragmentStateReady {
    [self.downloadSliceModel.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadFragmentState != ESTransferStateCompleted) {
            obj.downloadFragmentState = ESTransferStateReady;
        }
    }];
}

- (void)setDownloadEndTime:(NSTimeInterval)downloadEndTime {
#ifdef DEBUG

    _downloadEndTime = downloadEndTime;
    if (downloadEndTime < 1 || self.downloadBeginTime < 1) {
        return;
    }
     
    CGFloat size = self.size / (1024.0 * 1024);
    CGFloat speed = size / (downloadEndTime - self.downloadBeginTime);
    NSMutableString * mstr = [[NSMutableString alloc] initWithFormat:@"%@ [上传下载] 下载总记录:", [[NSDate date] stringFromFormat:@"MM-dd HH:mm:ss"]];
    [mstr appendFormat:@"名称:%@, ", self.name];
    [mstr appendFormat:@"分片并发数:%d, ", ESMaxSliceDownloadNum];
    [mstr appendFormat:@"大小:%.2f M, ", size];
    [mstr appendFormat:@"速率:%.2f M/s, ", speed];
    [mstr appendFormat:@"下载总耗时:%.2f s, ", (self.downloadEndTime - self.downloadBeginTime)];
    
    __block int httpNum = 0; __block int fileApiNum = 0;
    [self.downloadSliceModel.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadTransferWay == ESTransferWay_HTTP) {
            httpNum ++;
        } else if (obj.downloadTransferWay == ESTransferWay_HTTP_FILEAPI) {
            fileApiNum ++;
        }
    }];
    [mstr appendFormat:@"FILEAPI分片数:%d, HTTP分片数:%d", fileApiNum, httpNum];

    [[ESTransferManager manager] addTransferResult:mstr];
    ESDLog(mstr);
    
#endif
}
@end


@interface ESSliceModel()
@property (nonatomic, strong) dispatch_semaphore_t fragmentSemaphore;

@end

@implementation ESSliceModel

- (instancetype)init {
    if (self = [super init]) {
        self.dataArray = [NSMutableArray array];
        self.fragmentSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"dataArray" : [FileFragment class] };
}

- (int)completedSliceNum {
    __block int num = 0;
    [self.dataArray enumerateObjectsUsingBlock:^(FileFragment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.fragmentState == ESTransferStateCompleted) {
            num ++;
        }
    }];
    return num;
}

- (FileFragment *)getCanTransferFragment {
    __block FileFragment * item = nil;
    ESDLog(@"[上传下载] 获取可上传的分片 - 进入");
    dispatch_semaphore_wait(self.fragmentSemaphore, DISPATCH_TIME_FOREVER);
    [self.dataArray enumerateObjectsUsingBlock:^(FileFragment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.fragmentState == ESTransferStateReady ||
            obj.fragmentState == ESTransferStateSuspended ||
            obj.fragmentState == ESTransferStateFailed) {
            item = obj;
            *stop = YES;
        }
    }];
    dispatch_semaphore_signal(self.fragmentSemaphore);
    ESDLog(@"[上传下载] 尝试获取可上传的分片 - 退出，item is %@", (item == nil ? @"nil" : @"real"));

    return item;
}


@end


@interface ESDownloadSliceModel()
@property (nonatomic, strong) dispatch_semaphore_t fragmentSemaphore;

@end
@implementation ESDownloadSliceModel
- (instancetype)init {
    if (self = [super init]) {
        _rangeArray = [NSMutableArray array];
        self.fragmentSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"rangeArray" : [ESDownloadFragmentModel class] };
}


- (int)completedFragmentNum {
    __block int num = 0;
    [self.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadFragmentState == ESTransferStateCompleted) {
            num ++;
        }
    }];
    return num;
}

- (ESDownloadFragmentModel *)getCanDownloadFragment {
    __block ESDownloadFragmentModel * item = nil;
    ESDLog(@"[上传下载] 获取可下载的分片 - 进入");
    dispatch_semaphore_wait(self.fragmentSemaphore, DISPATCH_TIME_FOREVER);
    [self.rangeArray enumerateObjectsUsingBlock:^(ESDownloadFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadFragmentState == ESTransferStateReady ||
            obj.downloadFragmentState == ESTransferStateSuspended ||
            obj.downloadFragmentState == ESTransferStateFailed) {
            item = obj;
            *stop = YES;
        }
    }];
    dispatch_semaphore_signal(self.fragmentSemaphore);
    ESDLog(@"[上传下载] 尝试获取可下载的分片 - 退出，item is %@", (item == nil ? @"nil" : @"real"));

    return item;
}

- (CGFloat)getDownloadProgress {
    if (self.rangeArray.count == 0) {
        return 0;
    }
    return [self completedFragmentNum] * 1.0 / self.rangeArray.count;
}

@end

@implementation ESDownloadFragmentModel

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"startDownloadTime",
        @"endDownloadTime",
    ];
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}
@end



