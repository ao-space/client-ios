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
//  ESGradientView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESGradientView.h"
#import "ESThemeDefine.h"
#import "UIColor+ESHEXTransform.h"

@interface ESGradientView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation ESGradientView {
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.frame = self.bounds;
    [CATransaction commit];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.gradientLayer.cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
}

- (void)setGradientColor:(NSString *)sColor endColor:(NSString *)eColor {
    self.gradientLayer.colors = @[(__bridge id)[UIColor es_colorWithHexString:sColor].CGColor, (__bridge id)[UIColor es_colorWithHexString:eColor].CGColor];
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        // gradient
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.startPoint = CGPointMake(0, 1);
        _gradientLayer.endPoint = CGPointMake(0.99, 0.01);
        _gradientLayer.colors = @[(__bridge id)ESColor.primaryColor.CGColor, (__bridge id)ESColor.secondaryPrimaryColor.CGColor];
        _gradientLayer.locations = @[@(0), @(1.0f)];
        [self.layer insertSublayer:_gradientLayer atIndex:0];
    }
    return _gradientLayer;
}

@end
