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
//  ESFeedbackResultView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFeedbackResultView.h"
#import "ESFormItem.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESFeedbackResultView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) ESGradientButton *confirmButton;

@end

@implementation ESFeedbackResultView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(74);
        make.width.mas_equalTo(80);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.avatar.mas_bottom).inset(12);
        make.height.mas_equalTo(25);
        make.left.right.mas_equalTo(self.contentView).inset(30);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.title.mas_bottom).inset(16);
   
        make.left.right.mas_equalTo(self.contentView).inset(30);
    }];

    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).inset(30);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
    }];
    self.avatar.image = IMAGE_FEEDBACK_SUBMITTED;
    self.title.text = TEXT_FEEDBACK_SUBMITTED;
    self.content.text = TEXT_FEEDBACK_SUBMITTED_PROMPT;
}

- (void)reloadWithData:(ESFormItem *)model {
}

- (void)confirmAction {
    if (self.actionBlock) {
        self.actionBlock(nil);
    }
    [self removeFromSuperview];
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.backgroundColor = ESColor.systemBackgroundColor;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self);
            make.height.mas_equalTo(314);
            make.width.mas_equalTo(270);
        }];
    }
    return _contentView;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        [self.contentView addSubview:_avatar];
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 5;
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.font = [UIFont systemFontOfSize:14];
        _content.numberOfLines = 0;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (ESGradientButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_confirmButton setCornerRadius:10];
        [_confirmButton setTitle:TEXT_OK forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_confirmButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.contentView addSubview:_confirmButton];
        [_confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
