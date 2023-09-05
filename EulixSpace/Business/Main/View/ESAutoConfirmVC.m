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
//  ESAutoConfirmVC.m
//  EulixSpace
//
//  Created by qu on 2022/6/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

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
#import "ESToast.h"

@interface ESAutoConfirmVC()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *userDomin;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *iconImageView;

@property (nonatomic, strong) UIButton *iconBtnSelect;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *automaticLogon;
@property (nonatomic, strong) ESGradientButton *loginButton;

@end

@implementation ESAutoConfirmVC


-(void)viewDidLoad{
    [super viewDidLoad];
    [self initLayout];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)initLayout{
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(110.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(100.0f);
        make.width.mas_equalTo(100.0f);
    }];
    
    self.headImageView.layer.cornerRadius = 50;
    self.headImageView.layer.masksToBounds = YES;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImageView.mas_bottom).offset(48.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(22.0f);
        make.width.mas_equalTo(ScreenWidth - 60);
    }];
    
    [self.userDomin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(18.0f);
        make.width.mas_equalTo(ScreenWidth - 60);
    }];
    
    [self.automaticLogon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userDomin.mas_bottom).offset(80.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(18.0f);
//        make.width.mas_equalTo(85.0f);
    }];
    
    [self.iconBtnSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.automaticLogon.mas_centerY).offset(0);
        make.right.mas_equalTo(self.automaticLogon.mas_left).offset(10.0);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(kBottomHeight + 122);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(kBottomHeight + 100);
    }];
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",dic[@"personalName"], NSLocalizedString(@"es_affiliate_eulix_space", @"的傲空间")];
    self.userDomin.text =  dic[@"userDomain"];
    NSString *path = dic[@"imagePath"];
    self.headImageView.image = [UIImage imageWithContentsOfFile:path.fullCachePath];
  
}

- (UILabel *)automaticLogon {
    if (!_automaticLogon) {
        _automaticLogon = [[UILabel alloc] init];
        _automaticLogon.textColor = ESColor.labelColor;
        _automaticLogon.text = NSLocalizedString(@"es_automatic_login_hint", "15天内自动登录");
        _automaticLogon.textAlignment = NSTextAlignmentCenter;
        _automaticLogon.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.view addSubview:_automaticLogon];
    }
    return _automaticLogon;
}

- (UIButton *)iconBtnSelect {
    if (!_iconBtnSelect) {
        _iconBtnSelect = [[UIButton alloc] init];
        _iconBtnSelect.selected = YES;
        [_iconBtnSelect setImage:IMAGE_LOGIN_AUTO_SED forState:UIControlStateNormal];
        [_iconBtnSelect addTarget:self action:@selector(iconBtnSelectAct:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_iconBtnSelect];
    }
    return _iconBtnSelect;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.text = @"授权浏览器登录 元气满满喵 的傲空间";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)userDomin {
    if (!_userDomin) {
        _userDomin = [[UILabel alloc] init];
        _userDomin.textColor = ESColor.labelColor;
        _userDomin.textAlignment = NSTextAlignmentCenter;
        _userDomin.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_userDomin];
    }
    return _userDomin;
}

- (UIButton *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIButton alloc] init];
        [self.view addSubview:_iconImageView];
        [_iconImageView setImage:nil forState:UIControlStateNormal];
        [_iconImageView addTarget:self action:@selector(iconBtnSelectAct:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [UIImageView new];
        _headImageView.image = IMAGE_PUSH_HEAD;
        [self.view addSubview:_headImageView];
    }
    return _headImageView;
}

- (ESGradientButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_loginButton setCornerRadius:10];
        [_loginButton setTitle:TEXT_LOGIN_TITLE forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_loginButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_loginButton setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [self.view addSubview:_loginButton];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 164);
        }];
    }
    return _loginButton;
}


-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_cancelBtn setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_cancelBtn setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [self.view addSubview:_cancelBtn];
        [_cancelBtn addTarget:self action:@selector(cancelloginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (void)cancelloginAction{
    ESSpaceGatewayQRCodeScanningServiceApi *api =  [ESSpaceGatewayQRCodeScanningServiceApi new];
    ESAuthorizedTerminalLoginConfirmInfo *info =  [ESAuthorizedTerminalLoginConfirmInfo new];
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            return;
        }
        info.encryptedClientUUID = [self.clientUUID aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        info.login = @(0);
        if(self.iconBtnSelect.selected){
            info.autoLogin = @(1);
        }else{
            info.autoLogin = @(0);
        }
 
        info.accessToken = token.accessToken;
        [api spaceV1ApiAuthAutoLoginConfirmPostWithBody:info completionHandler:^(ESResponseBaseVerifyTokenResult *output, NSError *error) {
            if (!error && [output.code isEqualToString:@"GW-200"]) {
                NSLog(@"%@",output);
            }else{
                if(error){
                     [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                }
            }
        }];
    }];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)loginAction{
    ESSpaceGatewayQRCodeScanningServiceApi *api =  [ESSpaceGatewayQRCodeScanningServiceApi new];
    ESAuthorizedTerminalLoginConfirmInfo *info =  [ESAuthorizedTerminalLoginConfirmInfo new];
    
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            return;
        }
        info.encryptedClientUUID = [self.clientUUID aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        info.login = @(1);
        if(self.iconBtnSelect.selected){
            info.autoLogin = @(1);
        }else{
            info.autoLogin = @(0);
        }
        info.accessToken = token.accessToken;
        [api spaceV1ApiAuthAutoLoginConfirmPostWithBody:info completionHandler:^(ESResponseBaseVerifyTokenResult *output, NSError *error) {
            if (!error && [output.code isEqualToString:@"GW-200"]) {
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }];
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


@end
