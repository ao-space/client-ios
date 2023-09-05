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
//  ESSecurityPasswordResetByEmailController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordResetByEmailController.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"

@interface ESSecurityPasswordResetByEmailController ()<ESBoxBindViewModelDelegate>

@end

@implementation ESSecurityPasswordResetByEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewModel.delegate = self;
}

- (void)onDoneBtn {
    NSString * nPs = [self getNewPassword];
    NSString * cPs = [self getConfirmPassword];
    if ([self checkInput:nPs cPs:cPs] == NO) {
        return;
    }
    
    [self.view endEditing:YES];
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"newPasswd"] = nPs;
    
    NSString * apiName;
    if (self.authType == ESAuthenticationTypeBinderResetPassword) {
        apiName = security_passwd_reset_binder;
        params[@"securityToken"] = self.securityToken;
    } else if (self.authType == ESAuthenticationTypeAutherResetPassword) {
        apiName = security_passwd_reset_auther;
        params[@"acceptSecurityToken"] = self.applyRsp.securityToken;//绑定端允许拿到的 securityToken
        params[@"emailSecurityToken"] = self.securityToken;//邮箱验证通过拿到的 securityToken
        params[@"clientUuid"] = self.applyRsp.clientUuid;
        params[@"applyId"] = self.applyRsp.applyId;
    } else if (self.authType == ESAuthenticationTypeNewDeviceResetPassword) {
        [self sendReqByLocal];
        return;
    } else {
        [ESToast toastInfo:@"类型不对"];
    }

    weakfy(self);
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:apiName queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id response) {
        [weak_self resetResult:0];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        long code = [error errorCode];
        [weak_self resetResult:code];
    }];
}

- (void)sendReqByLocal {
    if (self.authType != ESAuthenticationTypeNewDeviceResetPassword) {
        return;
    }
    
    ESSecurityPasswordResetBinderReq * req = [[ESSecurityPasswordResetBinderReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_passwd_reset_newdevice_local;
    req.apiPath = api_security_passwd_reset_newdevice_local;
    
    req.entity.acceptSecurityToken = self.applyRsp.securityToken;
    req.entity.emailSecurityToken = self.securityToken;
    req.entity.clientUuid = self.applyRsp.clientUuid;
    req.entity.newPasswd = [self getNewPassword];
    req.entity.applyId = self.applyRsp.applyId;
    req.entity.newDeviceClientUuid = ESBoxManager.clientUUID;
    
    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESSecurityPasswordResetBinderRsp * rsp = [ESSecurityPasswordResetBinderRsp.class yy_modelWithJSON:rspDict];
    if (rsp.codeValue != 200) {
        [self resetResult:-1];
        return;
    }
    if (rsp.results.codeValue == 200) {
        [self resetResult:0];
    } else {
        [self resetResult:rsp.results.codeValue];
    }
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
