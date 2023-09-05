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
// Created by Ye Tao on 2021/12/2.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESMultipartNetworking.h"
#import "ESMultipartApi.h"
#import "ESRspCompleteMultipartTaskRsp.h"
#import "ESApiClient.h"


@interface ESMultipartNetworking ()

@end

@implementation ESMultipartNetworking {
}

- (void)create:(ESUploadMetadata *)metadata completionBlock:(void (^)(id, NSError *))completionBlock {
    ESCreateMultipartTaskReq *req = [ESCreateMultipartTaskReq new];
    req.betag = metadata.betag;
    req.businessId = @(metadata.businessId);
    req.createTime = @(metadata.creationDate);
    req.fileName = metadata.fileName;
    req.folderId = metadata.folderId;
    req.folderPath = metadata.folderPath;
    req.mime = @"application/octet-stream";
    req.modifyTime = @(metadata.modificationDate);
    req.size = @(metadata.size);
    req.albumId = @([metadata.albumId integerValue]);
    ESApiClient * client = [ESApiClient sharedClient];
    NSTimeInterval old = client.timeoutInterval;
    client.timeoutInterval = 60;
    ESMultipartApi *api = [[ESMultipartApi alloc] initWithApiClient:client];

    [api spaceV1ApiMultipartCreatePostWithRequestId:NSUUID.UUID.UUIDString.lowercaseString
                                             object:req
                                  completionHandler:^(ESRspCreateMultipartTaskRsp *output, NSError *error){
        client.timeoutInterval = old;
        completionBlock(output, error);
    }];
}


- (void)completeUploadId:(NSString *)uploadId completionBlock:(void (^)(id, NSError *))completionBlock {
    ESCompleteMultipartTaskReq *req = [ESCompleteMultipartTaskReq new];
    req.uploadId = uploadId;
    
    ESApiClient * client = [ESApiClient sharedClient];
    NSTimeInterval old = client.timeoutInterval;
    client.timeoutInterval = 60 * 60;
    ESMultipartApi *api = [[ESMultipartApi alloc] initWithApiClient:client];
    [api spaceV1ApiMultipartCompletePostWithRequestId:NSUUID.UUID.UUIDString.lowercaseString object:req completionHandler:^(ESRspCompleteMultipartTaskRsp *output, NSError *error) {
        client.timeoutInterval = old;
            completionBlock(output, error);
    }];
}

- (void)completeUploadListUUID:(NSString *)uploadId completionBlock:(void (^)(id, NSError *))completionBlock {
    ESMultipartApi *api = [ESMultipartApi new];
    ESListMultipartReq *listReq = [ESListMultipartReq new];
    listReq.uploadId = uploadId;
    [api spaceV1ApiMultipartListGetWithRequestId:NSUUID.UUID.UUIDString.lowercaseString object:listReq completionHandler:^(ESRspListMultipartRsp *output, NSError *error) {
        completionBlock(output, error);
    }];
}


+ (ESUploadRspBody *)transferUploadResult:(ESFileInfo *)file {
    ESUploadRspBody * rsp = [[ESUploadRspBody alloc] init];
    rsp.betag = file.betag;
    rsp.bucketName = file.bucketName;
    rsp.category = file.category;
    rsp.createdAt = file.createdAt;
    rsp.executable = file.executable;
    rsp.fileCount = file.fileCount;
    rsp.isDir = file.isDir;
    rsp.mime = file.mime;
    rsp.modifyAt = file.modifyAt;
    rsp.name = file.name;
    rsp.operationAt = file.operationAt;
    rsp.parentUuid = file.parentUuid;
    rsp.path = file.path;
    rsp.size = file.size;
    rsp.tags = file.tags;
    rsp.path = file.path;
    rsp.transactionId = file.transactionId;
    rsp.trashed = file.trashed;
    rsp.userId = file.userId;
    rsp.uuid = file.uuid;
    rsp.version = file.version;
    return rsp;
}

+ (ESRspUploadRspBody *)transferModel:(ESRspCompleteMultipartTaskRsp *)data {
    if (data == nil) {
        return nil;
    }
    ESRspUploadRspBody * mBody = [[ESRspUploadRspBody alloc] init];
    mBody.code = data.code;
    mBody.message = data.message;
    mBody.requestId = data.requestId;
    
    ESUploadRspBody * results = [ESUploadRspBody new];
    mBody.results = results;
    
    results.betag = data.results.betag;
    results.bucketName = data.results.bucketName;
    results.category = data.results.category;
    results.createdAt = data.results.createdAt;
    results.executable = data.results.executable;
    results.fileCount = data.results.fileCount;
    results.isDir = data.results.isDir;
    results.mime = data.results.mime;
    results.modifyAt = data.results.modifyAt;
    results.name = data.results.name;
    results.operationAt = data.results.operationAt;
    results.parentUuid = data.results.parentUuid;
    results.path = data.results.path;
    results.size = data.results.size;
    results.tags = data.results.tags;
    results.transactionId = data.results.transactionId;
    results.trashed = data.results.trashed;
    results.userId = data.results.userId;
    results.uuid = data.results.uuid;
    results.version = data.results.version;
    
    return mBody;
}

@end
