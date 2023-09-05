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
//  ESColor.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESColor : NSObject

+ (UIColor *)colorWithHex:(unsigned long)hexValue;
//
+ (UIColor *)colorWithHex:(unsigned long)hexValue alpha:(CGFloat)alpha;

/// 渐变1
@property (class, nonatomic, readonly) UIColor *primaryColor;
/// 渐变2
@property (class, nonatomic, readonly) UIColor *secondaryPrimaryColor;

@property (class, nonatomic, readonly) UIColor *clearColor;

#pragma mark Foreground colors
/// Label主
@property (class, nonatomic, readonly) UIColor *labelColor;

/// 按钮不可点击
@property (class, nonatomic, readonly) UIColor *grayColor;

/// Label次
@property (class, nonatomic, readonly) UIColor *secondaryLabelColor;

/// 空白页title
@property (class, nonatomic, readonly) UIColor *blankSpaceColor;

/// 占位符颜色
@property (class, nonatomic, readonly) UIColor *placeholderTextColor;

/// 分割线颜色
@property (class, nonatomic, readonly) UIColor *separatorColor;

/// main
@property (class, nonatomic, readonly) UIColor *grayLabelColor;

#pragma mark Background colors

/// 主背景
@property (class, nonatomic, readonly) UIColor *systemBackgroundColor;

@property (class, nonatomic, readonly) UIColor *secondarySystemBackgroundColor;
@property (class, nonatomic, readonly) UIColor *tertiarySystemBackgroundColor;
@property (class, nonatomic, readonly) UIColor *disableSystemBackgroundColor;

#pragma mark Other colors
/// 纯白背景
@property (class, nonatomic, readonly) UIColor *lightTextColor;

/// 纯黑背景
@property (class, nonatomic, readonly) UIColor *darkTextColor;
@property (class, nonatomic, readonly) UIColor *disableTextColor;
@property (class, nonatomic, readonly) UIColor *redColor;
@property (class, nonatomic, readonly) UIColor *greenColor;

@property (class, nonatomic, readonly) UIColor *yellowColor;

@property (class, nonatomic, readonly) UIColor *grayBgColor;

@property (class, nonatomic, readonly) UIColor *downGreenColor;

@property (class, nonatomic, readonly) UIColor *searchLabelColor;

@property (class, nonatomic, readonly) UIColor *grayPointColor;


#pragma mark - light dark Style

+ (BOOL)isLighterColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (BOOL)isLighterColor:(UIColor *)color;
+ (BOOL)isLighterColorWithHXB:(NSInteger)hexColor;

@property (class, nonatomic, readonly) UIColor *pushBgColor;

@property (class, nonatomic, readonly) UIColor *pushTitleColor;

@property (class, nonatomic, readonly) UIColor *btnBgColor;

@property (class, nonatomic, readonly) UIColor *newsListBg;

@property (class, nonatomic, readonly) UIColor *newsListTimeColor;

@property (class, nonatomic, readonly) UIColor *iconBg;

@property (class, nonatomic, readonly) UIColor *searchTitleColor;

@property (class, nonatomic, readonly) UIColor *btnBuleColor;

@property (class, nonatomic, readonly) UIColor *searchBuleColor;


@end
