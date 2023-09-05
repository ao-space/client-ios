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
//  ESBoxBindModeSelectView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindModeSelectView.h"
#import "ESFormItem.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESBoxBindModeSelectView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) ESGradientButton *retryButton;

@property (nonatomic, strong) UIButton *wiredConnectionButton;

@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation ESBoxBindModeSelectView

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
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(98);
        make.height.mas_equalTo(74);
        make.top.mas_equalTo(self.contentView).inset(20);
        make.centerX.mas_equalTo(self.contentView);
    }];

    //图片太小, 补齐大小到44
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16 + 28);
        make.top.right.mas_equalTo(self.contentView).inset(20 - 14);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatar.mas_bottom).inset(12);
        make.left.right.mas_equalTo(self.contentView).inset(20);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(16);
        make.left.right.mas_equalTo(self.contentView).inset(20);
    }];

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.top.mas_equalTo(self.content.mas_bottom).inset(28);
        make.centerX.mas_equalTo(self.contentView);
    }];

    [self.wiredConnectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.top.mas_equalTo(self.retryButton.mas_bottom).inset(10);
        make.centerX.mas_equalTo(self.contentView);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
}

- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self);
            make.width.mas_equalTo(270);
            make.height.mas_equalTo(356);
        }];
    }
    return _contentView;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_dismissButton];
        _dismissButton.tag = ESBoxBindModeSelectTypeDismiss;
        [_dismissButton setImage:IMAGE_DISMISS forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.image = IMAGE_BIND_BLE_FAILED;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.numberOfLines = 0;
        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        _title.text = TEXT_BOX_BIND_BLE_FAILED;
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = ESFontPingFangRegular(14);
        _content.numberOfLines = 0;
        _content.text = TEXT_BOX_BIND_BLE_FAILED_PROMPT;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (ESGradientButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_retryButton setCornerRadius:10];
        [_retryButton setTitle:TEXT_BOX_BIND_RETRY_BLE forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_retryButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.tag = ESBoxBindModeSelectTypeRetryBle;
        [self.contentView addSubview:_retryButton];
    }
    return _retryButton;
}

- (UIButton *)wiredConnectionButton {
    if (!_wiredConnectionButton) {
        _wiredConnectionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        _wiredConnectionButton.layer.cornerRadius = 10;
        _wiredConnectionButton.layer.masksToBounds = YES;
        _wiredConnectionButton.layer.borderWidth = 1;
        _wiredConnectionButton.layer.borderColor = ESColor.primaryColor.CGColor;
        _wiredConnectionButton.backgroundColor = ESColor.systemBackgroundColor;
        [_wiredConnectionButton setTitle:TEXT_BOX_BIND_TRY_WIRED_CONNECTION forState:UIControlStateNormal];
        _wiredConnectionButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_wiredConnectionButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_wiredConnectionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        _wiredConnectionButton.tag = ESBoxBindModeSelectTypeWiredConnection;
        [self.contentView addSubview:_wiredConnectionButton];
    }
    return _wiredConnectionButton;
}

@end
