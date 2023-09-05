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
//  ESPassWordCheckVC.m
//  EulixSpace
//
//  Created by qu on 2022/9/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPassWordCheckVC.h"
#import "ESAuthenticationApplyController.h"
#import "ESAuthenticationTypeController.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@interface ESPassWordCheckVC ()

@end

@implementation ESPassWordCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Secure Password Authentication", @"安全密码验证");

    
}


- (void)editingChanged:(UITextField *)sender {
    if (sender.text.length < 6) {
        return;
    }
    [self verifySecurityPasswordForSetEmail:sender.text];
}

- (void)onForgetPasswordBtn {
    
    ESAuthenticationTypeController * ctl = [[ESAuthenticationTypeController alloc] init];
    ctl.authType = ESAuthenticationTypeBinderResetPassword;
    [self.navigationController pushViewController:ctl animated:YES];
    
//    if (self.authType == ESAuthenticationTypeBinderModifyEmail
//        || self.authType == ESAuthenticationTypeBinderSetEmail) {
//        ctl.authType = ESAuthenticationTypeBinderResetPassword;
//        [self.navigationController pushViewController:ctl animated:YES];
//        return;
//    }
//
//    if (self.authType == ESAuthenticationTypeAutherModifyEmail
//        || self.authType == ESAuthenticationTypeAutherSetEmail) {
//        [self applyAuth:ESAuthenticationTypeAutherResetPassword];
//    } else {
//        [ESToast toastInfo:@"类型不对"];
//    }
}

- (void)applyAuth:(ESAuthenticationType)authType {
    NSString * key = [[NSString alloc] initWithFormat:@"ESAutherApplyResetPs_%lu", (unsigned long)authType];
    if ([[ESReTransmissionManager Instance] failedEventIsResume:key distance:60] == NO) {
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        return;
    }
    
    weakfy(self);
    [ESAuthenticationApplyController showAuthApplyView:self type:authType block:^(ESAuthApplyRsp * applyRsp) {
        if (applyRsp.accept) {

        }
    } cancel:^{
        [[ESReTransmissionManager Instance] addFailedEvent:key distance:60 max:3];
    }];
}

- (void)gotoAuthenticationTypeView:(ESAuthApplyRsp *)applyRsp type:(ESAuthenticationType)authType {

//    ESAuthenticationTypeController * ctl = [[ESAuthenticationTypeController alloc] init];
//    ctl.authType = authType;
//    ctl.applyRsp = applyRsp;
//    ctl.emailInfo = self.emailInfo;
  
}


- (void)verifySecurityPasswordForSetEmail:(NSString *)password {
    self.errorLabel.hidden = YES;
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    NSMutableDictionary * req = [NSMutableDictionary dictionary];
    req[@"oldPasswd"] = password;
    weakfy(self);
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:security_passwd_verify queryParams:nil header:nil body:req modelName:nil successBlock:^(NSInteger requestId, NSDictionary * response) {
        [ESToast dismiss];
        if (![response isKindOfClass:[NSDictionary class]]) {
            return;
        }
        if (weak_self.securityPasswordBlock) {
            weak_self.securityPasswordBlock(0, nil, nil);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
        NSString * msg = [error errorMessage];
        if ([[error codeString] isEqualToString:@"ACC-403"]) {
            [weak_self.pinCodeTextField clearText];
            // 密码错误
            int num = [[ESReTransmissionManager Instance] addFailedEvent:ESSecurityPasswordInputFailedTimes distance:60 max:3];
            if (num == 0) {
                if (weak_self.securityPasswordBlock) {
                    weak_self.securityPasswordBlock(1, nil, nil);
                }
            } else {
                weak_self.errorLabel.hidden = NO;
                weak_self.errorLabel.text = [NSString stringWithFormat:TEXT_BOX_UNBIND_PASSWORD_ERROR_PROMPT, @(num)];
            }
            return;
        }else  if([msg isEqual:@"client request rate is over limit"]){
            msg = @"密码输入错误超出限制，请1分钟后重试。";
            [ESToast toastError:msg];
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}



@end
