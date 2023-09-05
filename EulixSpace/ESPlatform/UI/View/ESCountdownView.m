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
//  ESCountdownView.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESCountdownView.h"

@interface ESCountdownView ()

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) CAShapeLayer *backgroudCircle;

@property (nonatomic, assign) CGFloat progress;

@end

static CGFloat const ESCircleLineWidth = 2.0f;

@implementation ESCountdownView


- (void)layoutSubviews {
    [super layoutSubviews];
    self.circle.frame = CGRectInset(self.bounds, 0, 0);
    [self drawCircle];
}

- (void)reloadWithProgress:(CGFloat)progress {
    self.progress = progress;
    [self drawCircle];
}

- (void)drawCircle {
    if (_backgroudCircle.superlayer) {
        [_backgroudCircle removeFromSuperlayer];
    }
    
    if (_circle.superlayer) {
        [_circle removeFromSuperlayer];
    }
    
    CGPoint origin = CGPointMake(CGRectGetMidX(self.circle.bounds), CGRectGetMidY(self.circle.bounds));
    CGFloat endAngle = M_PI * 2 - M_PI_2;
    CGFloat startAngle = endAngle + self.progress * M_PI * 2;
    
    UIBezierPath *backgroudCirclePath = [UIBezierPath bezierPathWithArcCenter:origin radius:origin.x - ESCircleLineWidth startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.backgroudCircle.path = backgroudCirclePath.CGPath;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:origin radius:origin.x - ESCircleLineWidth startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.circle.path = path.CGPath;
    
    [self.layer addSublayer:_backgroudCircle];
    [self.layer addSublayer:_circle];
}

- (CAShapeLayer *)circle {
    if (!_circle) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.fillColor = ESColor.clearColor.CGColor;
        circle.strokeColor = ESColor.primaryColor.CGColor;
        circle.lineWidth = ESCircleLineWidth;
        _circle = circle;
    }
    return _circle;
}

- (CAShapeLayer *)backgroudCircle {
    if (!_backgroudCircle) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.fillColor = ESColor.clearColor.CGColor;
        circle.strokeColor = [ESColor colorWithHex:0xE3EAF8].CGColor;
        circle.lineWidth = ESCircleLineWidth;
        _backgroudCircle = circle;
    }
    return _backgroudCircle;
}

@end
