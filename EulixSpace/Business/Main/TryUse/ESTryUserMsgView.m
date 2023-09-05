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
//  ESTryUserMsgView.m
//  EulixSpace
//
//  Created by qu on 2021/12/1.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTryUserMsgView.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESTryUserMsgView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *pointOutLable;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) UIView *programView;
@end

@implementation ESTryUserMsgView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(19.0f);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-50.0);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(19.0f);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-50.0);
    }];

    [self.pointOutLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(19.0f);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-50.0);
    }];

    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(19.0f);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-50.0);
    }];

    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(19.0f);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-50.0);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"family_information_name", @"昵称");
        _titleLabel.textColor = ESColor.secondaryLabelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)completeBtn {
    if (nil == _completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_completeBtn setTitle:NSLocalizedString(@"confirm_join", @"确认加入") forState:UIControlStateNormal];
        [_completeBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
        [_completeBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
        [self.programView addSubview:_completeBtn];
    }
    return _completeBtn;
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] init];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        _programView.layer.cornerRadius = 10.0;
        _programView.layer.masksToBounds = YES;
        [self addSubview:_programView];
    }
    return _programView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_ME_ARROW;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end
