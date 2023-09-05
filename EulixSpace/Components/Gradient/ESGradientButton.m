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
// Created by Ye Tao on 2021/7/12.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <Lottie/LOTAnimationView.h>
#import <Masonry/Masonry.h>

@interface ESGradientButton ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) LOTAnimationView *animation;

@end

@implementation ESGradientButton {
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.gradientLayer.cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.gradientLayer.hidden = !enabled;
    if (enabled) {
        self.backgroundColor = ESColor.clearColor;
    } else {
        self.backgroundColor = ESColor.disableSystemBackgroundColor;
    }
}

- (void)startLoading:(NSString *)text {
    NSParameterAssert(text);
    [self.animation play];
    self.animation.hidden = NO;
    self.userInteractionEnabled = NO;
    [self setTitle:text forState:UIControlStateNormal];
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    CGFloat width = [text es_widthWithFont:self.titleLabel.font];
    [self.animation mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).offset(-(width + 8) / 2);
    }];
}

- (void)stopLoading:(NSString *)text {
    NSParameterAssert(text);
    [self.animation stop];
    self.animation.hidden = YES;
    self.userInteractionEnabled = YES;
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setTitle:text forState:UIControlStateNormal];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
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

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"loading"];
        _animation.loopAnimation = YES;
        [self addSubview:_animation];
        [_animation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.width.height.mas_equalTo(24);
        }];
    }
    return _animation;
}

- (void)userEnable:(BOOL)enable {
    ESDLog(@"[ESGradientButton] title:%@ enable:%d", self.titleLabel.text, enable);
    if (enable) {
        _gradientLayer.colors = @[(__bridge id)ESColor.primaryColor.CGColor, (__bridge id)ESColor.secondaryPrimaryColor.CGColor];
    } else {
        _gradientLayer.colors = @[(__bridge id)[ESColor colorWithHex:0xC3D8FF].CGColor, (__bridge id)[ESColor colorWithHex:0xBAEBFF].CGColor];
    }
    [self.layer layoutIfNeeded];
}
@end
