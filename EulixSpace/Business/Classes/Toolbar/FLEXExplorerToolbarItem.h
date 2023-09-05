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
//  FLEXExplorerToolbarItem.h
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXExplorerToolbarItem : UIButton

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image;

/// @param backupItem a toolbar item to use in place of this item when it becomes disabled.
/// Items without a sibling item exhibit expected behavior when they become disabled, and are greyed out.
+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image sibling:(nullable FLEXExplorerToolbarItem *)backupItem;

/// If a toolbar item has a sibling, the item will replace itself with its
/// sibling when it becomes disabled, and vice versa when it becomes enabled again.
@property (nonatomic, readonly) FLEXExplorerToolbarItem *sibling;

/// When a toolbar item has a sibling and it becomes disabled, the sibling is the view
/// that should be added to or removed from a new or existing toolbar. This property
/// alleviates the programmer from determining whether to use \c item or \c item.sibling
/// or \c item.sibling.sibling and so on. Yes, sibling items can also have siblings so
/// that each item which becomes disabled may present another item in its place, creating
/// a "stack" of toolbar items. This behavior is useful for making buttons which occupy
/// the same space under different states.
///
/// With this in mind, you should never access a stored toolbar item's view properties
/// such as \c frame or \c superview directly; you should access them on \c currentItem.
/// If you are trying to modify the frame of an item, and the item itself is not currently
/// displayed but instead its sibling is being displayed, then your changes could be ignored.
///
/// @return the result of the item's sibling's \c currentItem,
/// if this item has a sibling and this item is disabled, otherwise this item.
@property (nonatomic, readonly) FLEXExplorerToolbarItem *currentItem;

@end

NS_ASSUME_NONNULL_END
