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
//  FLEXMITMDataSource.m
//  FLEX
//
//  Created by Tanner Bennett on 8/22/21.
//

#import "FLEXMITMDataSource.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXUtility.h"

@interface FLEXMITMDataSource ()
@property (nonatomic, readonly) NSArray *(^dataProvider)(void);
@property (nonatomic) NSString *filterString;
@end

@implementation FLEXMITMDataSource

+ (instancetype)dataSourceWithProvider:(NSArray<id> *(^)(void))future {
    FLEXMITMDataSource *ds = [self new];
    ds->_dataProvider = future;
    [ds reloadData:nil];
    
    return ds;
}

- (BOOL)isFiltered {
    return self.filterString.length > 0;
}

- (NSArray *)transactions {
    return _filteredTransactions;
}

- (NSInteger)bytesReceived {
    return _filteredBytesReceived;
}

- (void)reloadByteCounts {
    [self updateBytesReceived];
    [self updateFilteredBytesReceived];
}

- (void)reloadData:(void (^)(FLEXMITMDataSource *dataSource))completion {
    self.allTransactions = self.dataProvider();
    [self filter:self.filterString completion:completion];
}

- (void)filter:(NSString *)searchString completion:(void (^)(FLEXMITMDataSource *dataSource))completion {
    self.filterString = searchString;
    
    if (!searchString.length) {
        self.filteredTransactions = self.allTransactions;
        if (completion) completion(self);
    } else {
        NSArray<FLEXNetworkTransaction *> *allTransactions = self.allTransactions.copy;
        [self onBackgroundQueue:^NSArray *{
            return [allTransactions flex_filtered:^BOOL(FLEXNetworkTransaction *entry, NSUInteger idx) {
                return [entry matchesQuery:searchString];
            }];
        } thenOnMainQueue:^(NSArray *filteredNetworkTransactions) {
            if ([self.filterString isEqual:searchString]) {
                self.filteredTransactions = filteredNetworkTransactions;
                if (completion) completion(self);
            }
        }];
    }
}

- (void)setAllTransactions:(NSArray *)transactions {
    _allTransactions = transactions;
    [self updateBytesReceived];
}

- (void)setFilteredTransactions:(NSArray *)filteredTransactions {
    _filteredTransactions = filteredTransactions;
    [self updateFilteredBytesReceived];
}

- (void)updateBytesReceived {
    NSInteger bytesReceived = 0;
    for (FLEXNetworkTransaction *transaction in self.transactions) {
        bytesReceived += transaction.receivedDataLength;
    }
    
    self.bytesReceived = bytesReceived;
}

- (void)updateFilteredBytesReceived {
    NSInteger filteredBytesReceived = 0;
    for (FLEXNetworkTransaction *transaction in self.filteredTransactions) {
        filteredBytesReceived += transaction.receivedDataLength;
    }
    
    self.filteredBytesReceived = filteredBytesReceived;
}

- (void)onBackgroundQueue:(NSArray *(^)(void))backgroundBlock thenOnMainQueue:(void(^)(NSArray *))mainBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *items = backgroundBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            mainBlock(items);
        });
    });
}

@end
