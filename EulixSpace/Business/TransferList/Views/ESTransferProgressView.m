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
//  ESTransferProgressView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/8/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferProgressView.h"
#import "ESGradientView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESTransferProgressView ()

@property (nonatomic, strong) UIView *background;

@property (nonatomic, strong) ESGradientView *progress;

@property (nonatomic, assign) CGFloat rate;

@end

@implementation ESTransferProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    [UIView performWithoutAnimation:^{
        self.progress.frame = CGRectMake(0, 0, width * self.rate, CGRectGetHeight(self.bounds));
    }];
}

- (void)reloadWithRate:(CGFloat)rate {
    ESPerformBlockOnMainThread(^{
        self.rate = rate;
        [self setNeedsLayout];
    });
}

- (void)setHolderBackgroundColor:(UIColor *)holderBackgroundColor {
    self.background.backgroundColor = holderBackgroundColor;
}

- (void)setCornerRadius:(CGFloat)num {
    [self.progress setCornerRadius:num];
    self.background.layer.cornerRadius = num;
}

- (void)setGradientStartColor:(NSString *)sColor endColor:(NSString *)eColor {
    [self.progress setGradientColor:sColor endColor:eColor];
}

- (CGFloat)getRateValue {
    return self.rate;
}

#pragma mark - Lazy Load

- (UIView *)background {
    if (!_background) {
        _background = [[UIView alloc] init];
        _background.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _background.layer.cornerRadius = 3;
        _background.layer.masksToBounds = YES;
        [self addSubview:_background];
    }
    return _background;
}

- (ESGradientView *)progress {
    if (!_progress) {
        _progress = [[ESGradientView alloc] init];
        [_progress setCornerRadius:3];
        [self addSubview:_progress];
    }
    return _progress;
}

@end
