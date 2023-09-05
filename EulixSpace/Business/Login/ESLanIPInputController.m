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
//  ESLanIPInputController.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/29.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLanIPInputController.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "NSArray+ESTool.h"
#import "UILabel+ESTool.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"
#import "ESGradientButton.h"
#import "NSString+ESTool.h"
#import "ESNetworkRequestManager.h"
#import "ESStatusResult.h"
#import "ESAuthorizedLoginForBoxVC.h"

@interface ESLanIPInputController ()
@property (nonatomic, strong) UITextField * ipTextField;
@property (nonatomic, strong) ESGradientButton * nextBtn;
@end

@implementation ESLanIPInputController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"login_title", @"登录");
    [self setupViews];
}

- (void)onNextBtn {
    [self.nextBtn startLoading:NSLocalizedString(@"common_next", @"下一步")];
    [self checkIPConnect];
}

- (NSString *)getProtocolType {
    NSString * protocol = @"https";
    NSString * ipString = [self.ipTextField.text componentsSeparatedByString:@":"].firstObject;
    if ([ipString es_validateIPV4Format]) {
        protocol = @"http";
    }
    return protocol;
}

- (void)checkIPConnect {
    NSString * baseUrl = [[NSString alloc] initWithFormat:@"%@://%@", [self getProtocolType], self.ipTextField.text];
    [ESNetworkRequestManager sendRequest:baseUrl path:@"/space/status" method:@"GET" queryParams:nil header:nil body:nil modelName:@"ESStatusResult" successBlock:^(NSInteger requestId, ESStatusResult * response) {
        if ([response.status isEqualToString:@"ok"]) {
            [self showSuccess];
        } else {
            [self showIPConnectFailed];
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self showIPConnectFailed];
    }];
}

- (void)showSuccess {
    [self.nextBtn stopLoading:NSLocalizedString(@"common_next", @"下一步")];
    weakfy(self);
    NSString * url  = [[NSString alloc] initWithFormat:@"%@://%@/space/index.html#/qrLogin?language=%@&isOpensource=1",
                       [self getProtocolType],
                       self.ipTextField.text,
                       [ESCommonToolManager isEnglish] ? @"en-US" : @"zh-CN"];
    ESAuthorizedLoginForBoxVC * ctl = [[ESAuthorizedLoginForBoxVC alloc] init];
    ctl.url = url;
    ctl.actionBlock = ^(id  _Nonnull action) {
        strongfy(self);
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(viewModelJump)]) {
                [self.navigationController popToViewController:obj animated:NO];
                self.tabBarController.selectedIndex = 0;
                *stop = YES;
            }
        }];
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showIPConnectFailed {
    // 访问失败，请检查手机与傲空间服务器是否在同一局域网内
    [ESToast toastError:NSLocalizedString(@"LAN_accessfailed", @"")];
    [self.nextBtn stopLoading:NSLocalizedString(@"common_next", @"下一步")];
}

- (void)textDidChange:(UITextField *)textField {
    NSString * ipString = textField.text;
    self.nextBtn.enabled = ipString.length > 0;
}

- (void)setupViews {
    //请输入傲空间服务器的 IP 地址或局域网
    NSString * text = NSLocalizedString(@"LAN_enterIPaddress", @"");
    UILabel * label = [UILabel createLabel:text font:ESFontPingFangMedium(14) color:@"#333333"];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(26);
        make.trailing.mas_equalTo(self.view).offset(-26);
        make.top.mas_equalTo(self.view).offset(20);
    }];
    
    UILabel * label1 = [UILabel createLabel:@"https://" font:ESFontPingFangRegular(16) color:@"#333333"];
    [self.view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(26);
        make.top.mas_equalTo(label.mas_bottom).offset(30);
    }];
    
    UITextField * tf = [[UITextField alloc] init];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.placeholder = [[NSString alloc] initWithFormat:@"%@:192.168.1.1", NSLocalizedString(@"LAN_example", @"") ];
    self.ipTextField = tf;
    [tf addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:tf];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view).offset(-26);
        make.leading.mas_equalTo(self.view).offset(94);
        make.centerY.mas_equalTo(label1);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(26);
        make.trailing.mas_equalTo(self.view).offset(-26);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(label1.mas_bottom).offset(20);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(lineView).offset(50);
        make.centerX.mas_equalTo(self.view);
    }];
}

- (ESGradientButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_nextBtn setCornerRadius:10];
        _nextBtn.enabled = NO;
        [_nextBtn setTitle:NSLocalizedString(@"common_next", @"下一步") forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = ESFontPingFangMedium(16);
        [_nextBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_nextBtn];
        [_nextBtn addTarget:self action:@selector(onNextBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

@end
