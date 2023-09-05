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
//  UIView+ESTool.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ESTool)

- (UIView *)es_addline:(CGFloat)margin;

- (UIView *)es_addline:(CGFloat)margin offset:(CGFloat)offset;

- (UIView *)es_addline:(CGFloat)margin offset:(CGFloat)offset vertical:(BOOL)vertical;

// 默认是 背景为白，圈圈为蓝色 加载动效
- (UIView *)showLoadingView;
- (UIView *)showLoadingView:(NSString *)text;
- (UIView *)showLoadingFailedView:(NSString *)text image:(NSString *)imageName;

- (void)removeLoadingView;

- (UIViewController *)es_getController;

+ (UIView *)es_sloganView:(NSString *)title;
+ (UIView *)es_create:(NSString *)color radius:(float)radius;
@end

@interface ESViewBuilder : NSObject

@property (class, nonatomic, readonly) ESViewBuilder * (^label)(NSString *text);

@property (nonatomic, readonly) ESViewBuilder * (^fontSize)(CGFloat fontSize);

@property (nonatomic, readonly) ESViewBuilder * (^fontWeight)(UIFontWeight fontWeight);

@property (nonatomic, readonly) ESViewBuilder * (^textColor)(UIColor *textColor);

//@property (nonatomic, readonly) __kindof UIView * (^build)(void);

@property (nonatomic, readonly) __kindof UIView * (^build)(UIView *superView);

@end
