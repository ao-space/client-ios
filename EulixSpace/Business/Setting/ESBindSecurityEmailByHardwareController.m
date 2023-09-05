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
//  ESBindSecurityEmailByHardwareController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBindSecurityEmailByHardwareController.h"
#import "ESServiceNameHeader.h"
#import "ESGatewayManager.h"
#import "ESToast.h"
#import <YYModel/YYModel.h>
#import "ESSecurityEmailBindSuccessController.h"

@interface ESBindSecurityEmailByHardwareController ()

@end

@implementation ESBindSecurityEmailByHardwareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewModel.delegate = self;
}

- (void)sendReq {
    weakfy(self);
    [self.verfiryBtn startLoading:NSLocalizedString(@"verifying", @"正在验证...")];
    
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (token && token.accessToken.length > 0) {
            weak_self.securityToken = token.accessToken;
            [weak_self doSend];
            return;
        }
        [weak_self.verfiryBtn stopLoading:NSLocalizedString(@"verify", @"验证")];
        [ESToast toastError:@"req failed and retry later"];
    }];
}

- (void)doSend {
    ESSecurityEmailSetReq * req = [[ESSecurityEmailSetReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.apiName = api_security_email_set_binder_local;
    req.apiPath = api_security_email_set_binder_local;
    if (self.authType == ESAuthenticationTypeBinderModifyEmail) {
        req.apiName = api_security_email_modify_binder_local;
        req.apiPath = api_security_email_modify_binder_local;
    } else if (self.authType == ESAuthenticationTypeAutherModifyEmail) {
        req.apiName = api_security_email_modify_auther_local;
        req.apiPath = api_security_email_modify_auther_local;
    }  else if (self.authType == ESAuthenticationTypeAutherSetEmail) {
        req.apiName = api_security_email_set_auther_local;
        req.apiPath = api_security_email_set_auther_local;
    }
    req.entity.accessToken = self.securityToken;
    req.entity.emailAccount = self.accountStr;
    req.entity.emailPasswd = [self.emailPasswordStr toHexString];
    req.entity.host = self.hostStr;
    req.entity.port = self.portStr;
    req.entity.sslEnable = self.enableSSL;

    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

#pragma -mark viewmodel delegate
- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESDLog(@"[安保功能] 蓝牙或局域网设置密保邮箱结果：%@", rspDict);
    
    ESSecurityEmailSetRsp * rsp = [ESSecurityEmailSetRsp.class yy_modelWithJSON:rspDict];
    ESBaseResp * realRsp = rsp.results;

    if ([rsp isOK] && [realRsp isOK]) {
        [self bindResult:ESSecurityEmailResult_AUTHENTICATION_SUCCESS title:@"" msg:@""];
    } else {
        long errCode = [realRsp codeValue];
        NSString * title = NSLocalizedString(@"bind failed", @"绑定失败");
        NSString * content = rsp.message;
        [self bindResult:errCode title:title msg:content];
    }
}

- (void)dealloc {
    
}

@end
