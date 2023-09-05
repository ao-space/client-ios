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
//  FLEXSingleRowSection.m
//  FLEX
//
//  Created by Tanner Bennett on 9/25/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXSingleRowSection.h"
#import "FLEXTableView.h"

@interface FLEXSingleRowSection ()
@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) void (^cellConfiguration)(__kindof UITableViewCell *cell);

@property (nonatomic) NSString *lastTitle;
@property (nonatomic) NSString *lastSubitle;
@end

@implementation FLEXSingleRowSection

#pragma mark - Public

+ (instancetype)title:(NSString *)title
                reuse:(NSString *)reuse
                 cell:(void (^)(__kindof UITableViewCell *))config {
    return [[self alloc] initWithTitle:title reuse:reuse cell:config];
}

- (id)initWithTitle:(NSString *)sectionTitle
              reuse:(NSString *)reuseIdentifier
               cell:(void (^)(__kindof UITableViewCell *))cellConfiguration {
    self = [super init];
    if (self) {
        _title = sectionTitle;
        _reuseIdentifier = reuseIdentifier ?: kFLEXDefaultCell;
        _cellConfiguration = cellConfiguration;
    }

    return self;
}

#pragma mark - Overrides

- (NSInteger)numberOfRows {
    if (self.filterMatcher && self.filterText.length) {
        return self.filterMatcher(self.filterText) ? 1 : 0;
    }
    
    return 1;
}

- (BOOL)canSelectRow:(NSInteger)row {
    return self.pushOnSelection || self.selectionAction;
}

- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    return self.selectionAction;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return self.pushOnSelection;
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    return self.reuseIdentifier;
}

- (void)configureCell:(__kindof UITableViewCell *)cell forRow:(NSInteger)row {
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    self.cellConfiguration(cell);
    self.lastTitle = cell.textLabel.text;
    self.lastSubitle = cell.detailTextLabel.text;
}

- (NSString *)titleForRow:(NSInteger)row {
    return self.lastTitle;
}

- (NSString *)subtitleForRow:(NSInteger)row {
    return self.lastSubitle;
}

@end
