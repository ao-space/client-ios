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
//  FHSViewController.h
//  FLEX
//
//  Created by Tanner Bennett on 1/6/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// The view controller
/// "FHS" stands for "FLEX (view) hierarchy snapshot"
@interface FHSViewController : UIViewController

/// Use this when you want to snapshot a set of windows.
+ (instancetype)snapshotWindows:(NSArray<UIWindow *> *)windows;
/// Use this when you want to snapshot a specific slice of the view hierarchy.
+ (instancetype)snapshotView:(UIView *)view;
/// Use this when you want to emphasize specific views on the screen.
/// These views must all be in the same window as the selected view.
+ (instancetype)snapshotViewsAtTap:(NSArray<UIView *> *)viewsAtTap selectedView:(UIView *)view;

@property (nonatomic, nullable) UIView *selectedView;

@end

NS_ASSUME_NONNULL_END
