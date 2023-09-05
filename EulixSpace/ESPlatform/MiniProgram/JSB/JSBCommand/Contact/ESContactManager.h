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
//  ESContactManager.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESContactManagerFetchContactHandler)(BOOL success, NSString * _Nullable vCardFilePath, NSUInteger count, NSError *_Nullable error);

@interface ESContactManager : NSObject

//生成file在特定文件夹目录，webview只有权限访问指定的文件夹
- (void)fetchContactVCardFileWithCustomCacheFileDir:(NSString *)dir
                                  completionHandler:(ESContactManagerFetchContactHandler)handler;
- (void)fetchContactVCardFile:(ESContactManagerFetchContactHandler)handler;

- (void)fetchContactCount:(ESContactManagerFetchContactHandler)handler;

@end

NS_ASSUME_NONNULL_END
