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
//  ESBindSecurityEmailBySecurityCodeController.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESGradientButton.h"
#import "NSString+ESTool.h"
#import "ESTapTextView.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESToast.h"
#import "ESSecurityEmailMamager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESBindSecurityEmailBySecurityCodeController : YCViewController

@property (nonatomic, assign) ESAuthenticationType authType;

@property (nonatomic, strong) NSString * expiredAt;
@property (nonatomic, strong) NSString * securityToken;

@property (nonatomic, strong) NSString * accountStr;
@property (nonatomic, strong) NSString * emailPasswordStr;
@property (nonatomic, strong) NSString * hostStr;
@property (nonatomic, strong) NSString * portStr;
@property (nonatomic, assign) bool enableSSL;

@property (nonatomic, strong) ESGradientButton * verfiryBtn;
@property (nonatomic, strong) ESTapTextView * tapView;

- (void)sendReq;
- (void)bindResult:(long)code title:(NSString *)title msg:(NSString *)msg;
- (void)onHelpView;
- (void)onVerifyBtn;
@end

NS_ASSUME_NONNULL_END
