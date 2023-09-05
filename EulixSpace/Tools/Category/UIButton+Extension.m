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

#import "UIButton+Extension.h"
#import "UIColor+ESHEXTransform.h"

@implementation UIButton (Extension)

#pragma mark - init

- (void)sc_setLayout:(SCEUIButtonLayoutStyle)aLayoutStyle
             spacing:(CGFloat)aFloatSpacing {
    self.titleEdgeInsets = UIEdgeInsetsZero;
    self.imageEdgeInsets = UIEdgeInsetsZero;

    CGFloat floatImageW = self.imageView.image.size.width;
    CGFloat floatLabelW = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}].width;

    CGRect rectImage = self.imageView.frame;
    CGRect rectTitle = self.titleLabel.frame;

    CGFloat floatTotalH = rectImage.size.height + aFloatSpacing + rectTitle.size.height;
    CGFloat floatSelfH = self.frame.size.height;
    CGFloat floatSelfW = self.frame.size.width;

    switch (aLayoutStyle) {
        case SCEImageLeftTitleRightStyle: {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -aFloatSpacing / 2, 0, aFloatSpacing / 2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, aFloatSpacing / 2, 0, -aFloatSpacing / 2);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, aFloatSpacing / 2, 0, aFloatSpacing / 2);
            break;
        }
        case SCETitleLeftImageRightStyle: {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, floatLabelW + aFloatSpacing / 2, 0, -(floatLabelW + aFloatSpacing / 2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(floatImageW + aFloatSpacing / 2), 0, floatImageW + aFloatSpacing / 2);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, aFloatSpacing / 2, 0, aFloatSpacing / 2);
            break;
        }
        case SCEImageTopTitleBootomStyle: {
            CGFloat floatTitleTempX = ((floatSelfH - floatTotalH) / 2 + rectImage.size.height + aFloatSpacing - rectTitle.origin.y);
            CGFloat floatTitleTempY = (floatSelfW / 2 - rectTitle.origin.x - rectTitle.size.width / 2) - (floatSelfW - rectTitle.size.width) / 2;
            CGFloat floatTitleTempW = -((floatSelfH - floatTotalH) / 2 + rectImage.size.height + aFloatSpacing - rectTitle.origin.y);
            CGFloat floatTitleTempH = -(floatSelfW / 2 - rectTitle.origin.x - rectTitle.size.width / 2) - (floatSelfW - rectTitle.size.width) / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(floatTitleTempX,
                                                    floatTitleTempY,
                                                    floatTitleTempW,
                                                    floatTitleTempH);

            CGFloat floatImageTempX = ((floatSelfH - floatTotalH) / 2 - rectImage.origin.y);
            CGFloat floatImageTempY = (floatSelfW / 2 - rectImage.origin.x - rectImage.size.width / 2);
            CGFloat floatImageTempW = -((floatSelfH - floatTotalH) / 2 - rectImage.origin.y);
            CGFloat floatImageTempH = -(floatSelfW / 2 - rectImage.origin.x - rectImage.size.width / 2);
            self.imageEdgeInsets = UIEdgeInsetsMake(floatImageTempX,
                                                    floatImageTempY,
                                                    floatImageTempW,
                                                    floatImageTempH);
            break;
        }
        case SCETitleTopImageBootomStyle: {
            CGFloat floatTitleTempX = ((floatSelfH - floatTotalH) / 2 - rectTitle.origin.y);
            CGFloat floatTitleTempY = (floatSelfW / 2 - rectTitle.origin.x - rectTitle.size.width / 2) - (floatSelfW - rectTitle.size.width) / 2;
            CGFloat floatTitleTempW = -((floatSelfH - floatTotalH) / 2 - rectTitle.origin.y);
            CGFloat floatTitleTempH = -(floatSelfW / 2 - rectTitle.origin.x - rectTitle.size.width / 2) - (floatSelfW - rectTitle.size.width) / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(floatTitleTempX,
                                                    floatTitleTempY,
                                                    floatTitleTempW,
                                                    floatTitleTempH);

            CGFloat floatImageTempX = ((floatSelfH - floatTotalH) / 2 + rectTitle.size.height + aFloatSpacing - rectImage.origin.y);
            CGFloat floatImageTempY = (floatSelfW / 2 - rectImage.origin.x - rectImage.size.width / 2);
            CGFloat floatImageTempW = -((floatSelfH - floatTotalH) / 2 + rectTitle.size.height + aFloatSpacing - rectImage.origin.y);
            CGFloat floatImageTempH = -(floatSelfW / 2 - rectImage.origin.x - rectImage.size.width / 2);
            self.imageEdgeInsets = UIEdgeInsetsMake(floatImageTempX,
                                                    floatImageTempY,
                                                    floatImageTempW,
                                                    floatImageTempH);
            break;
        }
        default:
            break;
    }
}


+ (UIButton *)es_create:(NSString *)title
                font:(UIFont *)font
             txColor:(NSString *)txColor
             bgColor:(NSString *)bgColor
              target:(id)target
            selector:(SEL)selector {
    UIButton * btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    if (txColor) {
        [btn setTitleColor:[UIColor es_colorWithHexString:txColor] forState:UIControlStateNormal];
    }
    if (bgColor) {
        btn.backgroundColor = [UIColor es_colorWithHexString:bgColor];
    }
    if (target && selector) {
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    return btn;
}

- (void)setEsCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

@end
