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
//  ESLoginAuthCodeForPlatformController.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/20.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLoginAuthCodeForPlatformController.h"
#import "ESServiceNameHeader.h"

@interface ESLoginAuthCodeForPlatformController ()
@property (nonatomic, strong) ESAuthBkeyCreateResp * authRespModelForPlatform;

@end

@implementation ESLoginAuthCodeForPlatformController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = NSLocalizedString(@"login authorization", @"登录授权");
    self.isAutoLog15Days = YES;
    [self setupViews];
    ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(20).showFrom(UIWindow.keyWindow);
    [self reqAuthBkey];
}

- (void)reqAuthBkey {
    ESDLog(@"[登录授权] reqAuthCode");
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            [ESToast dismiss];
            ESDLog(@"[登录授权] token is nil");
            [ESToast toastError:NSLocalizedString(@"req failed and retry later", @"")];
            return;
        }
        
        
        NSMutableDictionary * body = [NSMutableDictionary dictionary];
        body[@"accessToken"] = token.accessToken;
        body[@"authKey"] = [ESBoxManager.activeBox.info.authKey aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        body[@"clientUUID"] = [ESBoxManager.clientUUID aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        body[@"boxName"] = [ESBoxManager.activeBox.name aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        body[@"boxUUID"] = [ESBoxManager.activeBox.boxUUID aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
        body[@"version"] = @"v2";

        [ESNetworkRequestManager sendRequest:@"/space/v1/api/auth/bkey/create" method:@"POST" queryParams:nil header:nil body:body modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
            ESAuthBkeyCreateResp * respModel = [ESAuthBkeyCreateResp yy_modelWithJSON:response];
            [ESToast dismiss];

            ESDLog(@"[登录授权] reqAuthCode result code:%@, msg:%@", respModel.code, respModel.message);
            self.authRespModelForPlatform = respModel;
            if ([respModel isOK]) {
                respModel.authCodeInfo.authCode = [respModel.authCodeInfo.authCode aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
                respModel.authCodeInfo.bkey = [respModel.authCodeInfo.bkey aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
                if (respModel.authCodeInfo.authCodeTotalExpiresAt > 0) {
                    [self refreshAuthCode];
                } else {
                    [self showAuthCode:self.authRespModelForPlatform];
                }
            } else {
                [ESToast toastError:NSLocalizedString(@"req failed and retry later", @"")];
            }
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [ESToast dismiss];
            ESDLog(@"[登录授权] %s, error:%@", __func__, error);
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }];
    }];
}

- (void)refreshAuthCode {
    if (self.isRefreshingAuth) {
        return;
    }
    self.isRefreshingAuth = YES;
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:@"auth_totp_auth-code" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        self.authRespModel = [[ESAuthBkeyCreateResp alloc] init];
        ESAuthBkeyCreateModel * model = [ESAuthBkeyCreateModel yy_modelWithJSON:response];
        self.authRespModel.authCodeInfo = model;
        [ESToast dismiss];
        self.isRefreshingAuth = NO;
        [self showAuthCode:self.authRespModel];
        ESDLog(@"[登录授权] %s %@", __func__, response);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
        self.isRefreshingAuth = NO;
        ESDLog(@"[登录授权] %s, error:%@", __func__, error);
        [ESToast toastError:NSLocalizedString(@"req failed and retry later", @"")];
    }];
}

- (void)showAuthCode:(ESAuthBkeyCreateResp *)model {
    if (model.authCodeInfo.authCode.length > 4) {
        self.countdownView.hidden = NO;
        self.countdownLabel.hidden = NO;
    }
    
    NSString * authCode = model.authCodeInfo.authCode;
    
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    [attDic setValue:ESFontPingFangMedium(50) forKey:NSFontAttributeName];    // 字体大小
    [attDic setValue:ESColor.primaryColor forKey:NSForegroundColorAttributeName]; // 字体颜色
    [attDic setValue:@20 forKey:NSKernAttributeName];                             // 字间距
    
    if (authCode.length > 0) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:authCode attributes:attDic];
        self.authCodeLabel.attributedText = attStr;
    }
    [self reqBoxInfoByBkey];
    [self createTimer];
}

- (void)createTimer {
    ESDLog(@"[登录授权] timer call");
    if (self.authRespModel.authCodeInfo.authCode.length <= 4) {
        ESDLog(@"[登录授权] timer 验证码只有4位：%@", self.authRespModel.authCodeInfo.authCode);
        // Old Version
        return;
    }
    
    weakfy(self);
    long max = self.authRespModel.authCodeInfo.authCodeTotalExpiresAt / 1000;
    self.countValue = self.authRespModel.authCodeInfo.authCodeExpiresAt / 1000;
    if (self.countValue == 0) {
        ESDLog(@"[登录授权] timer reqauthcode, countValue=0");
        ESPerformBlockAfterDelay(1, ^{
            [self refreshAuthCode];
        });
        return;
    }
    ESDLog(@"[登录授权] timer countValue:%ld", self.countValue);
    [self.countdownView reloadWithProgress:(max - self.countValue) * 1.0 / max];
    self.countdownLabel.text = [NSString stringWithFormat:@"%ld", self.countValue];
    
    [self stopTimer];
    
    ESDLog(@"[登录授权] timer create");
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        strongfy(self);
        self.countValue --;
        ESDLog(@"[登录授权] timer loop %ld", self.countValue);

        if (self.countValue == 0) {
            ESDLog(@"[登录授权] timer reqauthcode");
            [self refreshAuthCode];
        }
        if (self.countValue >= 0) {
            [self.countdownView reloadWithProgress:(max - self.countValue) * 1.0 / max];
            self.countdownLabel.text = [NSString stringWithFormat:@"%ld", self.countValue];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc {
    [self stopTimer];
}

- (void)reqBoxInfoByBkey {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSMutableDictionary * body = [NSMutableDictionary dictionary];
    body[@"bkey"] = self.authRespModelForPlatform.authCodeInfo.bkey;
    body[@"boxPubKey"] = [ESRSACenter boxPair:ESBoxManager.activeBox.boxUUID].publicKey.pem;
    body[@"pkey"] = self.v;
    NSString * ud = dic[@"userDomain"];
    if (ud.length < 1) {
        ud = ESBoxManager.realdomain;
    }
    body[@"userDomain"] = ud;
    body[@"lanDomain"] = self.authRespModelForPlatform.authCodeInfo.lanDomain;
    body[@"lanIp"] = self.authRespModelForPlatform.authCodeInfo.lanIp;

    NSString * relativePath = [[NSString alloc] initWithFormat:@"/v2/platform/pkeys/%@/boxinfo", self.v];
    [ESNetworkRequestManager sendRequest:ESPlatformClient.platformClient.platformUrl path:relativePath method:@"POST" queryParams:nil header:nil body:body modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self reqAuthResultPoll];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[登录授权] %s, error:%@", __func__, error);
        [ESToast toastError:NSLocalizedString(@"The request failed, please scan the qrcode again!", @"请求失败，请重新扫码！")];
    }];
}

- (void)reqAuthResultPoll {
    if (self.isReqingPoll) {
        return;
    }
    self.isReqingPoll = YES;
    ESDLog(@"[登录授权] reqAuthResultPoll %@", [NSThread currentThread]);
    ESSpaceGatewayQRCodeScanningServiceApi *api = [ESSpaceGatewayQRCodeScanningServiceApi new];
    NSNumber * autoLogin = self.isAutoLog15Days ? @(1) : @(0);

    weakfy(self);
    [api spaceV1ApiAuthBkeyPollPostWithBkey:self.authRespModelForPlatform.authCodeInfo.bkey autoLogin:autoLogin completionHandler:^(ESVerifyTokenResult *output, NSError *error) {
        if (error) {
            ESPerformBlockAfterDelay(5, ^{
                strongfy(self);
                self.isReqingPoll = NO;
                [self reqAuthResultPoll];
            });
            return;
        }
        ESDLog(@"[登录授权] reqPoll for platform auth result:%@", output.result);
        if ([output.result boolValue]) {
            [ESToast toastInfo:NSLocalizedString(@"Login Success", @"登录成功")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            self.tabBarController.selectedIndex = 0;
            self.tabBarController.tabBar.hidden = NO;
        } else {
            ESPerformBlockAfterDelay(5, ^{
                strongfy(self);
                self.isReqingPoll = NO;
                [self reqAuthResultPoll];
            });
        }
    }];
}

- (void)setupViews {
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(26);
        make.trailing.mas_equalTo(self.view).offset(-26);
        make.top.mas_equalTo(self.view).offset(60);
    }];
    
    UIView * bgView = [[UIView alloc] init];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 10;
    bgView.backgroundColor = [UIColor es_colorWithHexString:@"#F8FAFF"];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(26);
        make.trailing.mas_equalTo(self.view).offset(-26);
        make.top.mas_equalTo(self.nickNameLabel.mas_bottom).offset(30);
    }];
    
    // 本次登录授权码为
    UILabel * label = [[UILabel alloc] init];
    {
        label.textColor = ESColor.labelColor;
        label.text = NSLocalizedString(@"login_authorization", nil);
        label.numberOfLines = 0;
        label.font = ESFontPingFangMedium(16);
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(bgView).offset(22);
            make.trailing.mas_equalTo(bgView).offset(-22);
            make.top.mas_equalTo(bgView).offset(30);
        }];
    }
    
    // auth code
    UILabel * label1 = [[UILabel alloc] init];
    {
        self.authCodeLabel = label1;
        label1.adjustsFontSizeToFitWidth = YES;
        label1.textColor = ESColor.primaryColor;
        label1.font = ESFontPingFangMedium(50);
        [bgView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(bgView).offset(22);
            make.top.mas_equalTo(label.mas_bottom).offset(20);
            make.height.mas_equalTo(60);
            make.trailing.mas_equalTo(bgView).offset(-70);
        }];
    }
    
    // countdown view
    ESCountdownView * cdView = [[ESCountdownView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    self.countdownView = cdView;
    cdView.hidden = YES;
    [bgView addSubview:cdView];
    [cdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(bgView).offset(-20);
        make.centerY.mas_equalTo(self.authCodeLabel);
        make.width.height.mas_equalTo(26);
    }];
    
    // countdown time label
    {
        UILabel * label = [[UILabel alloc] init];
        label.hidden = YES;
        self.countdownLabel = label;
        label.textColor = ESColor.primaryColor;
        label.font = ESFontPingFangMedium(10);
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.countdownView);
        }];
    }
    
    UIView * lineView = [[UIView alloc] init];
    [bgView addSubview:lineView];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#E5E6EC"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(bgView).offset(22);
        make.trailing.mas_equalTo(bgView).offset(-22);
        make.top.mas_equalTo(self.authCodeLabel.mas_bottom).offset(9);
        make.height.mas_equalTo(1);
    }];
    
    [bgView addSubview:self.autoLoginBtn];
    [self.autoLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(bgView).offset(22);
        make.top.mas_equalTo(lineView.mas_bottom).offset(25);
        make.width.height.mas_equalTo(12);
        make.bottom.mas_equalTo(bgView).offset(-30);
    }];
    
    // 15天内自动登录
    {
        UILabel * label = [[UILabel alloc] init];
        label.text = NSLocalizedString(@"Automatic login within 15 days", @"");
        label.textColor = ESColor.labelColor;
        label.font = ESFontPingFangRegular(14);
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.autoLoginBtn);
            make.leading.mas_equalTo(self.autoLoginBtn.mas_trailing).offset(5);
        }];
    }
    
    {
        // 为确保空间的数据安全，请勿泄漏此授权码
        UILabel * label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.text = NSLocalizedString(@"Login Auth Code Hint", @"");
        label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
        label.font = ESFontPingFangRegular(14);
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view).offset(26);
            make.trailing.mas_equalTo(self.view).offset(-26);
            make.top.mas_equalTo(bgView.mas_bottom).offset(30);
        }];
    }
}

- (void)onAutoLoginBtn:(UIButton *)sender {
    self.isAutoLog15Days = !self.isAutoLog15Days;
    NSString * imageName = self.isAutoLog15Days ? @"login_auto_sed" : @"login_auto";
    [self.autoLoginBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (UIButton *)autoLoginBtn {
    if (!_autoLoginBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setEnlargeEdge:UIEdgeInsetsMake(10, 10, 10, 20)];
        [btn setImage:[UIImage imageNamed:@"login_auto_sed"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onAutoLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
        _autoLoginBtn = btn;
    }
    return _autoLoginBtn;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        UILabel * label = [[UILabel alloc] init];
        label.textColor = ESColor.labelColor;
        NSString * name = [ESAccountManager manager].userInfo.personalName;
        // 傲空间账号 %@ 在其他终端登录使用
        label.text = [NSString stringWithFormat:NSLocalizedString(@"login authorization hint", nil), name];
        label.numberOfLines = 0;
        label.font = ESFontPingFangMedium(16);
        if (name) {
            NSRange range = [label.text rangeOfString:name];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:label.text];
            [attrString addAttribute:NSForegroundColorAttributeName value:ESColor.primaryColor range:range];
            [label setAttributedText:attrString];
        } else {
            label.text = [NSString stringWithFormat:NSLocalizedString(@"login authorization hint 1", nil), name];
        }
        
        [self.view addSubview:label];
        _nickNameLabel = label;
    }
    return _nickNameLabel;
}


// 是否是通过扫描盒子侧的二维码来授权登录的; 默认是平台侧
+ (BOOL)isLoginFromBox:(NSString *)bt {
    if ([bt isEqualToString:@"box-login"]) {
        return YES;
    }
    
    return NO;
}

@end
