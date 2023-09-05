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
//  ESBoxCell.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/23.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxCell.h"
#import "ESGradientButton.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESBindInitResp.h"

@interface ESBoxCell()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * ipLabel;
@property (nonatomic, strong) UIImageView * boxImageView;
@property (nonatomic, strong) ESGradientButton * loginBtn;

@end

@implementation ESBoxCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setData:(ESNetServiceItem *)data {
    _data = data;
    ESDeviceAbilityModel * model = [[ESDeviceAbilityModel alloc] init];
    model.deviceModelNumber = (int)data.devicemodel;
    
    self.nameLabel.text = [model boxName];
    self.boxImageView.image = [model boxIcon];
    self.ipLabel.text = [NSString stringWithFormat:@"IP: %@", data.ipv4];
}

- (void)onLoginBtn {
    if (self.onLoginBlock) {
        self.onLoginBlock(self.data);
    }
}

- (void)initViews {
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor es_colorWithHexString:@"#EDF3FF"];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 10;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.leading.mas_equalTo(self.contentView).offset(25);
        make.trailing.mas_equalTo(self.contentView).offset(-25);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    UIImageView * bgIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_search_bg"]];
    [bgView addSubview:bgIv];
    [bgIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(bgView);
    }];
    
    self.nameLabel = [UILabel createLabel:ESFontPingFangMedium(18) color:@"#333333"];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView).offset(30);
        make.leading.mas_equalTo(bgView).offset(20);
        make.trailing.mas_equalTo(bgView).offset(-20);
    }];
    
    self.ipLabel = [UILabel createLabel:ESFontPingFangRegular(14) color:@"#333333"];
    self.ipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:self.ipLabel];
    [self.ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(20);
        make.leading.mas_equalTo(bgView).offset(20);
        make.trailing.mas_equalTo(bgView).offset(-20);
    }];
    
    self.boxImageView = [[UIImageView alloc] init];
    [bgView addSubview:self.boxImageView];
    [self.boxImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.top.mas_equalTo(self.ipLabel.mas_bottom).offset(10);
    }];
    
    [bgView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(bgView).offset(41);
        make.trailing.mas_equalTo(bgView).offset(-41);
        make.top.mas_equalTo(self.boxImageView.mas_bottom).offset(20);
        make.bottom.mas_equalTo(bgView).offset(-30);
        make.height.mas_equalTo(44);
    }];
}

- (ESGradientButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_loginBtn setCornerRadius:10];
        [_loginBtn setTitle:NSLocalizedString(@"login_title", @"登录") forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = ESFontPingFangMedium(16);
        [_loginBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(onLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}


@end
