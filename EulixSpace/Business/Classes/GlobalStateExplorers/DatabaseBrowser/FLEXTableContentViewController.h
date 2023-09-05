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
//  PTTableContentViewController.h
//  PTDatabaseReader
//
//  Created by Peng Tao on 15/11/23.
//  Copyright © 2015年 Peng Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEXDatabaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLEXTableContentViewController : UIViewController

/// Display a mutable table with the given columns, rows, and name.
///
/// @param columnNames self explanatory.
/// @param rowData an array of rows, where each row is an array of column data.
/// @param rowIDs an array of stringy row IDs. Required for deleting rows.
/// @param tableName an optional name of the table being viewed, if any. Enables adding rows.
/// @param databaseManager an optional manager to allow modifying the table.
///        Required for deleting rows. Required for adding rows if \c tableName is supplied.
+ (instancetype)columns:(NSArray<NSString *> *)columnNames
                   rows:(NSArray<NSArray<NSString *> *> *)rowData
                 rowIDs:(NSArray<NSString *> *)rowIDs
              tableName:(NSString *)tableName
               database:(id<FLEXDatabaseManager>)databaseManager;

/// Display an immutable table with the given columns and rows.
+ (instancetype)columns:(NSArray<NSString *> *)columnNames
                   rows:(NSArray<NSArray<NSString *> *> *)rowData;

@end

NS_ASSUME_NONNULL_END
