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
//  ESDatabaseManager.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAccount.h"
#import <Foundation/Foundation.h>

extern NSString *const kESDatabaseAccount;

extern NSString *const kESDatabaseSync;

extern NSString *const kESDatabaseFilelist;

@interface ESDatabaseManager : NSObject

+ (instancetype)manager;
//是否初始化好
- (BOOL)isReady;

- (void)close:(void (^)(void))onClosed;

///Common

- (void)save:(NSArray *)data;

- (NSArray *)query:(Class)some;

/// 增加
- (BOOL)insertObjects:(NSArray *)array into:(NSString *)into;

- (BOOL)createTableAndIndexesOfName:(NSString *)tableName withClass:(Class)cls;

- (NSArray *)getFilesByUids:(NSString *)tableName withClass:(Class)cls category:(NSString *)category;

- (BOOL)deleteObjectsFromTable:(NSString *)tableName;

- (void)reset;

@end
