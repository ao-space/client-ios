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
//  ESWebTryPageVC.m
//  EulixSpace
//
//  Created by qu on 2021/11/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESWebTryPageVC.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>

@interface ESWebTryPageVC () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ESWebTryPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"试用反馈";
    [self initWKWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    NSString *userAgent = configuration.applicationNameForUserAgent;
    userAgent = [userAgent stringByAppendingString:@" Eulix/iOS"];
    configuration.applicationNameForUserAgent = userAgent;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [self.view addSubview:self.webView];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.top.mas_equalTo(self.view.mas_top).offset(0.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0.0);
        make.right.mas_equalTo(self.view.mas_right).offset(0.0);
    }];

    NSURL *webLoginUrl = [NSURL URLWithString:self.contentUrl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webLoginUrl];
    [_webView loadRequest:request];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

- (void)rightClick {
    [self.webView goBack];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@')", @"ios"];
    [self.webView evaluateJavaScript:jsStr
                   completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                       NSLog(@"%@----%@", result, error);
                       if (self.actionBlock) {
                           self.actionBlock();
                       }
                   }];
}

@end
