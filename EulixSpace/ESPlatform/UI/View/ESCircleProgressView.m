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
//  ESCircleProgressView.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCircleProgressView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"

@interface ESCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) CAShapeLayer *backgroudCircle;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CGFloat circleLineWidth;
@property (nonatomic, strong) NSString * strokeColor;
@end

static CGFloat const ESCircleLineWidth = 6.0f;

@implementation ESCircleProgressView {
    CGFloat startAngle;
    CGFloat endAngle;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.circle.frame = CGRectInset(self.bounds, 0, 0);
    [self drawCircle];
}

- (void)reloadWithProgress:(CGFloat)progress {
    self.progress = progress;
    [self drawCircle];
}

- (void)setCircleLineWidth:(CGFloat)width {
    _circleLineWidth = width;
}

- (void)setStrokeColor:(NSString *)color {
    _strokeColor = color;
}

- (void)setCircleStrokeColor:(NSString *)color {
    self.circle.strokeColor = [UIColor es_colorWithHexString:color].CGColor;
}

- (void)drawCircle {
    if (_backgroudCircle.superlayer) {
        [_backgroudCircle removeFromSuperlayer];
    }
    
    if (_circle.superlayer) {
        [_circle removeFromSuperlayer];
    }
    
    CGPoint origin = CGPointMake(CGRectGetMidX(self.circle.bounds), CGRectGetMidY(self.circle.bounds));
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    
    CGFloat lineWidth = self.circleLineWidth > 0 ? self.circleLineWidth : ESCircleLineWidth;
    UIBezierPath *backgroudCirclePath = [UIBezierPath bezierPathWithArcCenter:origin radius:origin.x - lineWidth startAngle:startAngle endAngle:M_PI_2 * 3 clockwise:YES];
    self.backgroudCircle.path = backgroudCirclePath.CGPath;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:origin radius:origin.x - lineWidth startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.circle.path = path.CGPath;
    
    [self.layer addSublayer:_backgroudCircle];
    [self.layer addSublayer:_circle];
}

- (CAShapeLayer *)circle {
    if (!_circle) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.fillColor = ESColor.clearColor.CGColor;
        if (self.strokeColor) {
            circle.strokeColor = [UIColor es_colorWithHexString:self.strokeColor].CGColor;
        } else {
            circle.strokeColor = ESColor.primaryColor.CGColor;
        }
        circle.lineWidth = self.circleLineWidth > 0 ? self.circleLineWidth : 6;
        _circle = circle;
      
    }
    return _circle;
}

- (CAShapeLayer *)backgroudCircle {
    if (!_backgroudCircle) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.fillColor = ESColor.clearColor.CGColor;
        circle.strokeColor = [ESColor colorWithHex:0xE3EAF8].CGColor;
        circle.lineWidth = self.circleLineWidth > 0 ? self.circleLineWidth : 6;
        _backgroudCircle = circle;
    }
    return _backgroudCircle;
}
@end
