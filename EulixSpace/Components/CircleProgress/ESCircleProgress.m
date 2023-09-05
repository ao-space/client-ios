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
//  ESCircleProgress.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/12/10.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCircleProgress.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESCircleProgress ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) CAShapeLayer *circle;

@property (nonatomic, assign) CGFloat progress;

@end

@implementation ESCircleProgress {
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

- (void)drawCircle {
    CGPoint origin = CGPointMake(CGRectGetMidX(self.circle.bounds), CGRectGetMidY(self.circle.bounds));
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:origin radius:origin.x - 1 startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path addLineToPoint:origin];
    self.circle.path = path.CGPath;
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.2];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderColor = ESColor.lightTextColor.CGColor;
        _contentView.layer.borderWidth = 1;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (CAShapeLayer *)circle {
    if (!_circle) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.fillColor = ESColor.lightTextColor.CGColor;
        circle.strokeColor = ESColor.lightTextColor.CGColor;
        circle.lineWidth = 1;
        _circle = circle;
        [self.contentView.layer addSublayer:circle];
    }
    return _circle;
}

@end
