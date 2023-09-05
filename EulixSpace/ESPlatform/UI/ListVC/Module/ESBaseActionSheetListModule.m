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
//  ESBaseActionSheetListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseActionSheetListModule.h"
#import "ESActionSheetItem.h"
#import "ESActionSheetHeadCell.h"

@interface ESBaseTableListModule ()

@property (nonatomic, strong) NSArray *listData;

@end

@implementation ESBaseActionSheetListModule

- (void)reloadData:(NSArray *)listData {
    self.listData = listData;
 
    [self.listView reloadData];
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    if (indexPath.row == self.listData.count - 1) {
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.listData.count && [self.listData[indexPath.row] isKindOfClass:[ESActionSheetItem class]]) {
        ESActionSheetItem *item = self.listData[indexPath.row];
        if (item.isSectionHeader) {
            return 30;
        }
    }
    return [self defalutActionHeight];
}

- (CGFloat)defalutActionHeight {
    return 30;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.listData.count && [self.listData[indexPath.row] isKindOfClass:[ESActionSheetItem class]]) {
        ESActionSheetItem *item = self.listData[indexPath.row];
        if (item.isSectionHeader) {
            return [ESActionSheetHeadCell class];
        }
    }
    return [ESActionSheetCell class];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.listData.count) {
        ESActionSheetItem *item = self.listData[indexPath.row];
        if (item.isSectionHeader) {
            return;
        }
    
        if (item.isSelectedTyple) {
            [self.listData enumerateObjectsUsingBlock:^(ESActionSheetItem  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.isSelectedTyple) {
                    obj.isSelected = NO;
                }
            }];
            item.isSelected = YES;
            [self.listView reloadData];
        }
        
        if (item.canSelectedType == NO) {
            return;
        }
        
        if (item.nextStep) {
            [self.actionSheetVC hidden:YES];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.actionSheetVC hidden:NO];
            });
        }
        
        NSInteger selectIndex = indexPath.row;
        __block NSInteger sectionCountBeforeSelectIndex = 0;
        [self.listData enumerateObjectsUsingBlock:^(ESActionSheetItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (item.isSectionHeader && idx <= selectIndex) {
                sectionCountBeforeSelectIndex++;
            }
            if (idx > selectIndex) {
                *stop = YES;
            }
        }];
        
        if ([self.actionSheetVC.delegate respondsToSelector:@selector(actionSheet:didMenuSelectItem:rowAtIndexPath:)]) {
            [self.actionSheetVC.delegate actionSheet:self.actionSheetVC didMenuSelectItem:item rowAtIndexPath:MAX(0, (selectIndex - sectionCountBeforeSelectIndex))];
        }
    }
}

@end
