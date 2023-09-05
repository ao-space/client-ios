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
//  ESLoginAuthCodeForPlatformController.h
//  EulixSpace
//
//  Created by dazhou on 2023/3/20.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESAccountManager.h"
#import "ESCountdownView.h"
#import "UIColor+ESHEXTransform.h"
#import "UIButton+ESTouchArea.h"
#import "ESGatewayManager.h"
#import "ESAccountServiceApi.h"
#import "ESCreateAuthCodeResult.h"
#import "ESPlatformAuthServiceApi.h"
#import "ESSpaceGatewayQRCodeScanningServiceApi.h"
#import "ESBoxManager.h"
#import "ESAES.h"
#import "ESToast.h"
#import "ESRSACenter.h"
#import "ESPlatformClient.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESNetworkRequestManager.h"
#import "ESLoginAuthModel.h"
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

// 为 平台侧 的登录展示授权码
@interface ESLoginAuthCodeForPlatformController : YCViewController

// 产品名， aospace
@property (nonatomic, strong) NSString * p;

/** 业务类型（business type）
box-login : 从盒子登录，包括局域网、用户域名。
platform-login : 从平台登录
 */
@property (nonatomic, strong) NSString * bt;

//  v：业务对应的值，如 pkey， bkey 等
@property (nonatomic, strong) NSString * v;


@property (nonatomic, strong) UILabel * nickNameLabel;
@property (nonatomic, strong) UILabel * authCodeLabel;
@property (nonatomic, strong) UIButton * autoLoginBtn;

@property (nonatomic, strong) ESCountdownView * countdownView;
@property (nonatomic, strong) UILabel * countdownLabel;
@property (nonatomic, assign) long countValue;

@property (nonatomic, strong, nullable) NSTimer * timer;
@property (nonatomic, strong) ESAuthBkeyCreateResp * authRespModel;
@property (nonatomic, assign) BOOL isAutoLog15Days;

@property (nonatomic, assign) BOOL hasSendPoll;
@property (nonatomic, assign) BOOL isReqingAuth;
@property (nonatomic, assign) BOOL isRefreshingAuth;

@property (nonatomic, assign) BOOL isReqingPoll;

// 请求展示的授权码
- (void)reqAuthBkey;
- (void)refreshAuthCode;
- (void)showAuthCode:(ESAuthBkeyCreateResp *)model;
- (void)reqBoxInfoByBkey;
- (void)reqAuthResultPoll;

// 是否是通过扫描盒子侧的二维码来授权登录的; 默认是平台侧
+ (BOOL)isLoginFromBox:(NSString *)bt;

@end

NS_ASSUME_NONNULL_END
