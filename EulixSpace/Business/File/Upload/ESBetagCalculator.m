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
//  ESBetagCalculator.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/1.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBetagCalculator.h"
#include <CommonCrypto/CommonDigest.h>
#import "NSString+ESTool.h"

@interface ESBetagCalculator()

@property (nonatomic, strong) NSFileHandle * readHandle;
@property (nonatomic, weak) ESTransferTask * task;
@property (nonatomic, copy) void (^completedBlock)(ESBetagCalculatorResult result);

// 保存分片数据 过渡下，后续要改成动态切片方式
@property (nonatomic, strong) NSMutableArray * sliceArr;
@property (nonatomic, strong) NSString * dataFilePath;

@end

@implementation ESBetagCalculator

- (void)asyncCalBetag:(ESTransferTask *)task completed:(void(^)(ESBetagCalculatorResult result))block {
    NSString * filePath = task.metadata.url;
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        if (block) {
            block(ESBetagCalculatorFileNotExist);
        }
        return;
    }
    
    self.task = task;
    self.completedBlock = block;
    self.readHandle = [NSFileHandle fileHandleForReadingAtPath:task.metadata.url];
    self.sliceArr = [NSMutableArray array];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataFilePath = [documentPath stringByAppendingPathComponent:[self.task.metadata.url md5Uppercase]];
    self.dataFilePath = dataFilePath;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doBetagCalculating];
    });
}

- (void)doBetagCalculating {
    long offset = 4194304;// 4*1024*1024
    
    UInt64 fileSize = self.task.size;
    UInt64 index = 0;
    UInt64 start = 0;
    NSMutableData * mutableData = [[NSMutableData alloc] init];
    
    UInt64 end = start + offset;
    while (end < fileSize) {
        FileFragment * item = [[FileFragment alloc] init];
        
        item.index = index++;
        item.fragementOffset = start;
        item.fragementOffsetEnd = end;
        
        [self doSliceBetagCalculating:item];
        [mutableData appendData:[self dataWithHexString:item.md5sum]];
        
        [self.sliceArr addObject:item];
        
        start = end;
        end += offset;
    }

    
    // Last slice smaller than 4M
    if (start < fileSize && end >= fileSize) {
        FileFragment * item = [[FileFragment alloc] init];
        
        item.index = index;
        item.fragementOffset = start;
        item.fragementOffsetEnd = fileSize;
        
        [self doSliceBetagCalculating:item];
        [mutableData appendData:[self dataWithHexString:item.md5sum]];
        [self.sliceArr addObject:item];
    }
    
    NSString * fileBetag;
    if (self.sliceArr.count == 1) {
        FileFragment * item = self.sliceArr.firstObject;
        fileBetag = item.md5sum;
    } else {
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(mutableData.bytes, (CC_LONG)mutableData.length, digest);
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        fileBetag = output;
    }
    
    [self.readHandle closeFile];
    [self.task setUploadBetag:fileBetag slice:self.sliceArr];
    if (self.completedBlock) {
        self.completedBlock(ESBetagCalculatorSuccess);
    }
}

- (void)doSliceBetagCalculating:(FileFragment *)fragment {
    @autoreleasepool {
        [self.readHandle seekToFileOffset:fragment.fragementOffset];
        UInt64 length = fragment.fragementOffsetEnd - fragment.fragementOffset;

        NSData * sliceData = [self.readHandle readDataOfLength:length];

        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(sliceData.bytes, (CC_LONG)sliceData.length, digest);
        NSMutableString * md5sum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        {
            [md5sum appendFormat:@"%02x", digest[i]];
        }
        
        fragment.md5sum = md5sum;
        fragment.path = [self create:sliceData dataMd5:md5sum];
    }
}


- (NSString *)create:(NSData *)fileData dataMd5:(NSString *)dataMd5{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDir = NO;

    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:self.dataFilePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:self.dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
        
    NSString * path = [self.dataFilePath stringByAppendingPathComponent:dataMd5];
    [fileData writeToFile:path atomically:YES];
    
    return path;
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
