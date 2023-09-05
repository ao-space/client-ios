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
//  ESPinCodeTextField.h
//  EulixSpace
//
//  Created by dazhou on 2023/2/23.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESPinCodeTextFieldStyle) {
    ESPinCodeTextFieldStyle_Line = 0,// 默认是下划线样式
    ESPinCodeTextFieldStyle_Box, // 带4个单位圆角的方框样式
    ESPinCodeTextFieldStyle_Dot,  //带圆点样式
};

NS_ASSUME_NONNULL_BEGIN

// 移植于 KKPinCodeTextField，主要修改点在于密文输入时，密文位置的计算方式
/// TextField for verification codes
@interface ESPinCodeTextField : UITextField

/// Verification code length. Default value is 4
@property (assign, nonatomic) IBInspectable NSUInteger digitsCount;

/// Bottom borders height. Default value is 4
@property (assign, nonatomic) IBInspectable CGFloat borderHeight;

/// Spacing between bottom borders. Default value is 10
@property (assign, nonatomic) IBInspectable CGFloat bordersSpacing;

/// Bottom border color when digit is filled. Default value is UIColor.lightGrayColor
@property (strong, nonatomic) IBInspectable UIColor *filledDigitBorderColor;

/// Bottom border color when digit is empty. Default value is UIColor.redColor
@property (strong, nonatomic) IBInspectable UIColor *emptyDigitBorderColor;

@property (nonatomic, assign) ESPinCodeTextFieldStyle tfStyle;
// Default value is 0
@property (nonatomic, assign) CGFloat borderCornerRadius;
/// Clears all text
- (void)clearText;

@end

NS_ASSUME_NONNULL_END
