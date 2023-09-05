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
//  ESLoginAuthCodeForBoxController.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/23.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLoginAuthCodeForBoxController.h"
#import "ESServiceNameHeader.h"

@interface ESLoginAuthCodeForBoxController ()

@end

@implementation ESLoginAuthCodeForBoxController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)reqAuthBkey {
    [self refreshAuthCode];
}

- (void)reqBoxInfoByBkey {
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[@"bkey"] = self.v;

    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:@"auth_totp_bkey_verify" queryParams:query header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        int su = [response intValue];
        if (su > 0) {
            ESDLog(@"[登录授权] auth_totp_bkey_verify  result yes");
            [self reqAuthResultPoll];
        } else {
            ESDLog(@"[登录授权] auth_totp_bkey_verify  result NO");
            [ESToast toastError:NSLocalizedString(@"The request failed, please scan the qrcode again!", @"请求失败，请重新扫码！")];
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[登录授权] %s, error:%@", __func__, error);
        [ESToast toastError:NSLocalizedString(@"The request failed, please scan the qrcode again!", @"请求失败，请重新扫码！")];
    }];
}

- (void)reqAuthResultPoll {
    if (self.isReqingPoll) {
        return;
    }
    self.isReqingPoll = YES;
    ESDLog(@"[登录授权] %s", __func__);
    
    NSMutableDictionary * query = [NSMutableDictionary dictionary];
    query[@"bkey"] = self.v;
    query[@"autoLogin"] = self.isAutoLog15Days ? @(1) : @(0);

    weakfy(self);
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:@"auth_totp_bkey_poll" queryParams:query header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        strongfy(self);
        int su = [response intValue];
        if (su > 0) {
            [ESToast toastInfo:NSLocalizedString(@"Login Success", @"登录成功")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            self.tabBarController.selectedIndex = 0;
            self.tabBarController.tabBar.hidden = NO;
        } else {
            ESPerformBlockAfterDelay(5, ^{
                strongfy(self);
                self.isReqingPoll = NO;
                [self reqAuthResultPoll];
            });
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[登录授权] %s, error:%@", __func__, error);
        ESPerformBlockAfterDelay(5, ^{
            strongfy(self);
            self.isReqingPoll = NO;
            [self reqAuthResultPoll];
        });
    }];
}



@end
