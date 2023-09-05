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
//  ESPushWaitView.m
//  EulixSpace
//
//  Created by qu on 2022/6/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPushWaitView.h"
#import "ESAutoConfirmVC.h"
#import <YCBase/YCItemDefine.h>
#import "ESColor.h"
#import "ESGradientButton.h"
#import "ESImageDefine.h"
#import <Masonry/Masonry.h>
#import "ESThemeDefine.h"
#import "ESBoxManager.h"
#import "ESSpaceGatewayQRCodeScanningServiceApi.h"
#import "ESAES.h"
#import "ESGatewayManager.h"
#import "ESAccountManager.h"
#import "ESLocalPath.h"
@interface ESPushWaitView()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *userDomin;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *iconImageView;

@property (nonatomic, strong) UIButton *iconBtnSelect;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *automaticLogon;
@property (nonatomic, strong) ESGradientButton *loginButton;

@property (nonatomic, strong) UIView *programView;

@end

@implementation ESPushWaitView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}


-(void)initUI{
    self.programView.contentMode = UIViewContentModeScaleAspectFit;
    self.programView.layer.cornerRadius = 10;
    self.programView.layer.masksToBounds = YES;
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(28.0f);
        make.right.equalTo(self.mas_right).offset(-28.0f);
        make.height.equalTo(@(450));
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(60.0f);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(100.0f);
        make.width.mas_equalTo(100.0f);
    }];
    
    self.headImageView.layer.cornerRadius = 50;
    self.headImageView.layer.masksToBounds = YES;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImageView.mas_bottom).offset(48.0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(22.0f);
//        make.width.mas_equalTo(ScreenWidth - 60);
    }];
    
    [self.userDomin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10.0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(18.0f);
        make.width.mas_equalTo(ScreenWidth - 60);
    }];
    
    [self.automaticLogon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userDomin.mas_bottom).offset(50.0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(18.0f);
//        make.width.mas_equalTo(200.0f);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).inset(kBottomHeight + 122);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.programView.mas_bottom).inset(40.0f);
    }];
}

- (UILabel *)automaticLogon {
    if (!_automaticLogon) {
        _automaticLogon = [[UILabel alloc] init];
        _automaticLogon.textColor = ESColor.primaryColor;
        _automaticLogon.text = NSLocalizedString(@"grantee_request_login_hint", @"请在绑定手机上确定登录");
        _automaticLogon.textAlignment = NSTextAlignmentCenter;
        _automaticLogon.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        [self.programView addSubview:_automaticLogon];
    }
    return _automaticLogon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)userDomin {
    if (!_userDomin) {
        _userDomin = [[UILabel alloc] init];
        _userDomin.textColor = ESColor.labelColor;
  
        _userDomin.textAlignment = NSTextAlignmentCenter;
        _userDomin.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.programView addSubview:_userDomin];
    }
    return _userDomin;
}

- (UIButton *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIButton alloc] init];
        [self addSubview:_iconImageView];
        [_iconImageView setImage:nil forState:UIControlStateNormal];
        [_iconImageView addTarget:self action:@selector(iconBtnSelectAct:) forControlEvents:UIControlEventTouchUpInside];
        [self.programView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [UIImageView new];
        _headImageView.image = IMAGE_PUSH_HEAD;
        [self.programView addSubview:_headImageView];
    }
    return _headImageView;
}


-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_cancelBtn setTitle:@"取消登录" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_cancelBtn setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [self addSubview:_cancelBtn];
        [_cancelBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)loginAction{
    self.hidden = YES;
    if (self.actionBlock) {
        self.actionBlock(@(1));
    }
}


- (void)iconBtnSelectAct:(UIButton *)btn {
    if(!btn.selected){
        self.iconBtnSelect.selected = YES;
        [_iconBtnSelect setImage:IMAGE_LOGIN_AUTO_SED forState:UIControlStateNormal];
    }else{
        [_iconBtnSelect setImage:IMAGE_LOGIN_AUTO forState:UIControlStateNormal];
        self.iconBtnSelect.selected = NO;
    }
}

- (void)loginAction:(UIButton *)btn{
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] init];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        [self addSubview:_programView];
    }
    return _programView;
}

-(void)setNameStr:(NSString *)nameStr{
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",nameStr, NSLocalizedString(@"es_affiliate_eulix_space", @"的傲空间")];
}

-(void)setDomainStr:(NSString *)domainStr{
    self.userDomin.text = domainStr;
}

-(void)setImagePath:(NSString *)domainStr{
    UIImage *image = [UIImage imageWithContentsOfFile:domainStr.shareCacheFullPath];
    ESDLog(@"[setImagePath] shareCacheFullPath: %@ path:%@", image, domainStr.shareCacheFullPath);
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:domainStr.fullCachePath];
        ESDLog(@"[setImagePath] fullCachePath: %@ path:%@", image, domainStr.fullCachePath);
    }
    self.headImageView.image = image;
    [self setNeedsLayout];
}

@end
