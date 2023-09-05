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
//  ESAppletViewController.m
//  ExampleApp-iOS
//
//  Created by KongBo on 2022/6/2.
//  Copyright © 2022 Marcus Westin. All rights reserved.
//

#import "ESAppletViewController.h"
#import "ESWebViewJavascriptBridge.h"
#import "UIWindow+ESVisibleVC.h"
#import <Masonry/Masonry.h>
#import "ESGlobalMacro.h"
#import "ESAppletMoreOperateVC.h"
#import "ESToast.h"
#import "ESAppletManager.h"
#import "ESNavigationBar.h"
#import "ESAppletManager+ESCache.h"
#import "UIViewController+ESPresent.h"
#import "ESAppletViewController+ESOperate.h"
#import "ESNavigationBar+ESStyle.h"
#import "ESAppletViewController+ESRegisterCommand.h"
#import "ESAccountInfoStorage.h"
#import "ESAppletManager.h"
#import "ESAccountInfoStorage.h"
#import "ESAppletScopesManager.h"
#import "ESAppWelcome.h"
#import "ESAppStoreVC.h"
#import "ESAppInstallPageVC.h"
#import "ESAppV2SettingVC.h"
#import "ESFormItem.h"


NSNotificationName const ESAppletInfoChanged = @"ESAppletInfoChanged";

@interface ESAppletViewController ()<WKNavigationDelegate>

@property ESWebViewJavascriptBridge* bridge;
@property (nonatomic, copy) NSString* url;

@property (nonatomic, strong) ESAppletInfoModel* appletInfo;
@property (nonatomic, weak) ESAppletMoreOperateVC *moreOperateVC;
@property (nonatomic, strong) ESNavigationBar *customNavigationBar;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ESAppletViewController

- (void)loadWithAppletInfo:(ESAppletInfoModel *)appletInfo {
    _appletInfo = appletInfo;
    [self loadWithURL:appletInfo.localCacheUrl];
}

- (void)loadWithURL:(NSString *)url {
    if (url.length <= 0) {
        return;
    }
    _url = url;
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self showAppletContentVC];
}

- (void)showAppletContentVC {
    UIViewController *topVisibelVC = [UIWindow visibleViewController];
    if (topVisibelVC.navigationController != nil) {
        [topVisibelVC.navigationController pushViewController:self animated:YES];
        return;
    }
    [topVisibelVC presentViewController:self animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self fetchUpdateInfo];
    
    if (_bridge) { return; }
    
    WKWebView *webView = [self setupWebview];
    self.webView = webView;
    [self registerMethods];
    
    [self setupNavigationBarView];
    [self loadPageURL:webView];
}

- (void)fetchUpdateInfo {
    if ([ESAccountInfoStorage isMemberAccount]) {
        return;
    }
    
//    __weak typeof(self) weakSelf = self;
//    [ESAppletManager.shared getAppletInfoListWithCompletionBlock:^(NSArray<ESAppletInfoModel *> * _Nonnull infoList, NSError * _Nullable error) {
//        __strong typeof(weakSelf) self = weakSelf;
//        if (infoList.count <= 0) {
//            //以本地数据判断
//            [self tryShowUpdateDialog];
//            return;
//        }
//
//        //以最新数据判断
//        [infoList enumerateObjectsUsingBlock:^(ESAppletInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.appletId isEqual:self.appletInfo.appletId]) {
//                self.appletInfo.appletVersion = obj.appletVersion;
//                self.appletInfo.isForceUpdate = obj.isForceUpdate;
//                self.appletInfo.installedAppletVersion = obj.installedAppletVersion;
//                [self newVersionUpdate];
//                *stop = YES;
//            }
//        }];
    if(self.appletInfo.hasNewVersion){
        [self newVersionUpdate];
    }
        [self tryShowUpdateDialog];
        return;
 
}

- (void)newVersionUpdate {
    [self updateNavigationBarRedhot];
    [self.moreOperateVC haveNewVersionUpdate];
}

- (WKWebView *)setupWebview {
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
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

- (void)setupNavigationBarView {
    [self.view addSubview:self.customNavigationBar];
    [self.customNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kTopHeight);
    }];
    
    [self.customNavigationBar setTitle:self.appletInfo.name];
    
    __weak typeof(self) weakSelf = self;
    self.customNavigationBar.actionBlock = ^(id  _Nonnull sender, ESNavigationBarActionType actionType){
        __strong typeof(weakSelf) self = weakSelf;
        switch (actionType) {
            case ESNavigationBarActionTypeBack: {
                if ([self.webView canGoBack]) {
                    [self.webView goBack];
                    return;
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case ESNavigationBarActionTypeMore: {
                ESAppletMoreOperateVC *moreOperateVC = [[ESAppletMoreOperateVC alloc] initWithAppletInfo:self.appletInfo
                                                                                         operateDelegate:self];
                moreOperateVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self es_presentViewController:moreOperateVC animated:YES completion:^{
                        
                }];
                self.moreOperateVC = moreOperateVC;
            }
                break;
            case ESNavigationBarActionTypeClose:
            {
                [self closeApplet];
            }
                break;
        }
    };
    
    [self updateNavigationBarRedhot];

    self.customNavigationBar.styleUpdateBlock = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self setNeedsStatusBarAppearanceUpdate];
        [self resetWebViewFrame];
    };
    
    [self resetWebViewFrame];
}

- (void)resetWebViewFrame {
    CGFloat offsetY = 0;
    if (!self.customNavigationBar.isTranslucent) {
        offsetY = kTopHeight;
    }
    self.webView.frame = CGRectMake(0, offsetY, self.view.bounds.size.width, self.view.bounds.size.height - offsetY);
}

- (void)updateNavigationBarRedhot {
    [self.customNavigationBar setHaveNewAction:[self haveNewAction]];
}

- (void)hiddenNewActionRedDot {
    self.appletInfo.context.shownedNewAction = YES;
    [self.customNavigationBar setHaveNewAction:NO];
}

// 红点只跟是否有更新关联，不跟操作关联
- (BOOL)haveNewAction {
    return [self.appletInfo hasNewVersion];
}


- (void)settingApplet {
    ESAppV2SettingVC *vc = [ESAppV2SettingVC new];
    ESFormItem *item = [ESFormItem new];
    item.appId = self.appletInfo.appletId;
    item.title = self.appletInfo.name;
    item.name = self.appletInfo.name;
    item.iconUrl = self.appletInfo.iconUrl;
    item.version = self.appletInfo.appletVersion;
    vc.item = item;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)closeApplet {
    __block UIViewController *notAppletVC = nil;

    
//    BOOL isAppWelcome = NO;
//        NSArray *viewControllers = self.navigationController.viewControllers;
//        for (UIViewController *vc in viewControllers) {
//            if ([vc isKindOfClass :[ESAppWelcome class]]) {
//                isAppWelcome = YES;
//            }
//        }
//    if(isAppWelcome){
        NSArray *viewControllers = self.navigationController.viewControllers;
        for (unsigned long i = viewControllers.count - 1; i >= 0;i --) {
            UIViewController *vc = viewControllers[i];
             
            if ([vc isKindOfClass :[ESAppInstallPageVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
            if ([vc isKindOfClass :[ESAppStoreVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
            
       
              
         }
//    }
    
//    if(![self.appletInfo.source isEqual:@"Welcome"]){
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        if (notAppletVC) {
//            [self.navigationController popToViewController:notAppletVC animated:YES];
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
}

- (ESNavigationBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[ESNavigationBar alloc] initWithFrame:CGRectZero];
    }
    return _customNavigationBar;
}

- (void)callJSMethod {
#if DEBUG
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
#endif
    
}

- (void)closeAppletAndPostNotificationInfoChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:ESAppletInfoChanged object:self.appletInfo];
    [self closeApplet];
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
    NSString *scheme = [url scheme];
    return [[self canOpenSchemeWhiteList] containsObject:ESSafeString(scheme)];
}

- (NSArray *)canOpenSchemeWhiteList {
    return @[@"tel", @"sms", @"mailto"];
}

- (void)tryApplicationHandlerUrl:(NSURL *)url {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url];
        return;
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self callJSMethod];
//    NSLog(@"webViewDidFinishLoad");
    //禁止缩放 + 滚动
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    webView.scrollView.bounces = false;
    webView.scrollView.scrollEnabled = false;
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadPageURL:(WKWebView*)webView {
    if ([self.url hasPrefix:@"http"]) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [webView loadRequest:request];
        return;
    }
    
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [webView loadHTMLString:appHtml baseURL:baseURL];
    
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
//
//    [webView loadFileURL:baseURL allowingReadAccessToURL:documentsURL];
    if(self.url.length < 1){
        return;
    }
    NSURL *baseURL = [NSURL fileURLWithPath:self.url];
    [webView loadFileURL:baseURL allowingReadAccessToURL:baseURL.URLByDeletingLastPathComponent];

    return;
}

- (void)dealloc {
    [ESAppletScopesManager.shared clearAuthStatusWithAppletId:self.appletInfo.appletId];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.customNavigationBar preferredStatusBarStyle];
}

@end

