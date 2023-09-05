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
//  ESSecurityEmailMamager.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESSecurityEmailModel.h"
#import "UIViewController+ESTool.h"
#import "ESBoxStatusItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESSecurityEmailResult) {
    ESSecurityEmailResult_AUTHENTICATION_SUCCESS = 200, // 成功
    ESSecurityEmailResult_AUTHENTICATION_FAIL = 4011, // 认证失败
    ESSecurityEmailResult_BOUNDED_MAILBOX = 4051, // 您已绑定此邮箱，请输入新的邮箱账号
    ESSecurityEmailResult_VERIFICATION_EXPIRE = 4052, // 邮件服务器连接超时
    ESSecurityEmailResult_SECURITY_TOKEN_EXPIRE = 4053, // 验证过期
};

typedef NS_ENUM(NSUInteger, ESAuthenticationType) {
    ESAuthenticationTypeBinderModifyPassword = 1, // 绑定端 修改 安全密码
    ESAuthenticationTypeBinderResetPassword, // 绑定端 重置 安全密码
    
    ESAuthenticationTypeAutherModifyPassword, // 授权端 修改 安全密码
    ESAuthenticationTypeAutherResetPassword, // 授权端 重置 安全密码

    ESAuthenticationTypeBinderSetEmail,// 绑定端 设置 密保邮箱
    ESAuthenticationTypeBinderModifyEmail,// 绑定端 修改 密保邮箱

    ESAuthenticationTypeAutherSetEmail,// 授权端 设置 密保邮箱
    ESAuthenticationTypeAutherModifyEmail,// 授权端 修改 密保邮箱
    
    ESAuthenticationTypeNewDeviceResetPassword, // 新设备 重置 安全密码
};

@interface ESSecurityEmailMamager : NSObject

+ (void)reqEmailConfigurations:(void(^)(ESSecurityEmailConfigModel * data))block;

+ (BOOL)checkInput:(UIViewController *)ctl account:(NSString *)account ps:(NSString *)password host:(NSString *)host  port:(NSString *)port handle:(void (^)(void))handler;

+ (void)reqSecurityEmailInfo:(void(^)(ESSecurityEmailSetModel * model))setBlock notSet:(void (^)(void))notSetBlock;


@end

NS_ASSUME_NONNULL_END
