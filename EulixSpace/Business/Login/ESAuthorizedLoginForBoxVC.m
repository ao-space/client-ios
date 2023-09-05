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
//  ESAuthorizedLoginForBoxVC.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/23.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAuthorizedLoginForBoxVC.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "ESAuthenticationTypeController.h"

@interface ESAuthorizedLoginForBoxVC ()

@end

@implementation ESAuthorizedLoginForBoxVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lanIPBtn.hidden = YES;
}

- (void)initWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];

    NSURL *webLoginUrl = [NSURL URLWithString:self.url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webLoginUrl];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];

    [self.webView loadRequest:request];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.boxKey == nil) {
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@"ios" forKey:@"terminalType"];
    NSString *terminalMode = [ESCommonToolManager judgeIphoneType:@""];
    [dic setObject:terminalMode forKey:@"terminalMode"];
    NSString * key = [ESRSAPair checkPublicKey:self.boxKey];
    ESRSAPair *pair = [ESRSAPair pairWithPublicKey:[ESRSAPair keyFromPEM:key isPubkey:YES]
                                        privateKey:[ESRSAPair keyFromPEM:nil isPubkey:NO]];
    NSString * encryUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    if (encryUUID) {
        [dic setObject:encryUUID forKey:@"clientUUID"];
    }

    NSString *json = [self gs_jsonStringCompactFormatForDictionary:dic];
    NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@','%@')", @"ios",json];
   // NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@')", @"ios"];

    [self.webView evaluateJavaScript:jsStr
                   completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                       NSLog(@"%@----%@", result, error);
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"setLoginInfo"]) {
        NSDictionary *dic = [NSString dictionaryWithJsonString:message.body];
        ESBoxItem *info  = [ESBoxItem fromAuth:dic];
        info.info.boxPubKey = self.boxKey;
        [ESBoxManager onAuth:info];
        
        info.boxIPResp = [[ESBoxIPResp alloc] init];
        info.boxIPResp.results = [NSMutableArray array];
        
        ESBoxIPModel * ipModel = [[ESBoxIPModel alloc] init];
        [info.boxIPResp.results addObject:ipModel];
        
        NSDictionary * lanInfoDict = dic[@"boxLanInfo"];
        ipModel.ip = lanInfoDict[@"lanIp"];
        if (lanInfoDict[@"port"]) {
            NSString * value = lanInfoDict[@"port"];
            ipModel.port = value.longLongValue;
        }
        if (lanInfoDict[@"tlsPort"]) {
            NSString * value = lanInfoDict[@"tlsPort"];
            ipModel.tlsPort = value.longLongValue;
        }

        NSString * ipDomain = [ipModel getIPDomain];
//        info.info.userDomain = ipDomain;
//        [ESBoxManager.manager markBoxActive:info];
        [ESBoxManager.manager setBoxIPConnect:ipDomain];

        self.aoid = dic[@"aoid"];
        [self getFamilyList:info];
    }
}


@end
