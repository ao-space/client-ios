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
//  FLEXSQLResult.m
//  FLEX
//
//  Created by Tanner on 3/3/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXSQLResult.h"
#import "NSArray+FLEX.h"

@implementation FLEXSQLResult
@synthesize keyedRows = _keyedRows;

+ (instancetype)message:(NSString *)message {
    return [[self alloc] initWithMessage:message columns:nil rows:nil];
}

+ (instancetype)error:(NSString *)message {
    FLEXSQLResult *result = [self message:message];
    result->_isError = YES;
    return result;
}

+ (instancetype)columns:(NSArray<NSString *> *)columnNames rows:(NSArray<NSArray<NSString *> *> *)rowData {
    return [[self alloc] initWithMessage:nil columns:columnNames rows:rowData];
}

- (instancetype)initWithMessage:(NSString *)message columns:(NSArray<NSString *> *)columns rows:(NSArray<NSArray<NSString *> *> *)rows {
    NSParameterAssert(message || (columns && rows));
    NSParameterAssert(rows.count == 0 || columns.count == rows.firstObject.count);
    
    self = [super init];
    if (self) {
        _message = message;
        _columns = columns;
        _rows = rows;
    }
    
    return self;
}

- (NSArray<NSDictionary<NSString *,id> *> *)keyedRows {
    if (!_keyedRows) {
        _keyedRows = [self.rows flex_mapped:^id(NSArray<NSString *> *row, NSUInteger idx) {
            return [NSDictionary dictionaryWithObjects:row forKeys:self.columns];
        }];
    }
    
    return _keyedRows;
}

@end
