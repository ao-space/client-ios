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
//  ESTimeSlider.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTimeSlider.h"
#import "ESVerticalSlider.h"

@interface ESTimeSlider ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ESVerticalSlider *slider;

@end

@implementation ESTimeSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.slider];
    [self.slider setThumbImage:[UIImage imageNamed:@"time_slider"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"time_slider"] forState:UIControlStateHighlighted];
    
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_left).offset(10.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(110.0f, 30.0f));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.slider.frame = self.bounds;
}

- (void)setValue:(float)value {
    [self.slider setValue:(self.slider.maximumValue - value)];
    [self updateTimeLabelFrame];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [ESColor systemBackgroundColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = ESColor.labelColor;
        _timeLabel.font = ESFontPingFangMedium(12);
        _timeLabel.layer.cornerRadius = 15.0f;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.layer.shadowColor = [ESColor colorWithHex:0xBCBFCD alpha:0.6].CGColor;
        _timeLabel.layer.shadowOpacity = 1.0f;
        _timeLabel.layer.shadowRadius = 10.0f;
    }
    return _timeLabel;
}

- (ESVerticalSlider *)slider {
    if (!_slider) {
        _slider = [[ESVerticalSlider alloc] initWithFrame:CGRectZero];
        _slider.maximumValue = 100;
        _slider.minimumValue = 0;
        _slider.continuous = YES;
        [_slider setMinimumTrackTintColor:ESColor.clearColor];
        [_slider setMaximumTrackTintColor:ESColor.clearColor];
        [_slider addTarget:self action:@selector(sliderValurChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (void)setShowStyle:(ESTimeSliderShowStyle)showStyle {
    _showStyle = showStyle;
    if (showStyle == ESTimeSliderShowStyleNormal) {
        self.hidden = NO;
        self.timeLabel.hidden = YES;
        return;
    }
    
    if (showStyle == ESTimeSliderShowStyleTimeLine) {
        self.hidden = NO;
        self.timeLabel.hidden = NO;
        return;
    }
    
    if (showStyle == ESTimeSliderShowStyleHideen) {
        self.hidden = YES;
        return;
    }
}

- (void)setTrackingBlock:(dispatch_block_t)trackingBlock {
    self.slider.trackingBlock = trackingBlock;
}

- (void)setEndTrackingBlock:(dispatch_block_t)endTrackingBlock {
    self.slider.endTrackingBlock = endTrackingBlock;
}

- (void)updateTimeText:(NSString *)time {
    self.timeLabel.text = time;
    self.timeLabel.alpha = time.length > 0 ? 1 : 0;
}

- (void)sliderValurChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    if (self.valueChangedBlock) {
        self.valueChangedBlock(self.slider.maximumValue - self.slider.value);
    }
    [self updateTimeLabelFrame];
}

- (void)updateTimeLabelFrame {
    CGFloat height = self.bounds.size.height;
    CGFloat timeLableOffsetY = (height - 30 - 44) / (self.slider.maximumValue - self.slider.minimumValue) * (self.slider.maximumValue - self.slider.value);
    
    self.timeLabel.frame = CGRectMake(self.bounds.size.width - 164, timeLableOffsetY + 18 , 110.0f, 30.0f);
}

@end


