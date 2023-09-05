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
//  FHSViewSnapshot.h
//  FLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FHSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSViewSnapshot : NSObject

+ (instancetype)snapshotWithView:(FHSView *)view;

@property (nonatomic, readonly) FHSView *view;

@property (nonatomic, readonly) NSString *title;
/// Whether or not this view item should be visually distinguished
@property (nonatomic, readwrite) BOOL important;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) BOOL hidden;
@property (nonatomic, readonly) UIImage *snapshotImage;

@property (nonatomic, readonly) NSArray<FHSViewSnapshot *> *children;
@property (nonatomic, readonly) NSString *summary;

/// Returns a different color based on whether or not the view is important
@property (nonatomic, readonly) UIColor *headerColor;

- (FHSViewSnapshot *)snapshotForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
