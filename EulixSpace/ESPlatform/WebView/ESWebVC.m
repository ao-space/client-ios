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
//  ESWebVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/3/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESWebVC.h"
#import "ESWebViewJavascriptBridge.h"
#import "UIWindow+ESVisibleVC.h"
#import <Masonry/Masonry.h>
#import <Masonry/Masonry.h>
#import "ESGlobalMacro.h"
#import "ESAppletMoreOperateVC.h"
#import "ESToast.h"
#import "ESWebViewJSBCommand.h"
#import "ESWebNavigationBar.h"

@interface ESWebVC ()<WKNavigationDelegate>

@property ESWebViewJavascriptBridge* bridge;
@property (nonatomic, copy) NSString* url;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) ESWebNavigationBar *customNavigationBar;
@property (nonatomic, assign) BOOL isPrePageShowNavigationBar;
@property (nonatomic, strong) UIView *statusBar;

@end

@implementation ESWebVC

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
- (void)loadWithURL:(NSString *)url {
    if (url.length <= 0) {
        return;
    }
    _url = url;
//    self.tabBarController.tabBar.hidden = YES;
    if (self.viewLoaded && self.view.window) {
        [self loadPageURL:self.webView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPrePageShowNavigationBar = !self.navigationController.navigationBarHidden;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    [self updateStyle];
    
    if (_bridge) { return; }
    
    WKWebView *webView = [self setupWebview];
    self.webView = webView;
    [self registerMethods];
    
    [self setupNavigationBarView];
    [self loadPageURL:webView];
}

- (void)setStyle:(ESWebVCShowStyle)style {
    _style = style;
    [self updateStyle];
}

- (void)setStatusBarBackgroudColor:(UIColor *)statusBarBackgroudColor {
    _statusBarBackgroudColor = statusBarBackgroudColor;
    if (@available(iOS 13.0, *)) {
            if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:self.statusBar]) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.statusBar];
            }
            self.statusBar.backgroundColor = _statusBarBackgroudColor;
        } else {
            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.backgroundColor = _statusBarBackgroudColor;
            }
        }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateStyle {
    if (![self useCustomNavigationBar]) {
        self.customNavigationBar.hidden = YES;
    }
    
    if(self.style == ESWebVCShowStyle_Translucent) {
        self.customNavigationBar.isTranslucent = YES; //修改背景色透明
    }
    [self resetWebViewFrame];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = !self.isPrePageShowNavigationBar;
    
    if (self.statusBarBackgroudColor == nil) {
        return;
    }
    if (@available(iOS 13.0, *)) {
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.statusBar]) {
                [self.statusBar removeFromSuperview];
            }
        } else {
            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.backgroundColor = UIColor.clearColor;
            }
        }
}

//优先级更高
- (BOOL)useCustomNavigationBar {
    return self.style == ESWebVCShowStyle_CustomNavigationBar;
}

//need overwrite
- (void)registerMethods {
    NSArray *registerCommandClassList = [self registerCommandClassList];
    [registerCommandClassList enumerateObjectsUsingBlock:^(NSString *commandClassName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![commandClassName isKindOfClass:[NSString class]]) {
            return;
        }
        
        if (commandClassName.length <= 0) {
            return;
        }
        
        Class commandClass = NSClassFromString(commandClassName);
        if (!commandClass) {
            return;
        }
        
        if (![commandClass isSubclassOfClass:[ESWebViewJSBCommand class]]) {
            return;
        }
        
        ESWebViewJSBCommand *commandObject = (ESWebViewJSBCommand *)[commandClass new];
        commandObject.context.webVC = self;
        commandObject.context.url = self.url;
        commandObject.context.customNavigationBar = self.customNavigationBar;
        [self.bridge registerHandler:commandObject.commandName handler:commandObject.commandHander];
    }];
  
}

- (NSArray<NSString *> *)registerCommandClassList {
    return @[];
}

- (WKWebView *)setupWebview {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    NSString *userAgent = config.applicationNameForUserAgent;
    userAgent = [userAgent stringByAppendingString:@" Eulix/iOS"];
    config.applicationNameForUserAgent = userAgent;
    
    config.preferences.javaScriptEnabled = YES;
    config.suppressesIncrementalRendering = YES; // 是否支持记忆读取
   [config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds configuration:config];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [ESWebViewJavascriptBridge enableLogging];
    _bridge = [ESWebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    return webView;
}

- (void)layoutWebViewIfNeed {
    CGFloat offsetY =   self.navigationController.isNavigationBarHidden ? kNavBarHeight : kTopHeight;
    self.webView.frame = CGRectMake(0, offsetY, self.view.bounds.size.width, self.view.bounds.size.height - offsetY);
}

- (void)callJSMethod {
#if DEBUG
//    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
//    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
//        ESDLog(@"testJavascriptHandler responded: %@", response);
//    }];
#endif
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    
    if ([self needApplicationHandlerWhiteList:url]) {
        [self tryApplicationHandlerUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)needApplicationHandlerWhiteList:(NSURL *)url {
    //没有配置白名单，不限制
    if ([url.absoluteString hasPrefix:@"http"]) {
        return NO;
    }
    if (self.canOpenSchemeWhiteList.count <= 0) {
        return YES;
    }
    NSString *scheme = [url scheme];
    return [[self canOpenSchemeWhiteList] containsObject:ESSafeString(scheme)];
}

- (NSArray *)canOpenSchemeWhiteList {
    return @[];
}

- (void)tryApplicationHandlerUrl:(NSURL *)url {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url];
        return;
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    ESDLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    ESDLog(@"webViewDidFinishLoad");
    [self callJSMethod];

    //禁止缩放 + 滚动
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    webView.scrollView.bounces = false;
    webView.scrollView.scrollEnabled = true;
}

- (void)callHandler:(id)sender {
//    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
//    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
//        ESDLog(@"testJavascriptHandler responded: %@", response);
//    }];
}

- (void)loadPageURL:(WKWebView*)webView {
    if ([self.url hasPrefix:@"http"]) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [webView loadRequest:request];
        return;
    }
    
    if(self.url.length <= 0){
        return;
    }
    NSURL *baseURL = [NSURL fileURLWithPath:self.url];
    [webView loadFileURL:baseURL allowingReadAccessToURL:baseURL.URLByDeletingLastPathComponent];

    return;
}

- (void)setupNavigationBarView {
    if (![self useCustomNavigationBar]) {
        if (self.customNavigationBar.superview) {
            [self.customNavigationBar removeFromSuperview];
        }
        [self resetWebViewFrame];
        return;
    }
    
    [self.view addSubview:self.customNavigationBar];
    [self.customNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kTopHeight);
    }];
    
    [self.customNavigationBar setTitle:self.title];
    
    __weak typeof(self) weakSelf = self;
    self.customNavigationBar.actionBlock = ^(id  _Nonnull sender, ESWebNavigationBarActionType actionType){
        __strong typeof(weakSelf) self = weakSelf;
        switch (actionType) {
            case ESWebNavigationBarActionTypeBack: {
                if ([self.webView canGoBack]) {
                    [self.webView goBack];
                    return;
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
                case ESWebNavigationBarActionTypeClose:
            {
                [self closeWeb];
            }
                break;
        }
    };
    
    self.customNavigationBar.styleUpdateBlock = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self setNeedsStatusBarAppearanceUpdate];
        [self resetWebViewFrame];
    };
    
    [self resetWebViewFrame];
}

- (void)closeWeb {
    __block UIViewController *notAppletVC = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[ESWebVC class]]) {
                notAppletVC = obj;
                *stop = YES;
        }
    }];
    if (notAppletVC) {
        [self.navigationController popToViewController:notAppletVC animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (ESWebNavigationBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[ESWebNavigationBar alloc] initWithFrame:CGRectZero];
    }
    return _customNavigationBar;
}

- (UIView *)statusBar{
    if (!_statusBar) {
        if (@available(iOS 13.0, *)) {
            _statusBar = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        }
    }
    return _statusBar;
}

- (void)resetWebViewFrame {
    CGFloat offsetY = 0;
    if (self.style == ESWebVCShowStyle_CustomNavigationBar) {
        offsetY = kTopHeight;
    }
    if (self.style == ESWebVCShowStyle_FullScreen) {
        offsetY = kStatusBarHeight;
    }

    self.webView.frame = CGRectMake(0, offsetY, self.view.bounds.size.width, self.view.bounds.size.height - offsetY);
}

- (void)dealloc {
    ESDLog(@"[ESWebVC][dealloc]");
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
