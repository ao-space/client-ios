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
//  ESAgreementWebVC.m
//  EulixSpace
//
//  Created by qu on 2021/11/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAgreementWebVC.h"
#import "ESPlatformClient.h"
#import <Masonry/Masonry.h>
#import "ESAppletMoreOperateVC.h"
#import "ESAppletInfoModel.h"
#import "ESWebBottomView.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"

#import "ESNetworkRequestManager.h"
#import "UIViewController+ESPresent.h"
#import <WebKit/WebKit.h>
#import "ESAppDelView.h"
#import "ESCache.h"
//#import "ESMainMoreVC.h"

#import "ESAppStoreVC.h"
#import "ESAppInstallPageVC.h"
#import "ESAppWelcome.h"
#import "ESAppV2SettingVC.h"

@interface ESAgreementWebVC () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate,ESWebBottomViewDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) ESWebBottomView *webBottomView;

@property (nonatomic, strong) ESAppDelView *delView;


@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) ESAppletMoreOperateVC* moreOperateVC;

@end

@implementation ESAgreementWebVC

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.agreementType == ESUserAgreement) {
     
        self.title = NSLocalizedString(@"User Agreement", @"用户协议");
    }
    else if (self.agreementType == ESAppOpen) {
        self.title = self.name;
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.navigationItem.rightBarButtonItem = confirmItem;
    }
    else {
        self.title =  NSLocalizedString(@"Privacy Policy", @"隐私协议");
        
    }

    [self initWKWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"setLoginInfo"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"setLoginInfo"];
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

    NSString *baseUrl = ESPlatformClient.platformClient.baseURL.absoluteString;
    NSURL *webLoginUrl;

    if (self.agreementType == ESUserAgreement) {
        if ([ESCommonToolManager isEnglish]) {
            webLoginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/en/opensource/agreement", @"https://ao.space"]];
        }else{
            webLoginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/opensource/agreement", @"https://ao.space"]];
        }
   
    }
    else if (self.agreementType == ESAppOpen) {
        if ([self.urlStr containsString:@"https:"]) {
            webLoginUrl = [NSURL URLWithString:self.urlStr];
        } else {
            NSString *str = [NSString stringWithFormat:@"https://%@",self.urlStr];
            webLoginUrl = [NSURL URLWithString:str];
        }
    }
    else {
        if ([ESCommonToolManager isEnglish]) {
            webLoginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/en/opensource/privacy", @"https://ao.space"]];
        }else{
            webLoginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/opensource/privacy", @"https://ao.space"]];
        }
     
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webLoginUrl];
    [_webView loadRequest:request];

    [self clearWKWebViewCache];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

- (void)clearWKWebViewCache {
    NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:date completionHandler:^{}];
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
                   }];
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(0, 0, 50, 50);
        //[_cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"applet_more"] forState:UIControlStateNormal];
        _selectBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_selectBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (void)backAction{
    self.webBottomView.fileIcon =self.appletInfo.iconUrl;
    self.webBottomView.fileInfo = self.appletInfo;
    
    self.webBottomView.hidden = NO;

}


- (ESWebBottomView *)webBottomView {
    if (!_webBottomView) {
        _webBottomView = [[ESWebBottomView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _webBottomView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _webBottomView.delegate = self;
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_webBottomView addGestureRecognizer:delectActionTapGesture];
        _webBottomView.userInteractionEnabled = YES;
        [self.view.window addSubview:_webBottomView];
    }
    return _webBottomView;
}

- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.webBottomView.hidden = YES;
}

- (void)fileBottomDetailView:(ESWebBottomView *_Nullable)fileBottomDetailView didClickSettingBtn:(UIButton *_Nullable)button{
    self.webBottomView.hidden = YES;
    ESAppV2SettingVC *vc = [ESAppV2SettingVC new];
    vc.name = self.item.title;
    vc.item = self.item;
    if(self.item){
        vc.item = self.item;
    }else{
        ESFormItem *item = [ESFormItem new];
        item.title = self.appletInfo.name;
        item.version = self.appletInfo.appletVersion;
        item.iconUrl = self.appletInfo.iconUrl;
        item.appId = self.appletInfo.appletId;
        item.deployMode = self.appletInfo.deployMode;
        item.installSource = self.appletInfo.installSource;
        
        vc.item = item;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fileBottomDetailView:(ESWebBottomView *_Nullable)fileBottomDetailView didClickDelectBtn:(UIButton *_Nullable)button{
    self.webBottomView.hidden = YES;
    self.delView = NO;
    ESFormItem *item = [ESFormItem new];
    item.title = self.appletInfo.name;
    item.appId = self.appletInfo.appletId;
    item.packageId = self.appletInfo.packageId;
    item.version = self.appletInfo.appletVersion;
    item.deployMode = self.appletInfo.deployMode;
    item.installedAppletVersion = self.appletInfo.appletVersion;

    item.iconUrl = self.appletInfo.iconUrl;
    
    self.delView.item = item;
    
    self.delView.actionDel= ^(NSString *str)  {
        ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                        apiName:@"appstore_uninstall"
                                                    queryParams:@{ @"appid" : self.appletInfo.appletId
                                                                }
                                                         header:@{}
                                                           body:@{}
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
                [ESToast dismiss];
                [ESToast toastSuccess:NSLocalizedString(@"applet_uninstall_success", @"卸载成功")];
       
                NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
                NSMutableDictionary *dicMutable = [NSMutableDictionary dictionaryWithDictionary:dicApp];
                NSString *key = [ESCommonToolManager miniAppKey:self.appletInfo.appletId];
                [dicMutable setObject:@"NO" forKey:key];
                [[ESCache defaultCache] setObject:dicMutable forKey:@"v2_app_sel_status"];
            BOOL isPop = NO;
            if (self.agreementType == ESAppOpen) {
                NSArray *viewControllers = self.navigationController.viewControllers;
                for (unsigned long i = viewControllers.count - 1; i >= 0;i --) {
                    UIViewController *vc = viewControllers[i];
                    if ([vc isKindOfClass :[ESAppInstallPageVC class]]) {
                        isPop = YES;
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                    if ([vc isKindOfClass :[ESAppStoreVC class]]) {
                        isPop = YES;
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                    
//                    if ([vc isKindOfClass :[ESMainMoreVC class]]) {
//                        isPop = YES;
//                        [self.navigationController popToViewController:vc animated:YES];
//                        break;
//                    }
                    
                }
                if(!isPop){
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                 [ESToast dismiss];
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }];
    };
    
 
}

- (void)fileBottomDetailView:(ESWebBottomView *_Nullable)fileBottomDetailView didClickBackBtn:(UIButton *_Nullable)button{
    self.webBottomView.hidden = YES;
    if (self.agreementType == ESAppOpen) {
            BOOL isAppWelcome = NO;
                NSArray *viewControllers = self.navigationController.viewControllers;
                for (UIViewController *vc in viewControllers) {
                    if ([vc isKindOfClass :[ESAppWelcome class]]) {
                        isAppWelcome = YES;
                    }
                }
        if(isAppWelcome){
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
                   
//                    if ([vc isKindOfClass :[ESMainMoreVC class]]) {
//                        [self.navigationController popToViewController:vc animated:YES];
//                        break;
//                    }
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (ESAppDelView *)delView {
    if (!_delView) {
        _delView = [[ESAppDelView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _delView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        [self.view.window addSubview:_delView];
    }
    return _delView;
}

@end
