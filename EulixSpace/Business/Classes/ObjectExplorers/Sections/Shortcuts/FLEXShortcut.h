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
//  FLEXShortcut.h
//  FLEX
//
//  Created by Tanner Bennett on 12/10/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXObjectExplorer.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents a row in a shortcut section.
///
/// The purpsoe of this protocol is to allow delegating a small
/// subset of the responsibilities of a \c FLEXShortcutsSection
/// to another object, for a single arbitrary row.
///
/// It is useful to make your own shortcuts to append/prepend
/// them to the existing list of shortcuts for a class.
@protocol FLEXShortcut <FLEXObjectExplorerItem>

- (nonnull  NSString *)titleWith:(id)object;
- (nullable NSString *)subtitleWith:(id)object;
- (nullable void (^)(UIViewController *host))didSelectActionWith:(id)object;
/// Called when the row is selected
- (nullable UIViewController *)viewerWith:(id)object;
/// Basically, whether or not to show a detail disclosure indicator
- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object;
/// If nil is returned, the default reuse identifier is used
- (nullable NSString *)customReuseIdentifierWith:(id)object;

@optional
/// Called when the (i) button is pressed if the accessory type includes it
- (UIViewController *)editorWith:(id)object forSection:(FLEXTableViewSection *)section;

@end


/// Provides default behavior for FLEX metadata objects. Also works in a limited way with strings.
/// Used internally. If you wish to use this object, only pass in \c FLEX* metadata objects.
@interface FLEXShortcut : NSObject <FLEXShortcut>

/// @param item An \c NSString or \c FLEX* metadata object.
/// @note You may also pass a \c FLEXShortcut conforming object,
/// and that object will be returned instead.
+ (id<FLEXShortcut>)shortcutFor:(id)item;

@end


/// Provides a quick and dirty implementation of the \c FLEXShortcut protocol,
/// allowing you to specify a static title and dynamic atttributes for everything else.
/// The object passed into each block is the object passed to each \c FLEXShortcut method.
///
/// Does not support the \c -editorWith: method.
@interface FLEXActionShortcut : NSObject <FLEXShortcut>

+ (instancetype)title:(NSString *)title
             subtitle:(nullable NSString *(^)(id object))subtitleFuture
               viewer:(nullable UIViewController *(^)(id object))viewerFuture
        accessoryType:(nullable UITableViewCellAccessoryType(^)(id object))accessoryTypeFuture;

+ (instancetype)title:(NSString *)title
             subtitle:(nullable NSString *(^)(id object))subtitleFuture
     selectionHandler:(nullable void (^)(UIViewController *host, id object))tapAction
        accessoryType:(nullable UITableViewCellAccessoryType(^)(id object))accessoryTypeFuture;

@end

NS_ASSUME_NONNULL_END
