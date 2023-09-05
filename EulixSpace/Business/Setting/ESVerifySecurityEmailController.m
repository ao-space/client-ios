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
//  ESVerifySecurityEmailController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVerifySecurityEmailController.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESReTransmissionManager.h"
#import "UIViewController+ESTool.h"

@interface ESVerifySecurityEmailController ()

@end

@implementation ESVerifySecurityEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"verify old security email", @"原密保邮箱验证");
    
    [self initHintView];
}

- (void)onVerifyBtn {
    if (self.accountStr.length <= 0 || self.emailPasswordStr.length <= 0) {
        [self showAlert:NSLocalizedString(@"account_password_empty_hint", @"账号、密码为必填项，请检查后重新输入")];
        return;
    }
    
    [self sendReq];
}

- (void)sendReq {
    weakfy(self);
    [self.verfiryBtn startLoading:NSLocalizedString(@"verifying", @"正在验证...")];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    param[@"emailAccount"] = self.accountStr;
    param[@"emailPasswd"] = [self.emailPasswordStr toHexString];
    param[@"host"] = self.hostStr;
    param[@"port"] = self.portStr;
    param[@"sslEnable"] = @(self.enableSSL);
    param[@"clientUuid"] = ESBoxManager.clientUUID;

    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:security_email_verify queryParams:nil header:nil body:param modelName:nil successBlock:^(NSInteger requestId, NSDictionary * response) {
        [self.verfiryBtn stopLoading:NSLocalizedString(@"verify", @"验证")];

        NSString * expiredAt = response[@"expiredAt"];
        NSString * securityToken = response[@"securityToken"];
        if (weak_self.verifySecurityEmailBlock) {
            weak_self.verifySecurityEmailBlock(0, expiredAt, securityToken);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[安保功能] 验证密保邮箱失败:%@", error);
        [self.verfiryBtn stopLoading:NSLocalizedString(@"verify", @"验证")];
        
        long errCode = [error errorCode];
        NSString * title = NSLocalizedString(@"auth verify failed", @"身份验证失败");
        NSString * content = [error errorMessage];
 
        [self bindResult:errCode title:title msg:content];
    }];
}

- (void)initHintView {
    weakfy(self);
    NSMutableArray * tapList = [NSMutableArray array];
    ESTapModel * model = [[ESTapModel alloc] init];
    model.text = NSLocalizedString(@"view help", @"查看帮助");
    model.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
    model.underlineColor = [UIColor es_colorWithHexString:@"#337AFF"];
    model.textFont = ESFontPingFangRegular(12);
    model.onTapTextBlock = ^{
        [weak_self onHelpView];
    };
    [tapList addObject:model];
    
    NSString * email = self.oldEmailAccount;
    NSString * first = [email componentsSeparatedByString:@"@"].firstObject;
    if (first.length > 3) {
        NSString * star = [first substringFromIndex:3];
        NSRange range = [email rangeOfString:star];
        NSMutableString * with = [[NSMutableString alloc] init];
        for (int i = 0; i < star.length; i++) {
            [with appendString:@"*"];
        }
        
        email = [email stringByReplacingOccurrencesOfString:star withString:with options:NSRegularExpressionSearch range:range];
    }
    
    NSString * content =  NSLocalizedString(@"already bound security email hint", @"您已绑定密保邮箱 %@，请输入邮箱账号、密码进行登录验证。 查看帮助");
    content = [NSString stringWithFormat:content, email];
    [self.tapView setTextAlignment:NSTextAlignmentLeft];
    [self.tapView setShowData:content tap:tapList];
}



@end
