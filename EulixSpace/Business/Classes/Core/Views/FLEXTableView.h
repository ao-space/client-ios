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
//  FLEXTableView.h
//  FLEX
//
//  Created by Tanner on 4/17/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark Reuse identifiers

typedef NSString * FLEXTableViewCellReuseIdentifier;

/// A regular \c FLEXTableViewCell initialized with \c UITableViewCellStyleDefault
extern FLEXTableViewCellReuseIdentifier const kFLEXDefaultCell;
/// A \c FLEXSubtitleTableViewCell initialized with \c UITableViewCellStyleSubtitle
extern FLEXTableViewCellReuseIdentifier const kFLEXDetailCell;
/// A \c FLEXMultilineTableViewCell initialized with \c UITableViewCellStyleDefault
extern FLEXTableViewCellReuseIdentifier const kFLEXMultilineCell;
/// A \c FLEXMultilineTableViewCell initialized with \c UITableViewCellStyleSubtitle
extern FLEXTableViewCellReuseIdentifier const kFLEXMultilineDetailCell;
/// A \c FLEXTableViewCell initialized with \c UITableViewCellStyleValue1
extern FLEXTableViewCellReuseIdentifier const kFLEXKeyValueCell;
/// A \c FLEXSubtitleTableViewCell which uses monospaced fonts for both labels
extern FLEXTableViewCellReuseIdentifier const kFLEXCodeFontCell;

#pragma mark - FLEXTableView
@interface FLEXTableView : UITableView

+ (instancetype)flexDefaultTableView;
+ (instancetype)groupedTableView;
+ (instancetype)plainTableView;
+ (instancetype)style:(UITableViewStyle)style;

/// You do not need to register classes for any of the default reuse identifiers above
/// (annotated as \c FLEXTableViewCellReuseIdentifier types) unless you wish to provide
/// a custom cell for any of those reuse identifiers. By default, \c FLEXTableViewCell,
/// \c FLEXSubtitleTableViewCell, and \c FLEXMultilineTableViewCell are used, respectively.
///
/// @param registrationMapping A map of reuse identifiers to \c UITableViewCell (sub)class objects.
- (void)registerCells:(NSDictionary<NSString *, Class> *)registrationMapping;

@end

NS_ASSUME_NONNULL_END
