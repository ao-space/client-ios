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
//  PTDatabaseManager.h
//  Derived from:
//
//  FMDatabase.h
//  FMDB( https://github.com/ccgus/fmdb )
//
//  Created by Peng Tao on 15/11/23.
//
//  Licensed to Flying Meat Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Flying Meat Inc. licenses this file to you.

#import <Foundation/Foundation.h>
#import "FLEXDatabaseManager.h"
#import "FLEXSQLResult.h"

@interface FLEXSQLiteDatabaseManager : NSObject <FLEXDatabaseManager>

/// Contains the result of the last operation, which may be an error
@property (nonatomic, readonly) FLEXSQLResult *lastResult;
/// Calls into \c sqlite3_last_insert_rowid()
@property (nonatomic, readonly) NSInteger lastRowID;

/// Given a statement like 'SELECT * from @table where @col = @val' and arguments
/// like { @"table": @"Album", @"col": @"year", @"val" @1 } this method will
/// invoke the statement and properly bind the given arguments to the statement.
///
/// You may pass NSStrings, NSData, NSNumbers, or NSNulls as values.
- (FLEXSQLResult *)executeStatement:(NSString *)statement arguments:(NSDictionary<NSString *, id> *)args;

@end
