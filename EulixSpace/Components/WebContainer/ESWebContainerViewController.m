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
//  ESWebContainerViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/17.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESWebContainerViewController.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>

@interface ESWebContainerViewController () <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESWebContainerCallback> *actionHander;

@end

@implementation ESWebContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.webTitle;
    if (!self.notSetNavigationBarBackgroundColor) {
        self.navigationBarBackgroundColor = ESColor.clearColor;
    }
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(self.insets);
    }];
    [self loadUrl];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.actionHander.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:obj];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.actionHander.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:obj];
    }];
}

- (void)loadUrl {
    NSURL *webUrl = [NSURL URLWithString:self.webUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl];
    [self.webView loadRequest:request];
}

- (void)registerAction:(NSString *)action callback:(ESWebContainerCallback)callback {
    if (!action || !callback) {
        return;
    }
    self.actionHander[action] = callback;
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *jsStr = [NSString stringWithFormat:@"setEulixosEnv('%@')", @"ios"];
    [self.webView evaluateJavaScript:jsStr
                   completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                       NSLog(@"%@----%@", result, error);
                   }];
    if (!self.notSetIphoneOffSet) {
        jsStr = [NSString stringWithFormat:@"setIphoneOffSet(%@)", @(kTopHeight)];
        [self.webView evaluateJavaScript:jsStr
                       completionHandler:^(id _Nullable result, NSError *_Nullable error) {
            NSLog(@"%@----%@", result, error);
        }];
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    ESWebContainerCallback callback = self.actionHander[message.name];
    if (callback) {
        callback(message.body);
    }
}

#pragma mark - Lazy Load

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        NSString *userAgent = configuration.applicationNameForUserAgent;
        userAgent = [userAgent stringByAppendingString:@" Eulix/iOS"];
        configuration.applicationNameForUserAgent = userAgent;
        
        configuration.userContentController = [[WKUserContentController alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _webView;
}

- (NSMutableDictionary<NSString *, ESWebContainerCallback> *)actionHander {
    if (!_actionHander) {
        _actionHander = NSMutableDictionary.dictionary;
    }
    return _actionHander;
}

@end
