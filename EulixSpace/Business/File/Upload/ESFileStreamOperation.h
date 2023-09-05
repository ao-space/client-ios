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

#import <Foundation/Foundation.h>
#import "ESUploadMetadata.h"
#import "ESTransferDefine.h"

#define FileFragmentMaxSize         4*1024 *1024 // 1MB


@class FileFragment;

/**
 * 文件流操作类
 */
@interface ESFileStreamOperation : NSObject<NSCoding>
@property (nonatomic, readonly, copy) NSString *fileName;//包括文件后缀名的文件名
@property (nonatomic, readonly, assign) NSUInteger fileSize;//文件大小
@property (nonatomic, readonly, copy) NSString *filePath;//文件所在的文件目录
@property (nonatomic, readonly, strong) NSArray<FileFragment*> *fileFragments;//文件分片数组

+ (instancetype)sharedOperation;
//若为读取文件数据，打开一个已存在的文件。
//若为写入文件数据，如果文件不存在，会创建的新的空文件。（创建FileStreamer对象就可以直接使用fragments(分片数组)属性）
- (instancetype)initFileOperationAtPath:(ESUploadMetadata *)metadata forReadOperation:(BOOL)isReadOperation;

//获取当前偏移量
- (NSUInteger)offsetInFile;

//设置偏移量, 仅对读取设置
- (void)seekToFileOffset:(NSUInteger)offset;

//将偏移量定位到文件的末尾
- (NSUInteger)seekToEndOfFile;

//关闭文件
- (void)closeFile;

#pragma mark - 读操作
//通过分片信息读取对应的片数据
- (NSData*)readDateOfFragment:(FileFragment*)fragment;

//从当前文件偏移量开始
- (NSData*)readDataOfLength:(NSUInteger)bytes;

//从当前文件偏移量开始
- (NSData*)readDataToEndOfFile;

#pragma mark - 写操作
//写入文件数据
- (void)writeData:(NSData *)data;

@end


typedef NS_ENUM(NSInteger, FileUpState)
{
    FileUpStateWaiting = 0,//加入到数组
    FileUpStateLoading = 1,//正在上传
    FileUpStateSuccess = 2//上传成功
};


//上传文件片 貌似就 fragementOffset、fragementOffsetEnd、md5sum、path 有在用
@interface FileFragment : NSObject<NSCoding>
// 标记分片索引
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic,copy)NSString          *path;
@property (nonatomic,assign)NSUInteger      fragmentSize;   //片的大小
@property (nonatomic,assign)NSUInteger      fragementOffset;//片的偏移量
@property (nonatomic,assign)NSUInteger      fragementOffsetEnd;//片的偏移量
@property (nonatomic,assign)FileUpState            fragmentStatus; //上传状态 YES上传成功
@property (nonatomic,copy)NSString            *md5sum;


@property (nonatomic, assign) ESTransferState fragmentState;
// 此分片的速度
@property (nonatomic, assign) CGFloat fragmentSpeed;


@property (nonatomic, assign) ESTransferWay transferWay;
@property (nonatomic, assign) NSTimeInterval startUploadTime;
@property (nonatomic, assign) NSTimeInterval endUploadTime;

@end
