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
//  ESAuthorizedLoginVC.h
//  EulixSpace
//
//  Created by qu on 2021/8/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import <WebKit/WebKit.h>
#import "ESCommonToolManager.h"
#import "ESRSAPair.h"
#import "ESRSACenter.h"
#import "ESBoxManager.h"
#import "NSString+ESTool.h"


NS_ASSUME_NONNULL_BEGIN

// 展示平台侧的二维码
@interface ESAuthorizedLoginVC : YCViewController<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, copy) void (^actionBlock)(id action);
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) NSString *boxKey;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString *aoid;

@property (nonatomic, strong) UIButton * lanIPBtn;
- (void)initWKWebView;

-(NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson;
- (void)getFamilyList:(ESBoxItem *)info;
@end

NS_ASSUME_NONNULL_END
