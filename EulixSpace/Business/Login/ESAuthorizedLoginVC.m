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
//  ESAuthorizedLoginVC.m
//  EulixSpace
//
//  Created by qu on 2021/8/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAuthorizedLoginVC.h"
#import "ESAccountManager.h"
#import "ESPlatformClient.h"
#import "ESAccountServiceApi.h"
#import "ESCommentCachePlistData.h"
#import "ESHomeCoordinator.h"
#import "ESCommonToolManager.h"
#import "UIColor+ESHEXTransform.h"
#import "ESSearchBoxForIPConnectController.h"
#import "ESNetworkRequestManager.h"
#import <YYModel/YYModel.h>

@interface ESAuthorizedLoginVC () 



@property (nonatomic, strong) UIButton * lanIPConnectBtn;

@end

static NSString * const ESBoxPublicKey = @"boxPublicKey";

@implementation ESAuthorizedLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Login", @"登录");
    [self initWKWebView];
    [self initLanIPConnectBtn];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.navigationController setNavigationBarHidden:NO animated:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"setLoginInfo"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"setLoginInfo"];
}

- (void)initLanIPConnectBtn {
    UIButton * btn = [[UIButton alloc] init];
    self.lanIPBtn = btn;
    [btn setTitle:NSLocalizedString(@"LAN_access", @"局域网 IP 直连") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"] forState:UIControlStateNormal];
    btn.titleLabel.font = ESFontPingFangMedium(16);
    [btn addTarget:self action:@selector(onLanIPConnectBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight - 40);
    }];
    [self.view bringSubviewToFront:btn];
}

- (void)onLanIPConnectBtn {
    ESSearchBoxForIPConnectController * ctl = [[ESSearchBoxForIPConnectController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)initWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    NSString *userAgent = configuration.applicationNameForUserAgent;
    userAgent = [userAgent stringByAppendingString:@" Eulix/iOS"];
    configuration.applicationNameForUserAgent = userAgent;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];

    NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
    NSString *path;
    if ([ESCommonToolManager isEnglish]) {
        path = [NSString stringWithFormat:@"%@/en/login?isOpensource=1", baseUrl];
    }else{
        path = [NSString stringWithFormat:@"%@/login?isOpensource=1", baseUrl];
    }
    NSURL *webLoginUrl = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webLoginUrl];
    [_webView loadRequest:request];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];

    [self.webView loadRequest:request];
   
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)rightClick {
    [self.webView goBack];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"setLoginInfo"]) {
        ESDLog(@"[授权二维码] Web call APP by setLoginInfo");

        NSDictionary *dic = [NSString dictionaryWithJsonString:message.body];
        ESBoxItem *info  = [ESBoxItem fromAuth:dic];
        info.info.boxPubKey = self.boxKey;
        //query没取到值的情况下，取setLoginInfo jsb返回值兜底
        if (info.info.boxPubKey.length <= 0 && [dic[ESBoxPublicKey] isKindOfClass:[NSString class]]) {
            info.info.boxPubKey = dic[ESBoxPublicKey];
        }
        
        [ESBoxManager onAuth:info];
        self.aoid = dic[@"aoid"];
        [self getFamilyList:[ESBoxItem fromAuth:dic]];
    }
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@"ios" forKey:@"terminalType"];
    NSString *terminalMode = [ESCommonToolManager judgeIphoneType:@""];
    [dic setObject:terminalMode forKey:@"terminalMode"];
    [dic setObject:ESBoxManager.clientUUID forKey:@"clientUUID"];
    NSString *json = [self gs_jsonStringCompactFormatForDictionary:dic];
    NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@','%@')", @"ios",json];
   // NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@')", @"ios"];

    [self.webView evaluateJavaScript:jsStr
                   completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                       NSLog(@"%@----%@", result, error);
    }];
}

- (void)getFamilyList:(ESBoxItem *)info {
    if (![info.boxUUID isEqualToString:ESBoxManager.activeBox.info.boxUuid]) {
        ESDLog(@"[授权二维码] getFamilyList:boxUUID not equal");
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service" apiName:@"member_list" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSArray<ESAccountInfoResult *> * results = [NSArray yy_modelArrayWithClass:ESAccountInfoResult.class json:response];
        __block ESAccountInfoResult *matchAccountInfo;
        [results enumerateObjectsUsingBlock:^(ESAccountInfoResult *_Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
            if([self.aoid isEqualToString:ESSafeString(account.aoId)]) {
                matchAccountInfo = account;
                *stop = YES;
            }
        }];
        
        if (matchAccountInfo == nil) {
            [ESHomeCoordinator showHome];
            if (self.actionBlock) {
                self.actionBlock(@(1));
            }
            return;
        }
        ESBoxItem *matchBoxItem = [ESBoxManager.manager getBoxItemWithBoxUuid:info.boxUUID boxType:info.boxType aoid:self.aoid];
        if (matchBoxItem == nil) {
            [ESHomeCoordinator showHome];
            if (self.actionBlock) {
                self.actionBlock(@(1));
            }
            return;
        }
  
        [[ESAccountManager manager] loadAvatar:self.aoid
                                    completion:^(NSString *path) {
                                        matchBoxItem.bindUserHeadImagePath = path.length > 0 ? path :  matchBoxItem.bindUserHeadImagePath;
                                        matchBoxItem.info.userDomain = matchAccountInfo.userDomain;
                                        matchBoxItem.bindUserName = matchAccountInfo.personalName;
                                        matchBoxItem.info.boxPubKey = self.boxKey;
                                        [ESBoxManager.manager saveBoxList];
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loopUrlChangeNSNotification" object: matchAccountInfo.userDomain];
                                        [ESHomeCoordinator showHome];
                                        if (self.actionBlock) {
                                            self.actionBlock(@(1));
                                        }
                                    }];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESHomeCoordinator showHome];
        if (self.actionBlock) {
            self.actionBlock(@(1));
        }
    }];
}

-(NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {
    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return strJson;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{

}



// KVO 接收到通知时的方法
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"URL"]) {
        // 可以在这里进行拦截并做相应的处理
        NSString *decodeURIComponentStr = [_webView.URL.absoluteString stringByRemovingPercentEncoding];
        ESDLog(@"[授权二维码] URL:%@", decodeURIComponentStr);
        NSArray *valueArray = [decodeURIComponentStr componentsSeparatedByString:@"&"];
        if(valueArray.count > 1){
            NSArray *boxPubKey = [valueArray[1] componentsSeparatedByString:@"="];
            if(boxPubKey.count > 1){
                NSString *boxKeyStr = boxPubKey[1];
                NSArray *boxPubKeyArray = [boxKeyStr componentsSeparatedByString:@"#"];
                if(boxPubKeyArray){
                    self.boxKey = boxPubKeyArray[0];
                    self.lanIPBtn.hidden = YES;
                    ESDLog(@"[授权二维码] box pubKey:%@", self.boxKey);
                }
            }
        }
        
        if (decodeURIComponentStr) {
            self.host = self.webView.URL.host;
            NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithString:decodeURIComponentStr];
            [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ESDLog(@"[授权二维码] key:%@, value:%@", obj.name, obj.value);
                if ([obj.name isEqualToString:@"publickey"]) {
                    self.boxKey = obj.value;
                    self.lanIPBtn.hidden = YES;
                } else if ([obj.name isEqualToString:@"version"]) {
                    self.version = obj.value;
                }
            }];
        }
    }
}

@end
