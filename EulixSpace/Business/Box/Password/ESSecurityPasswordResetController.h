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
//  ESSecurityPasswordResetController.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESBoxBindViewModel.h"
#import "ESToast.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESSecurityEmailMamager.h"
#import "ESNotifiResp.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESSecurityPasswordResetController : YCViewController
@property (nonatomic, strong) ESBoxBindViewModel *viewModel;


@property (nonatomic, assign) ESAuthenticationType authType;
@property (nonatomic, strong) ESAuthApplyRsp * applyRsp;

- (NSString *)getNewPassword;
- (NSString *)getConfirmPassword;
- (BOOL)checkInput:(NSString *)nPs cPs:(NSString *)cPs;
- (void)onDoneBtn;
- (void)sendReq:(NSString *)accessToken ps:(NSString *)ps;
// code:0 表示设置成功
- (void)resetResult:(long)code;
@end

NS_ASSUME_NONNULL_END
