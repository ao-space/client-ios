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
//  FHSViewSnapshot.m
//  FLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FHSViewSnapshot.h"
#import "NSArray+FLEX.h"

@implementation FHSViewSnapshot

+ (instancetype)snapshotWithView:(FHSView *)view {
    NSArray *children = [view.children flex_mapped:^id(FHSView *v, NSUInteger idx) {
        return [self snapshotWithView:v];
    }];
    return [[self alloc] initWithView:view children:children];
}

- (id)initWithView:(FHSView *)view children:(NSArray<FHSViewSnapshot *> *)children {
    NSParameterAssert(view); NSParameterAssert(children);

    self = [super init];
    if (self) {
        _view = view;
        _title = view.title;
        _important = view.important;
        _frame = view.frame;
        _hidden = view.hidden;
        _snapshotImage = view.snapshotImage;
        _children = children;
        _summary = view.summary;
    }

    return self;
}

- (UIColor *)headerColor {
    if (self.important) {
        return [UIColor colorWithRed: 0.000 green: 0.533 blue: 1.000 alpha: 0.900];
    } else {
        return [UIColor colorWithRed:0.961 green: 0.651 blue: 0.137 alpha: 0.900];
    }
}

- (FHSViewSnapshot *)snapshotForView:(UIView *)view {
    if (view == self.view.view) {
        return self;
    }

    for (FHSViewSnapshot *child in self.children) {
        FHSViewSnapshot *snapshot = [child snapshotForView:view];
        if (snapshot) {
            return snapshot;
        }
    }

    return nil;
}

@end
