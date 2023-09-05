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
//  ESBoxSearchingPromptView.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/19.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxSearchingPromptView.h"
#import "ESBoxBindDefine.h"
#import <Lottie/LOTAnimationView.h>
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>

@interface ESBoxSearchingPromptView ()

@property (nonatomic, strong) LOTAnimationView *animation;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *detailHintLabel;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ESBoxSearchingPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;

    [self.animation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(68);
        make.size.mas_equalTo(CGSizeMake(196, 196));
        make.centerX.mas_equalTo(self.contentView);
    }];

    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.animation.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];

    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stateLabel.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView).inset(20);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.detailHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hintLabel.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView).inset(58);
        make.height.mas_greaterThanOrEqualTo(48);
    }];
}

- (void)reloadWithState:(ESBoxSearchingState)state {
    if (state == ESBoxSearchingStateScaning) {
        [self.animation play];
    } else {
        [self.animation stop];
    }
}

#pragma mark - Lazy Load

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"scaning"];
        _animation.loopAnimation = YES;
        [self addSubview:_animation];
    }
    return _animation;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.textColor = ESColor.primaryColor;
        _stateLabel.font = ESFontPingFangRegular(14);
        _stateLabel.text = NSLocalizedString(@"binding_connectingdevice", @"正在连接设备…");
        [self.contentView addSubview:_stateLabel];
    }
    return _stateLabel;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.textColor = ESColor.secondaryLabelColor;
        _hintLabel.font = ESFontPingFangRegular(14);
        _hintLabel.text = NSLocalizedString(@"box_power_on", @"请确保设备已接通电源");
        [self.contentView addSubview:_hintLabel];
    }
    return _hintLabel;
}

- (UILabel *)detailHintLabel {
    if (!_detailHintLabel) {
        _detailHintLabel = [[UILabel alloc] init];
        _detailHintLabel.textColor = ESColor.secondaryLabelColor;
        _detailHintLabel.textAlignment = NSTextAlignmentCenter;
        _detailHintLabel.font = ESFontPingFangMedium(14);
        _detailHintLabel.numberOfLines = 0;
        _detailHintLabel.text = NSLocalizedString(@"es_docker_searching_box_hint_1", @"请将手机与设备连接到同一网络");
        [self.contentView addSubview:_detailHintLabel];
    }
    return _detailHintLabel;
}


@end

