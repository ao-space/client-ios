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
//  UIButton+Extension.h
//  EulixSpace
//
//  Created by qudanjiang on 2021/5/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief  Button延展
 */
typedef NS_ENUM(NSInteger, SCEUIButtonLayoutStyle) {
    SCEImageLeftTitleRightStyle = 0, // 默认的方式 image左 title右
    SCETitleLeftImageRightStyle = 1, // image右,title左
    SCEImageTopTitleBootomStyle = 2, // image上，title下
    SCETitleTopImageBootomStyle = 3, // image下,title上
};

@interface UIButton (Extension)

#pragma mark - init

- (void)sc_setLayout:(SCEUIButtonLayoutStyle)aLayoutStyle
             spacing:(CGFloat)aFloatSpacing;

+ (UIButton *)es_create:(NSString *)title
                font:(UIFont *)font
             txColor:(NSString *)txColor
             bgColor:(NSString *)bgColor
              target:(id)target
            selector:(SEL)selector;

- (void)setEsCornerRadius:(CGFloat)cornerRadius;

@end
