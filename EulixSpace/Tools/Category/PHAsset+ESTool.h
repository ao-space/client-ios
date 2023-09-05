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
//  PHAsset+ESTool.h
//  ESTool
//
//  Created by Ye Tao on 2021/9/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (ESTool)

- (NSString *)es_originalFilename;

- (void)es_requestData:(PHImageRequestOptions *)options
         resultHandler:(void (^)(NSData *imageData, NSString *filename))resultHandler;

- (void)es_requestData:(void (^)(NSData *imageData, NSString *filename))resultHandler;

//- (void)es_writeData:(void (^)(NSString *path, NSString *filename))resultHandler;

- (void)es_writeData:(NSString *)path resultHandler:(void (^)(NSString *path, BOOL isEdited, NSString *es_originalFilename))resultHandler;

- (void)es_readThumbData:(void (^)(UIImage *thumb))resultHandler;

- (UInt64)es_fileSize;

- (NSString *)es_duration;

@end
