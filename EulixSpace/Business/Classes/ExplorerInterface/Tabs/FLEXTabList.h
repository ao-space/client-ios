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
//  FLEXTabList.h
//  FLEX
//
//  Created by Tanner on 2/1/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXTabList : NSObject

@property (nonatomic, readonly, class) FLEXTabList *sharedList;

@property (nonatomic, readonly, nullable) UINavigationController *activeTab;
@property (nonatomic, readonly) NSArray<UINavigationController *> *openTabs;
/// Snapshots of each tab when they were last active.
@property (nonatomic, readonly) NSArray<UIImage *> *openTabSnapshots;
/// \c NSNotFound if no tabs are present.
/// Setting this property changes the active tab to one of the already open tabs.
@property (nonatomic) NSInteger activeTabIndex;

/// Adds a new tab and sets the new tab as the active tab.
- (void)addTab:(UINavigationController *)newTab;
/// Closes the given tab. If this tab was the active tab,
/// the most recent tab before that becomes the active tab.
- (void)closeTab:(UINavigationController *)tab;
/// Closes a tab at the given index. If this tab was the active tab,
/// the most recent tab before that becomes the active tab.
- (void)closeTabAtIndex:(NSInteger)idx;
/// Closes all of the tabs at the given indexes. If the active tab
/// is included, the most recent still-open tab becomes the active tab.
- (void)closeTabsAtIndexes:(NSIndexSet *)indexes;
/// A shortcut to close the active tab.
- (void)closeActiveTab;
/// A shortcut to close \e every tab.
- (void)closeAllTabs;

- (void)updateSnapshotForActiveTab;

@end

NS_ASSUME_NONNULL_END
