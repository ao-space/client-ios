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
//  ESBaseTableListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseTableListModule.h"
#import "ESBaseCell.h"
#import "ESBaseViewController+Status.h"
#import "ESBaseTableVC.h"

@interface ESBaseTableListModule ()

@property (nonatomic, strong) NSArray *listData;

@end

@implementation ESBaseTableListModule

- (void)reloadData:(NSArray *)listData {
    self.listData = listData;
 
    [self.tableVC showEmpty:self.listData.count == 0];
    [self.listView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self defalutActionHeight];
}

- (CGFloat)defalutActionHeight {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:
                        [self cellResuableIdentifierWithIndexPath:indexPath]];
    if (cell == nil) {
        cell = [self cellForRowAtIndexPath:indexPath];
    }

    id data = [self bindDataForRowAtIndexPath:indexPath];
    if (data) {
        [self beforeBindData:data cell:cell forRowAtIndexPath:indexPath];
        [cell bindData:data];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell hiddenSeparatorStyleSingleLine:![self showSeparatorStyleSingleLineWithIndex:indexPath]];
    return cell;
}

- (ESBaseCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [[[self cellClassForRowAtIndexPath:indexPath] alloc] initWithStyle:UITableViewCellStyleDefault
                                                               reuseIdentifier:[self cellResuableIdentifierWithIndexPath:indexPath]];
}

- (void)beforeBindData:(id _Nullable)data cell:(ESBaseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return YES;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listData.count > indexPath.row) {
        return self.listData[indexPath.row];
    }
    return nil;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESBaseCell class];
}

- (NSString *)cellResuableIdentifierWithIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassForRowAtIndexPath:indexPath];
    return NSStringFromClass(cellClass);
}
@end
