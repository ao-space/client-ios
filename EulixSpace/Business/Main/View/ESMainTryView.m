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
//  ESMainTryView.m
//  EulixSpace
//
//  Created by qu on 2021/11/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMainTryView.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import <Masonry/Masonry.h>

@interface ESMainTryView ()

/// 按钮btn
@property (nonatomic, strong) UIImageView *iconImageView;

/// 按钮btn
@property (nonatomic, strong) UILabel *title;

/// 按钮btn
@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UIButton *filliInNowBtn;

@property (nonatomic, strong) UIButton *cancelBtn;
@end

@implementation ESMainTryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(36.0f);
        make.width.mas_equalTo(36.0f);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(17.0f);
        make.width.mas_equalTo(70.0f);
    }];

    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(17.0f);
        make.width.mas_equalTo(70.0f);
    }];

    [self.filliInNowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(17.0f);
        make.width.mas_equalTo(70.0f);
    }];

    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(17.0f);
        make.width.mas_equalTo(70.0f);
    }];
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_MAIN_TRY_ICON;
    }
    return _iconImageView;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = [ESColor labelColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self addSubview:_title];
    }
    return _title;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = [ESColor labelColor];
        _pointOutLabel.textAlignment = NSTextAlignmentCenter;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (UIButton *)filliInNowBtn {
    if (nil == _filliInNowBtn) {
        _filliInNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filliInNowBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_filliInNowBtn addTarget:self action:@selector(filliInNowBtnCick) forControlEvents:UIControlEventTouchUpInside];
        [_filliInNowBtn setTitle:@"确认加入" forState:UIControlStateNormal];
        [_filliInNowBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
        [_filliInNowBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
        [self addSubview:_filliInNowBtn];
    }
    return _filliInNowBtn;
}

- (UIButton *)cancelBtn {
    if (nil == _cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
        [self addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (void)cancelBtnClick {
}

- (void)filliInNowBtnCick {
}

@end
