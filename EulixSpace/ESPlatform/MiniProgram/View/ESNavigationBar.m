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
//  ESNavigationBar.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNavigationBar.h"
#import <Masonry/Masonry.h>
#import "ESNavigationBar+ESStyle.h"
#import "UIButton+ESTouchArea.h"

@interface ESNavigationBar ()

@property (nonatomic, strong) UIView* customNavigationBarContentView;
@property (nonatomic, strong) UIButton* backBt;

@property (nonatomic, strong) UIButton* moreBt;
@property (nonatomic, strong) UIImageView *redIcon;
@property (nonatomic, strong) UILabel* titleLabel;

@property (nonatomic, assign) BOOL isBarkStyle;
@property (nonatomic, strong) NSNumber *translucentUseLightIcons;

@property (nonatomic, strong) UIColor *backgroudColor;
@property (nonatomic, strong) UIColor *titleColor;

@end

@implementation ESNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupNavigationBarView];
        [self setupShowStyle];
    }
    return self;
}

- (void)setupShowStyle {
    self.isTranslucent = NO;
    self.isBarkStyle = NO;
    [self updateShowStyle];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
}

- (void)setCanGoBack:(BOOL)canGoBack {
    self.backBt.hidden = !canGoBack;
}

- (void)setHaveNewAction:(BOOL)newAction {
    _redIcon.hidden = !newAction;
}

- (void)setupNavigationBarView {
    [self addSubview:self.customNavigationBarContentView];
    [self.customNavigationBarContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(44.0f);
    }];
    
    [self.customNavigationBarContentView addSubview:self.backBt];
    [self.backBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavigationBarContentView.mas_centerY);
        make.left.mas_equalTo(self.customNavigationBarContentView.mas_left).offset(26.0f);
        make.height.width.mas_equalTo(18.0f);
    }];
    
    [self setupMoreView];
    
    [self.customNavigationBarContentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavigationBarContentView.mas_centerY);
        make.centerX.mas_equalTo(self.customNavigationBarContentView.mas_centerX);
        make.height.mas_equalTo(25.0f);
        make.width.mas_lessThanOrEqualTo(200.0f);
    }];
}

- (void)setupMoreView {
    [self.customNavigationBarContentView addSubview:self.moreBt];
    [self.moreBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavigationBarContentView.mas_centerY);
        make.right.mas_equalTo(self.customNavigationBarContentView.mas_right).mas_offset(-14.0f);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    [self.moreBt addSubview:self.redIcon];
    [self.redIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.moreBt.mas_right).offset(-6.0f);
        make.top.mas_equalTo(self.moreBt.mas_top).offset(6.0f);
        make.height.width.mas_equalTo(8.0f);
    }];
}

- (UIButton *)backBt {
    if (!_backBt) {
        _backBt = [[UIButton alloc] init];
        [_backBt addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _backBt;
}

- (UIButton *)moreBt {
    if (!_moreBt) {
        _moreBt = [[UIButton alloc] init];
        [_moreBt addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _moreBt;
}

- (UIImageView *)redIcon {
    if (!_redIcon) {
        _redIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _redIcon.backgroundColor = ESColor.redColor;
        _redIcon.layer.cornerRadius = 4;
        _redIcon.clipsToBounds = YES;
    }
    return _redIcon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
    
- (void)backAction:(UIButton *)sender {
    if (_actionBlock) {
        _actionBlock(sender, ESNavigationBarActionTypeBack);
    }
}

- (void)moreAction:(UIButton *)sender {
    if (_actionBlock) {
        _actionBlock(sender, ESNavigationBarActionTypeMore);
    }
}

- (void)closeAction:(UIButton *)sender {
    if (_actionBlock) {
        _actionBlock(sender, ESNavigationBarActionTypeClose);
    }
}

- (UIView *)customNavigationBarContentView {
    if (!_customNavigationBarContentView) {
        _customNavigationBarContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _customNavigationBarContentView.backgroundColor = [UIColor clearColor];
    }
    return _customNavigationBarContentView;
}

@end
