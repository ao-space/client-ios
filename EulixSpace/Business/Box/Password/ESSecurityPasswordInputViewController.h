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
//  ESSecurityPasswordInputViewController.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <YCBase/YCBase.h>
#import "ESBoxBindViewModel.h"
#import "UIColor+ESHEXTransform.h"
#import "ESAccountInfoStorage.h"
#import "ESAuthenticationTypeController.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESReTransmissionManager.h"
#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "ESPinCodeTextField.h"
#import "ESThemeDefine.h"

typedef NS_ENUM(NSUInteger, ESSecurityPasswordType) {
    ESSecurityPasswordTypeInput,
    ESSecurityPasswordTypeBind,
    ESSecurityPasswordTypeUnbind, //老盒子验证
    ESSecurityPasswordTypeUnbindBox, //解绑验证
};

#define ESSecurityPasswordInputFailedTimes @"ESSecurityPasswordInputFailedTimes"

@interface ESSecurityPasswordInputViewController : YCViewController<ESSecuritySettingJumpDelegate>

@property (nonatomic, strong) UIButton *showPromptButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) ESPinCodeTextField *pinCodeTextField;

@property (nonatomic, strong) ESBoxBindViewModel *viewModel;

@property (nonatomic, assign) ESSecurityPasswordType type;

@property (nonatomic, assign) ESAuthenticationType authType;

@property (nonatomic, copy) void (^inputDone)(NSString *password);


@property (nonatomic, strong) UIButton * forgetPasswordBtn;
- (void)editingChanged:(UITextField *)sender;
- (void)onForgetPasswordBtn;


@end
