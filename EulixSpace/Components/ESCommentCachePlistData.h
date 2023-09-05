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
//  ESCommentCachePlistData.h
//  EulixSpace
//
//  Created by qu on 2021/10/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESCommentCachePlistData : NSObject
+ (instancetype)manager;

- (NSDictionary *)getPlistDataWithPistName:(NSString *)plistName;

- (NSDictionary *)getDictionary:(NSString *)filePath;

- (NSString *)md5:(NSString *)str;

-(BOOL)isConnectionAvailable;

// 后期抽出
- (void)plistWriteDate:(NSMutableDictionary *)writeDate plistName:(NSString *)plistName;
@end

NS_ASSUME_NONNULL_END
