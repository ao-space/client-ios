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
//  UIBarButtonItem+FLEX.h
//  FLEX
//
//  Created by Tanner on 2/4/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FLEXBarButtonItem(title, tgt, sel) \
    [UIBarButtonItem flex_itemWithTitle:title target:tgt action:sel]
#define FLEXBarButtonItemSystem(item, tgt, sel) \
    [UIBarButtonItem flex_systemItem:UIBarButtonSystemItem##item target:tgt action:sel]

@interface UIBarButtonItem (FLEX)

@property (nonatomic, readonly, class) UIBarButtonItem *flex_flexibleSpace;
@property (nonatomic, readonly, class) UIBarButtonItem *flex_fixedSpace;

+ (instancetype)flex_itemWithCustomView:(UIView *)customView;
+ (instancetype)flex_backItemWithTitle:(NSString *)title;

+ (instancetype)flex_systemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action;

+ (instancetype)flex_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)flex_doneStyleitemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)flex_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)flex_disabledSystemItem:(UIBarButtonSystemItem)item;
+ (instancetype)flex_disabledItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;
+ (instancetype)flex_disabledItemWithImage:(UIImage *)image;

/// @return the receiver
- (UIBarButtonItem *)flex_withTintColor:(UIColor *)tint;

- (void)_setWidth:(CGFloat)width;

@end
