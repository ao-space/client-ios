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
//  ESProcessView.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESProcessView.h"
#import "UIColor+ESHEXTransform.h"

@interface ESProcessView ()

@property (nonatomic ,strong) UIView *trackTintView;//背景View
@property (nonatomic ,strong) UIView *tintView;//填充View
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation ESProcessView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressTapClick:)];
        [self addGestureRecognizer:tapGesture];
        [self loadingView];
        self.tintColorArray = @[(__bridge id)[UIColor es_colorWithHexString:@"#337AFF"].CGColor, (__bridge id)[UIColor es_colorWithHexString:@"#16B9FF"].CGColor];
        self.trackTintColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
        self.progressValue = 0;
    }
    return self;
}

- (void)progressTapClick:(UITapGestureRecognizer *)tapGes{
   
}

- (void)loadingView{
    [self trackTintView];
    [self tintView];
    [self gradientLayer];
}

- (UIView *)trackTintView{
    if (!_trackTintView) {
        _trackTintView = [UIView new];
        _trackTintView.layer.masksToBounds = YES;
        _trackTintView.layer.cornerRadius = 3;
        [self addSubview:_trackTintView];
    }
    return _trackTintView;
}

- (UIView *)tintView{
    if (!_tintView) {
        _tintView = [UIView new];
        _tintView.frame = CGRectMake(0, self.bounds.size.height/2-2.5, 0, self.bounds.size.height);
        _tintView.layer.masksToBounds = YES;
        _tintView.layer.cornerRadius = 3;
        [self addSubview:_tintView];
    }
    return _tintView;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        _gradientLayer.anchorPoint = CGPointMake(0, 0);
        [self.tintView.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

- (void)setProgressValue:(CGFloat)progressValue{
    _progressValue = progressValue;
    [self updateView];
}

- (void)setTintColorArray:(NSArray *)tintColorArray{
    _tintColorArray = tintColorArray;
    if (tintColorArray.count >= 2) {
        [self updateView];
    } else {
        //使用默认色
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor{
    _trackTintColor = trackTintColor;
    _trackTintView.backgroundColor = trackTintColor;
}

- (void)updateView{
    _trackTintView.backgroundColor = self.trackTintColor;

    _trackTintView.frame = CGRectMake(0, self.bounds.size.height/2 - 2.5, self.bounds.size.width, self.bounds.size.height);
    _tintView.frame = CGRectMake(0, self.bounds.size.height/2 - 2.5, self.bounds.size.width * _progressValue, self.bounds.size.height);
    self.gradientLayer.frame = self.tintView.bounds;
    self.gradientLayer.colors = self.tintColorArray;
}

@end
