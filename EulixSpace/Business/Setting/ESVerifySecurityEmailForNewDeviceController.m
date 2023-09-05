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
//  ESVerifySecurityEmailForNewDeviceController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVerifySecurityEmailForNewDeviceController.h"
#import "ESBoxManager.h"
#import "ESReTransmissionManager.h"

@interface ESVerifySecurityEmailForNewDeviceController ()<ESBoxBindViewModelDelegate>

@end

@implementation ESVerifySecurityEmailForNewDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Confidential email verification", @"密保邮箱验证");
    self.viewModel.delegate = self;
}

- (void)onVerifyBtn {
    if (self.accountStr.length <= 0 || self.emailPasswordStr.length <= 0) {
        [self showAlert:NSLocalizedString(@"account_password_empty_hint", @"账号、密码为必填项，请检查后重新输入")];
        return;
    }
    
    [self sendReq];
}

- (void)sendReq {
    [self.verfiryBtn startLoading:NSLocalizedString(@"verifying", @"正在验证...")];
    
    ESSecurityEmailVerityReq * req = [[ESSecurityEmailVerityReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_email_verify_local;
    req.apiPath = api_security_email_verify_local;
    req.entity.emailAccount = self.accountStr;
    req.entity.emailPasswd = [self.emailPasswordStr toHexString];
    req.entity.host = self.hostStr;
    req.entity.port = self.portStr;
    req.entity.sslEnable = @(self.enableSSL);
    req.entity.clientUuid = ESBoxManager.clientUUID;
    
    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESDLog(@"[安保功能] 收到Passthrough:%@", rspDict);
    [self.verfiryBtn stopLoading:NSLocalizedString(@"verify", @"验证")];
    NSString * title = NSLocalizedString(@"auth verify failed", @"身份验证失败");
    NSString * content = NSLocalizedString(@"req failed and retry later", @"请求失败，请稍后重试!");

    ESSecurityEmailVerityRsp * rsp = [ESSecurityEmailVerityRsp.class yy_modelWithJSON:rspDict];
    if (![rsp.code isEqualToString:@"AG-200"]) {
        [self showAlert:content];
        return;
    }
    
    if ([rsp.results codeValue] == 200) {
        if (rsp.results.securityToken.length <= 0) {
            return;
        }
        if (self.verifySecurityEmailBlock) {
            self.verifySecurityEmailBlock(0, rsp.results.expiredAt, rsp.results.securityToken);
        }
        return;
    }
    if ([rsp.results codeValue] == ESSecurityEmailResult_AUTHENTICATION_FAIL) {
        [self bindResult:ESSecurityEmailResult_AUTHENTICATION_FAIL title:title msg:@""];
        return;
    }
    
    [self bindResult:[rsp.results codeValue] title:title msg:content];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
