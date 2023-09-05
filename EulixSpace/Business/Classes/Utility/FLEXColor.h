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
//  FLEXColor.h
//  FLEX
//
//  Created by Benny Wong on 6/18/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXColor : NSObject

@property (readonly, class) UIColor *primaryBackgroundColor;
+ (UIColor *)primaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *secondaryBackgroundColor;
+ (UIColor *)secondaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *tertiaryBackgroundColor;
+ (UIColor *)tertiaryBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *groupedBackgroundColor;
+ (UIColor *)groupedBackgroundColorWithAlpha:(CGFloat)alpha;

@property (readonly, class) UIColor *secondaryGroupedBackgroundColor;
+ (UIColor *)secondaryGroupedBackgroundColorWithAlpha:(CGFloat)alpha;

// Text colors
@property (readonly, class) UIColor *primaryTextColor;
@property (readonly, class) UIColor *deemphasizedTextColor;

// UI element colors
@property (readonly, class) UIColor *tintColor;
@property (readonly, class) UIColor *scrollViewBackgroundColor;
@property (readonly, class) UIColor *iconColor;
@property (readonly, class) UIColor *borderColor;
@property (readonly, class) UIColor *toolbarItemHighlightedColor;
@property (readonly, class) UIColor *toolbarItemSelectedColor;
@property (readonly, class) UIColor *hairlineColor;
@property (readonly, class) UIColor *destructiveColor;

@end

NS_ASSUME_NONNULL_END
