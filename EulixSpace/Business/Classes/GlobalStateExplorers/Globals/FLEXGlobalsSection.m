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
//  FLEXGlobalsSection.m
//  FLEX
//
//  Created by Tanner Bennett on 7/11/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXGlobalsSection.h"
#import "NSArray+FLEX.h"
#import "UIFont+FLEX.h"

@interface FLEXGlobalsSection ()
/// Filtered rows
@property (nonatomic) NSArray<FLEXGlobalsEntry *> *rows;
/// Unfiltered rows
@property (nonatomic) NSArray<FLEXGlobalsEntry *> *allRows;
@end
@implementation FLEXGlobalsSection

#pragma mark - Initialization

+ (instancetype)title:(NSString *)title rows:(NSArray<FLEXGlobalsEntry *> *)rows {
    FLEXGlobalsSection *s = [self new];
    s->_title = title;
    s.allRows = rows;

    return s;
}

- (void)setAllRows:(NSArray<FLEXGlobalsEntry *> *)allRows {
    _allRows = allRows.copy;
    [self reloadData];
}

#pragma mark - Overrides

- (NSInteger)numberOfRows {
    return self.rows.count;
}

- (void)setFilterText:(NSString *)filterText {
    super.filterText = filterText;
    [self reloadData];
}

- (void)reloadData {
    NSString *filterText = self.filterText;
    
    if (filterText.length) {
        self.rows = [self.allRows flex_filtered:^BOOL(FLEXGlobalsEntry *entry, NSUInteger idx) {
            return [entry.entryNameFuture() localizedCaseInsensitiveContainsString:filterText];
        }];
    } else {
        self.rows = self.allRows;
    }
}

- (BOOL)canSelectRow:(NSInteger)row {
    return YES;
}

- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    return (id)self.rows[row].rowAction;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return self.rows[row].viewControllerFuture ? self.rows[row].viewControllerFuture() : nil;
}

- (void)configureCell:(__kindof UITableViewCell *)cell forRow:(NSInteger)row {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = UIFont.flex_defaultTableCellFont;
    cell.textLabel.text = self.rows[row].entryNameFuture();
}

@end


@implementation FLEXGlobalsSection (Subscripting)

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.rows[idx];
}

@end
