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
//  FLEXMITMDataSource.h
//  FLEX
//
//  Created by Tanner Bennett on 8/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXMITMDataSource<__covariant TransactionType> : NSObject

+ (instancetype)dataSourceWithProvider:(NSArray<TransactionType> *(^)(void))future;

/// Whether or not the data in \c filteredTransactions is actually filtered yet or not.
@property (nonatomic, readonly) BOOL isFiltered;

@property (nonatomic, readonly) NSArray<TransactionType> *transactions;
@property (nonatomic, readonly) NSArray<TransactionType> *allTransactions;
/// Equal to \c allTransactions if not filtered
@property (nonatomic, readonly) NSArray<TransactionType> *filteredTransactions;

/// Use this instead of either of the other two as it updates based on whether we have a filter or not
@property (nonatomic) NSInteger bytesReceived;
@property (nonatomic) NSInteger totalBytesReceived;
/// Equal to \c totalBytesReceived if not filtered
@property (nonatomic) NSInteger filteredBytesReceived;

- (void)reloadByteCounts;
- (void)reloadData:(void (^_Nullable)(FLEXMITMDataSource *dataSource))completion;
- (void)filter:(NSString *)searchString completion:(void(^_Nullable)(FLEXMITMDataSource *dataSource))completion;

@end

NS_ASSUME_NONNULL_END
