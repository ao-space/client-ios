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
//  ESBindSecurityEmailByEmailController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBindSecurityEmailByEmailController.h"

@interface ESBindSecurityEmailByEmailController ()

@end

@implementation ESBindSecurityEmailByEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)sendReq {
    weakfy(self);
    [self.verfiryBtn startLoading:NSLocalizedString(@"verifying", @"正在验证...")];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    param[@"securityToken"] = self.securityToken;
    param[@"emailAccount"] = self.accountStr;
    param[@"emailPasswd"] = [self.emailPasswordStr toHexString];
    param[@"host"] = self.hostStr;
    param[@"port"] = self.portStr;
    param[@"sslEnable"] = @(self.enableSSL);

    NSString * apiName;
    if (self.authType == ESAuthenticationTypeBinderModifyEmail) {
        apiName = security_email_modify_binder;
    } else if (self.authType == ESAuthenticationTypeAutherModifyEmail) {
        apiName = security_email_modify_auther;
    }
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:apiName queryParams:nil header:nil body:param modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        [weak_self bindResult:ESSecurityEmailResult_AUTHENTICATION_SUCCESS title:@"" msg:@""];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        long errCode = [error errorCode];
        NSString * title = NSLocalizedString(@"bind failed", @"绑定失败");
        NSString * content = [error errorMessage];
        ESDLog(@"[安保功能] 设置密保邮箱失败：%@", error);
        [weak_self bindResult:errCode title:title msg:content];
    }];
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
