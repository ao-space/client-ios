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
#import "ESActionSheetButton.h"

@interface ESActionSheetView : UIView
/** 取消按钮的高度 默认44 */
@property (assign, nonatomic) CGFloat cancelBtnHeight;
/** 取消按钮上下的间隙 默认为8 */
@property (assign, nonatomic) CGFloat cancelBtnTopAndBottomMargin;
/** 分割线高度 默认2 */
@property (assign, nonatomic) CGFloat seperatorHeight;
/** 左右的间隙 默认20 */
@property (assign, nonatomic) CGFloat leftAndRightMargin;
/** 圆角半径 默认10 */
@property (assign, nonatomic) CGFloat cornerRadius;
/** 取消按钮, 可自定义属性 */
@property (strong, nonatomic, readonly) ESActionSheetButton *cancelBtn;

/** 提示文字label, 可自定义属性 */
@property (strong, nonatomic, readonly) UILabel *titleLabel;
/** 详细文字label, 可自定义属性 */
@property (strong, nonatomic, readonly) UILabel *subtitleLabel;

@property (strong, nonatomic, readonly) UILabel *messageLabel;

/**
 *  初始化方法
 *
 *  @param title              title
 *  @param subtitle           subtitle
 *  @param actionSheetButtons actionSheetButtons
 *
 *  @return return value description
 */
- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
           actionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons;

/**
 *  初始化方法 无标题提示
 *
 *  @param actionSheetButtons actionSheetButtons description
 *
 *  @return return value description
 */
- (instancetype)initWithActionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons;


- (instancetype)initWithTitle:(NSAttributedString *)title
                     subtitle:(NSAttributedString *)subtitle
                      message:(NSAttributedString *)message
           actionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons;

- (void)leftAlignmentStyle;

/**
 *  弹出ActionSheet
 */
- (void)show;
/**
 *  移除ActionSheet
 */
- (void)hide;
@end
