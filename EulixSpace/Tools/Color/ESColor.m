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
//  ESColor.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESColor.h"

static inline UIColor *COLOR_COMPATIBILITY(unsigned long dark, unsigned long light) {
    UIColor *color = [ESColor colorWithHex:light];
    if (@available(iOS 13, *)) {
        color = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [ESColor colorWithHex:dark];
            }
            return [ESColor colorWithHex:light];
        }];
    }
    return color;
}

@implementation ESColor

+ (UIColor *)colorWithHex:(unsigned long)hexValue alpha:(CGFloat)alpha {
    CGFloat red = ((hexValue & 0xFF0000) >> 16);
    CGFloat green = ((hexValue & 0x00FF00) >> 8);
    CGFloat blue = ((hexValue & 0x0000FF) >> 0);
    alpha = MIN(alpha, 1);
    alpha = MAX(0, alpha);
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithHex:(unsigned long)hexValue {
    CGFloat alpha = 1;
    if (hexValue > 0xFFFFFF) {
        alpha = ((hexValue & 0xFF000000) >> 24) / 255.0;
    }
    return [self colorWithHex:hexValue alpha:alpha];
}

+ (UIColor *)primaryColor {
    return COLOR_COMPATIBILITY(0xFF337AFF, 0xFF337AFF);
}

+ (UIColor *)grayLabelColor {
    return COLOR_COMPATIBILITY(0xFFAEB2C9, 0xFFAEB2C9);
}



+ (UIColor *)secondaryPrimaryColor {
    return COLOR_COMPATIBILITY(0xFF16B9FF, 0xFF16B9FF);
}

+ (UIColor *)clearColor {
    return UIColor.clearColor;
}

#pragma mark Foreground colors

+ (UIColor *)labelColor {
    return COLOR_COMPATIBILITY(0xFFFFFFFF, 0xFF333333);
}

+ (UIColor *)secondaryLabelColor {
    return COLOR_COMPATIBILITY(0xFF85899C, 0xFF85899C);
}

+ (UIColor *)placeholderTextColor {
    return COLOR_COMPATIBILITY(0xFFDFE0E5, 0xFFDFE0E5);
}

+ (UIColor *)separatorColor {
    return COLOR_COMPATIBILITY(0xFF3E3F42, 0xFFF7F7F9);
}

+ (UIColor *)blankSpaceColor {
    return COLOR_COMPATIBILITY(0xFFBCBFCD, 0xFFBCBFCD);
}

#pragma mark Background colors

+ (UIColor *)systemBackgroundColor {
    return COLOR_COMPATIBILITY(0xFF1A1A1A, 0xFFFFFFFF);
}

+ (UIColor *)secondarySystemBackgroundColor {
    return COLOR_COMPATIBILITY(0xFF101010, 0xFFF5F6FA);
}

+ (UIColor *)tertiarySystemBackgroundColor {
    return COLOR_COMPATIBILITY(0xFFEDF3FF, 0xFFEDF3FF);
}

+ (UIColor *)disableSystemBackgroundColor {
    return COLOR_COMPATIBILITY(0xFFDFE0E5, 0xFFDFE0E5);
}

#pragma mark Other colors

+ (UIColor *)lightTextColor {
    return [ESColor colorWithHex:0xFFFFFFFF];
}

+ (UIColor *)darkTextColor {
    return [ESColor colorWithHex:0xFF000000];
}

+ (UIColor *)disableTextColor {
    return COLOR_COMPATIBILITY(0xFFBCBFCD, 0xFFBCBFCD);
}

+ (UIColor *)redColor {
    return COLOR_COMPATIBILITY(0xFFF6222D, 0xFFF6222D);
}

+ (UIColor *)greenColor {
    return COLOR_COMPATIBILITY(0xFF43D9AF, 0xFF43D9AF);
}

+ (UIColor *)downGreenColor {
    return COLOR_COMPATIBILITY(0x00C991, 0x00C991);
}


+ (UIColor *)yellowColor {
    return COLOR_COMPATIBILITY(0xFFFA9D00, 0xFFFA9D00);
}

+ (UIColor *)grayColor {
    return COLOR_COMPATIBILITY(0xFFBCBFCD, 0xFFBCBFCD);
}

+ (UIColor *)grayPointColor {
    return COLOR_COMPATIBILITY(0xFF85899C, 0xFF85899C);
}

+ (UIColor *)grayBgColor {
    return COLOR_COMPATIBILITY(0xFFDFE0E5, 0xFFDFE0E5);
}


+ (UIColor *)searchLabelColor {
    return COLOR_COMPATIBILITY(0xFFD3D5DF, 0xFFD3D5DF);
}

#pragma mark - light dark Style

+ (BOOL)isLighterColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return red*0.299 + green*0.578 + blue*0.114 >= 192;
}

+ (BOOL)isLighterColor:(UIColor *)color {
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    return (components[0]+components[1]+components[2])/3 >= 0.5;
}

+ (BOOL)isLighterColorWithHXB:(NSInteger)hexColor {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [self isLighterColorWithRed:red green:green blue:blue];
}

+ (UIColor *)pushBgColor {
    return COLOR_COMPATIBILITY(0xFFEDF3FF, 0xFFEDF3FF);
}

+ (UIColor *)pushTitleColor {
    return COLOR_COMPATIBILITY(0xFF337AFF, 0xFF337AFF);
}

+ (UIColor *)btnBgColor {
    return COLOR_COMPATIBILITY(0xFFE4EEFF, 0xFFE4EEFF);
}

+ (UIColor *)newsListBg {
    return COLOR_COMPATIBILITY(0xFFF5F6FA, 0xFFF5F6FA);
}

+ (UIColor *)newsListTimeColor {
    return COLOR_COMPATIBILITY(0xFF85899C, 0xFF85899C);
}


+ (UIColor *)iconBg {
    return COLOR_COMPATIBILITY(0xFFF7F9FF, 0xFFF7F9FF);
}

+ (UIColor *)searchTitleColor {
    return COLOR_COMPATIBILITY(0xFFCECECE, 0xFFCECECE);
}


+ (UIColor *)btnBuleColor {
    return COLOR_COMPATIBILITY(0xFF337AFF, 0xFF337AFF);
}

+ (UIColor *)searchBuleColor {
    return COLOR_COMPATIBILITY(0xFF4678f6, 0xFF4678f6);
}


@end
