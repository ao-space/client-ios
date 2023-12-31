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
//  FLEXMutableListSection.m
//  FLEX
//
//  Created by Tanner on 3/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXMutableListSection.h"
#import "FLEXMacros.h"

@interface FLEXMutableListSection ()
@property (nonatomic, readonly) FLEXMutableListCellForElement configureCell;
@end

@implementation FLEXMutableListSection
@synthesize cellRegistrationMapping = _cellRegistrationMapping;

#pragma mark - Initialization

+ (instancetype)list:(NSArray *)list
   cellConfiguration:(FLEXMutableListCellForElement)cellConfig
       filterMatcher:(BOOL(^)(NSString *, id))filterBlock {
    return [[self alloc] initWithList:list configurationBlock:cellConfig filterMatcher:filterBlock];
}

- (id)initWithList:(NSArray *)list
configurationBlock:(FLEXMutableListCellForElement)cellConfig
     filterMatcher:(BOOL(^)(NSString *, id))filterBlock {
    self = [super init];
    if (self) {
        _configureCell = cellConfig;

        self.list = list.mutableCopy;
        self.customFilter = filterBlock;
        self.hideSectionTitle = YES;
    }

    return self;
}


#pragma mark - Public

- (NSArray *)list {
    return (id)_collection;
}

- (void)setList:(NSMutableArray *)list {
    NSParameterAssert(list);
    _collection = (id)list;

    [self reloadData];
}

- (NSArray *)filteredList {
    return (id)_cachedCollection;
}

- (void)mutate:(void (^)(NSMutableArray *))block {
    block((NSMutableArray *)_collection);
    [self reloadData];
}


#pragma mark - Overrides

- (void)setCustomTitle:(NSString *)customTitle {
    super.customTitle = customTitle;
    self.hideSectionTitle = customTitle == nil;
}

- (BOOL)canSelectRow:(NSInteger)row {
    return self.selectionHandler != nil;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return nil;
}

- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    if (self.selectionHandler) { weakify(self)
        return ^(UIViewController *host) { strongify(self)
            if (self) {
                self.selectionHandler(host, self.filteredList[row]);
            }
        };
    }

    return nil;
}

- (void)configureCell:(__kindof UITableViewCell *)cell forRow:(NSInteger)row {
    self.configureCell(cell, self.filteredList[row], row);
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    if (self.cellRegistrationMapping.count) {
        return self.cellRegistrationMapping.allKeys.firstObject;
    }

    return [super reuseIdentifierForRow:row];
}

- (void)setCellRegistrationMapping:(NSDictionary<NSString *,Class> *)cellRegistrationMapping {
    NSParameterAssert(cellRegistrationMapping.count <= 1);
    _cellRegistrationMapping = cellRegistrationMapping;
}

@end
