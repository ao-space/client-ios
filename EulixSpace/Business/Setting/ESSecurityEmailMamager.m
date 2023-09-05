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
//  ESSecurityEmailMamager.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityEmailMamager.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import <YYModel/YYModel.h>
#import "NSString+ESTool.h"
#import "NSError+ESTool.h"


@implementation ESSecurityEmailMamager

+ (void)reqEmailConfigurations:(void(^)(ESSecurityEmailConfigModel * data))block {
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:security_email_configurations queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESSecurityEmailConfigModel * model = [ESSecurityEmailConfigModel.class yy_modelWithJSON:response];
        ESDLog(@"[安保功能] 邮箱配置信息列表请求成功：%@", [response yy_modelToJSONString]);
        if (block) {
            block(model);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[安保功能] 邮箱配置信息列表请求失败：%@", error);
    }];
}


+ (BOOL)checkInput:(UIViewController *)ctl account:(NSString *)account ps:(NSString *)password host:(NSString *)host  port:(NSString *)port handle:(void (^)(void))handler {
    NSString * title = NSLocalizedString(@"bind failed", @"绑定失败");
    if (account.length == 0 || password.length == 0 || host.length == 0 || port.length == 0) {
        [ctl showAlert:title message:NSLocalizedString(@"Account, password, SMTP server and port are required", @"账号、密码、SMTP服务器、端口为必填项，请检查后重新输入") handle:^{
            if ((host.length == 0 || port.length == 0) && handler) {
                handler();
            }
        }];
        return NO;
    }
    
    if (![account es_validateEmail]) {
        [ctl showAlert:title message:NSLocalizedString(@"email_format_error_1", @"邮箱格式错误，请重新输入")];
        return NO;
    }
    
    return YES;
}

+ (void)reqSecurityEmailInfo:(void(^)(ESSecurityEmailSetModel * model))setBlock notSet:(void (^)(void))notSetBlock {
    [ESNetworkRequestManager sendCallRequest:@{ServiceName: eulixspaceAccountService,
                                               ApiName : security_email_setting
                                             }  queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESDLog(@"[安保功能] 请求邮箱配置信息成功：%@", response);
        if (setBlock) {
            ESSecurityEmailSetModel * model = [ESSecurityEmailSetModel.class yy_modelWithJSON:response];
            setBlock(model);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[安保功能] 请求邮箱配置信息失败：%@", error);
        NSString * code = [error codeString];
        if (notSetBlock && [code isKindOfClass:NSString.class] && [code isEqualToString:@"ACC-404"]) {
            // 未设置密保邮箱
            notSetBlock();
        }
    }];
}

@end
