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



#import <UIKit/UIKit.h>
@class ESActionSheetView;
@class ESActionSheetButton;
typedef void(^ZJActionSheetSystemHandler)(ESActionSheetView *actionSheet, ESActionSheetButton *actionSheetButton);
@interface ESActionSheetButton : UIButton

/** 按钮的titleLabel 可自定义属性 */
@property (strong, nonatomic, readonly) UILabel *textLabel;
/** 点击响应 */
@property (copy, nonatomic) ZJActionSheetSystemHandler handler;
/** 按钮的高度 默认44 */
@property (assign, nonatomic) CGFloat btnHeight;
/** 文字的颜色 默认黑色 */
@property (strong, nonatomic) UIColor *titleColor;

/**
 *  初始化方法
 *
 *  @param title      title
 *  @param image      image
 *  @param titleColor titleColor
 *  @param handler    点击处理
 *
 *  @return return value description
 */
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image titleColor:(UIColor *)titleColor handler:(ZJActionSheetSystemHandler)handler;

/**
 *  初始化方法
 *
 *  @param title      title
 *  @param titleColor titleColor
 *  @param handler    点击处理
 *
 *  @return return value description
 */
- (instancetype)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor handler:(ZJActionSheetSystemHandler)handler;
/**
 *  初始化方法, 字体颜色默认为 黑色
 *
 *  @param title   title description
 *  @param handler 点击处理
 *
 *  @return return value description
 */
- (instancetype)initWithTitle:(NSString *)title handler:(ZJActionSheetSystemHandler)handler;

@end
