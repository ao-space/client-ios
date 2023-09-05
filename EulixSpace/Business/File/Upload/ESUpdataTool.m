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
//  ESUpdataTool.h
//  EulixSpace
//
//  Created by qu on 2022/2/21.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUpdataTool.h"
#import "ESFileStreamOperation.h"
#import "ESFileHandleManager.h"
#import "ESTransferTask.h"
#import "ESMultipartNetworking.h"
#import "ESTransferManager.h"
#import "ESMultipartApi.h"
#import "ESFileStreamOperation.h"
#include <CommonCrypto/CommonDigest.h>
#import "ESNetworking.h"
#import "NSString+ESTool.h"

@interface ESUpdataTool()

@property(strong,nonatomic) ESFileStreamOperation *fileStreamer;
@property(assign,nonatomic) NSInteger currentIndex;
@property(nonatomic,strong) NSThread *thread1;

@property (nonatomic, strong) ESUploadMetadata *metadata;
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) ESTransferTask *task;
@property (nonatomic, copy) void (^completedBlock)(NSString * md5Name);

// 保存分片数据
@property (nonatomic, strong) NSMutableArray * sliceArr;
@end


@implementation ESUpdataTool

-(void)upDataWithPatpTmp:(ESTransferTask *)task completed:(void(^)(NSString * md5Name))block{
    self.sliceArr = [NSMutableArray array];
    self.task = task;
    self.completedBlock = block;
    [self upDataWithPath:task.metadata];
}

-(void)upDataWithPath:(ESUploadMetadata *)metadata {
    self.metadata= metadata;
    ESFileStreamOperation *fileStreamer = [[ESFileStreamOperation alloc] initFileOperationAtPath:metadata forReadOperation:YES];
    if (!fileStreamer) {
        ESDLog(@"[上传下载] 文件不存在:%@", metadata.fileName);
        if (self.completedBlock) {
            self.completedBlock(nil);
        }
        return;
    }
    self.fileStreamer = fileStreamer;
    [self toUpData];
}

#pragma mark  懒加载
-(NSThread *)thread1{
    if (!_thread1) {
        _thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(upOneBreak) object:nil];
    }
    return _thread1;
}

#pragma mark  方法

-(void)toUpData{
    [self.thread1 start];
}

-(void)upOneBreak{
    ESDLog(@"[上传下载] 计算betag:%@", self.task.name);
    NSMutableArray *fileArray = [NSMutableArray new];
    while (1) {
        //        线程安全,防止多次上传同一块区间
        @synchronized (self) {
            @autoreleasepool {
                
                if (self.currentIndex < self.fileStreamer.fileFragments.count) {
                    if (self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus == FileUpStateWaiting) {
                        self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus = FileUpStateLoading;
                        NSData *fileData = [self.fileStreamer readDateOfFragment:self.fileStreamer.fileFragments[self.currentIndex]];
                        FileFragment *ment = self.fileStreamer.fileFragments[self.currentIndex];
                        
                        unsigned char digest[CC_MD5_DIGEST_LENGTH];
                        CC_MD5(fileData.bytes, (CC_LONG)fileData.length, digest );
                        NSMutableString *md5sum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
                        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
                        {
                            [md5sum appendFormat:@"%02x", digest[i]];
                        }
                        
                        ment.md5sum = md5sum;
                        NSString *filePath = [self createDirName:[self.metadata.url md5Uppercase] fileData:fileData dataMd5:md5sum];
                        ment.path = filePath;
                        [fileArray addObject:ment];
                        [self.sliceArr addObject:ment];

                        NSLog(@"这是第%zd个上传----%@",self.currentIndex,[NSThread currentThread]);
                        self.currentIndex++;
                    }
                    
                } else {
                    
                    NSMutableData *mutableData = [[NSMutableData alloc]init];
                    if (fileArray.count == 0) {
                        [NSThread exit];
                        return;
                    }
                    
                    NSString * fileBetag;
                    if (fileArray.count > 1) {
                        for (int i = 0; i <fileArray.count; i++) {
                            FileFragment *ment = fileArray[i];
                            NSData *dataMD5 = [self dataWithHexString:ment.md5sum];
                            [mutableData appendData:dataMD5];
                        }
                        
                        unsigned char digest[CC_MD5_DIGEST_LENGTH];
                        CC_MD5(mutableData.bytes, (CC_LONG)mutableData.length, digest);
                        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
                        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
                        {
                            [output appendFormat:@"%02x", digest[i]];
                        }
                        fileBetag = output;
                    } else {
                        FileFragment * ment = [fileArray firstObject];
                        fileBetag = ment.md5sum;
                    }
                    
                    [self.task setUploadBetag:fileBetag slice:self.sliceArr];
                    if (self.completedBlock) {
                        NSString *name = [self.metadata.url md5Uppercase];
                        self.completedBlock(name);
                    }
                    
                    [NSThread exit];
                }
            }
        }
    }
}

- (NSString *)createDirName:(NSString *)fileName fileData:(NSData *)fileData dataMd5:(NSString *)dataMd5{
    @synchronized (self) {
        NSString *filePath;
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataFilePath = [documentPath stringByAppendingPathComponent:fileName];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        BOOL isDir = NO;

        // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
        BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];

        if (!(isDir && existed)) {
          
            [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.filePath = dataFilePath;
        
        NSMutableData *writerData = [[NSMutableData alloc] initWithData:fileData];
        NSString *path = [dataFilePath stringByAppendingPathComponent:dataMd5];
        BOOL writeSuccess = [writerData writeToFile:path atomically:YES];

        if (writeSuccess) {
            filePath = path;
        }else{
            filePath = [NSString stringWithFormat:@"%@写入失败",dataMd5];
        }
        
        return filePath;
    }
}

- (NSData *)dataWithHexString:(NSString *)hexString
{
    // hexString的长度应为偶数
    if ([hexString length] % 2 != 0)
        return nil;
    
    NSUInteger len = [hexString length];
    NSMutableData *retData = [[NSMutableData alloc] init];
    const char *ch = [[hexString dataUsingEncoding:NSASCIIStringEncoding] bytes];
    for (int i=0 ; i<len ; i+=2) {
        
        int height=0;
        if (ch[i]>='0' && ch[i]<='9')
            height = ch[i] - '0';
        else if (ch[i]>='A' && ch[i]<='F')
            height = ch[i] - 'A' + 10;
        else if (ch[i]>='a' && ch[i]<='f')
            height = ch[i] - 'a' + 10;
        else
            // 错误数据
            return nil;
        
        int low=0;
        if (ch[i+1]>='0' && ch[i+1]<='9')
            low = ch[i+1] - '0';
        else if (ch[i+1]>='A' && ch[i+1]<='F')
            low = ch[i+1] - 'A' + 10;
        else if (ch[i+1]>='a' && ch[i+1]<='f')
            low = ch[i+1] - 'a' + 10;
        else
            // 错误数据
            return nil;
        
        int byteValue = height*16 + low;
        [retData appendBytes:&byteValue length:1];
    }
    
    return retData;
}

@end
