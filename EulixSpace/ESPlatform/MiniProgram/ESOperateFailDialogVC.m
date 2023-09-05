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
//  ESUpdateFailDialogVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESOperateFailDialogVC.h"

@interface ESOperateFailDialogVC ()

@property (nonatomic, strong) UIImageView *headerBackgroudImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *hintImageView;
@property (nonatomic, copy) NSString * iconImageUrl;
@property (nonatomic, strong) UIView *customHeaderView;


@property (nonatomic, strong) UIView *customContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *messageDetailLabel;
@property (nonatomic, copy) NSString *alertTitle;

@end

@implementation ESOperateFailDialogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionOrientationStyle = ESAlertActionOrientationStyleHorizontal;
}

- (UIView * _Nullable)headerView {
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _headerBackgroudImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_customHeaderView addSubview:self.headerBackgroudImageView];
        _headerBackgroudImageView.image = [UIImage imageNamed:@"gengxin-1"];
        [_headerBackgroudImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(97.0f);
            make.height.mas_equalTo(73.0f);
            make.centerX.equalTo(_customHeaderView.mas_centerX);
            make.top.equalTo(_customHeaderView.mas_top).offset(20.0f);
        }];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:self.iconImageView];
        [_iconImageView es_setImageWithURL:_iconImageUrl placeholderImageName:nil];

        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60.0f);
            make.height.mas_equalTo(60.0f);
            make.centerX.equalTo(_headerBackgroudImageView.mas_centerX).offset(4.5f);
            make.bottom.equalTo(_headerBackgroudImageView.mas_bottom).offset(-7.0f);
        }];
        
        _hintImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:_hintImageView];
        _hintImageView.image = [UIImage imageNamed:@"applet_update_fail_hint"];
        [_hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(25.0f);
            make.height.mas_equalTo(25.0f);
            make.right.equalTo(_headerBackgroudImageView.mas_right).offset(-11.5f);
            make.bottom.equalTo(_headerBackgroudImageView.mas_bottom).offset(-1.0f);
        }];
    }
    
    return _customHeaderView;
}

- (UIView * _Nullable)customContentView {
    if (!_customContentView) {
        _customContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addTitleLabel];
        [self addMessageLabel];
        [self addMessageDetailLabel];
    }
    return _customContentView;
}

- (void)addTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = ESFontPingFangMedium(18);
    _titleLabel.textColor = ESColor.labelColor ;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.alertTitle;
    [_customContentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25);
        make.top.equalTo(_customContentView.mas_top).offset(12);
        make.left.equalTo(_customContentView.mas_left).offset(12);
        make.right.equalTo(_customContentView.mas_right).offset(-12);
    }];
}

- (void)addMessageLabel {
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.numberOfLines = 1;
    _messageLabel.font = ESFontPingFangRegular(14);
    _messageLabel.textColor = ESColor.labelColor;
    _messageLabel.text = @"原因：傲空间系统版本过低";
    _messageLabel.textAlignment = NSTextAlignmentCenter;

    [_customContentView addSubview:_messageLabel];
    [_messageLabel sizeToFit];
    CGSize size = _messageLabel.frame.size;
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
        make.centerX.equalTo(_customContentView);
        make.height.mas_equalTo(22.0f);
        if (_titleLabel) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(16.0f);
        } else {
            make.top.equalTo(_customContentView.mas_top).offset(16.0f);
        }
    }];
}

- (void)addMessageDetailLabel {
    _messageDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageDetailLabel.backgroundColor = [UIColor clearColor];
    _messageDetailLabel.numberOfLines = 0;
    _messageDetailLabel.font = ESFontPingFangRegular(14);
    _messageDetailLabel.textColor = ESColor.secondaryLabelColor;
    _messageDetailLabel.text = @"请在管理员绑定手机上完成【系统升级】后再操作小应用更新。";
    _messageDetailLabel.textAlignment = NSTextAlignmentCenter;

    [_customContentView addSubview:_messageDetailLabel];
    
    [_messageDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_customContentView.mas_left).offset(35.0f);
        make.right.equalTo(_customContentView.mas_right).offset(-35.0f);
        make.top.equalTo(_messageLabel.mas_bottom).offset(10.0f);
        make.height.mas_equalTo(44.0f);
    }];
}

- (void)settIconImageUrl:(NSString *)url {
    _iconImageUrl = url;
    [_iconImageView es_setImageWithURL:url placeholderImageName:nil];
}

- (CGFloat)headerViewHeight {
    return 93;
}

- (CGFloat)contentViewHeight {
    return 129;
}

- (UIEdgeInsets)contentViewContentInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UIEdgeInsets)actionViewContentInsets {
    return UIEdgeInsetsMake(28, 35, 30, 35);
}

- (void)preAddAction {
    
}
@end
