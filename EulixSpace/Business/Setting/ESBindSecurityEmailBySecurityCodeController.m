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
//  ESBindSecurityEmailBySecurityCodeController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "ESWebContainerViewController.h"
#import "ESBoxManager.h"
#import "ESCellModel.h"
#import "ESMeSettingCell.h"
#import "NSArray+ESTool.h"
#import "ESEmailSSLModifyController.h"
#import "ESInputNormalController.h"
#import "ESInputSecretiveController.h"
#import "ESSecurityEmailMamager.h"
#import "ESSecurityEmailBindSuccessController.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"

@interface ESBindSecurityEmailBySecurityCodeController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) NSMutableArray * dataArr1;


@property (nonatomic, assign) bool showManualSetting;

@property (nonatomic, strong) ESCellModel * accountModel;
@property (nonatomic, strong) ESCellModel * passwordModel;
@property (nonatomic, strong) ESCellModel * smtpModel;
@property (nonatomic, strong) ESCellModel * portModel;
@property (nonatomic, strong) ESCellModel * sslModel;

@property (nonatomic, strong) ESSecurityEmailConfigModel * configModel;

@end

@implementation ESBindSecurityEmailBySecurityCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Bind security email", @"绑定密保邮箱");
    self.showManualSetting = false;
    [self initData];
    [self.tableView reloadData];
    
    weakfy(self);
    [ESSecurityEmailMamager reqEmailConfigurations:^(ESSecurityEmailConfigModel * _Nonnull data) {
        weak_self.configModel = data;
    }];
}

- (void)showInputAccount {
    weakfy(self);
    ESInputNormalController * ctl = [[ESInputNormalController alloc] init];
    ctl.navigationItem.title = self.accountModel.title;
    ctl.keyboardType = UIKeyboardTypeEmailAddress;
    if (self.accountModel.value.length > 0) {
        ctl.defaultString = self.accountModel.value;
    } else {
        ctl.placeholderString = self.accountModel.placeholderValue;
    }
    ctl.doneBlock = ^(NSString * _Nonnull content) {
        weak_self.accountStr = content;
        self.accountModel.value = content;
        
        NSString * last = [[content componentsSeparatedByString:@"@"] lastObject];
        ESSecurityEmailServersModel * model = [self.configModel getServers:last smtp:YES];
        if (model) {
            self.hostStr = model.host;
            self.portStr = model.port;
            self.enableSSL = model.sslEnable;
            
            self.smtpModel.value = model.host;
            self.portModel.value = model.port;
            self.sslModel.value = model.sslEnable ? @"SSL" : NSLocalizedString(@"None", @"无");
        }
        
        [weak_self.tableView reloadData];
    };
    ctl.checkInputBlock = ^NSString * _Nonnull(NSString * _Nonnull content) {        
        BOOL result = [content es_validateEmail];
        
        if (result) {
            return nil;
        }
        return NSLocalizedString(@"email_format_error", @"邮箱格式错误，请填写正确的邮箱");
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showInoutPassword {
    weakfy(self);
    ESInputSecretiveController * ctl = [[ESInputSecretiveController alloc] init];
    ctl.navigationItem.title = self.passwordModel.title;
    ctl.keyboardType = UIKeyboardTypeDefault;
    if (self.passwordModel.value.length > 0) {
        ctl.defaultString = self.passwordModel.value;
    } else {
        ctl.placeholderString = self.passwordModel.placeholderValue;
    }
    ctl.doneBlock = ^(NSString * _Nonnull content) {
        weak_self.emailPasswordStr = content;
        self.passwordModel.value = content;
        [weak_self.tableView reloadData];
    };
    ctl.checkInputBlock = ^NSString * _Nonnull(NSString * _Nonnull content) {
        BOOL result = content.length > 0;
        if (result) {
            return nil;
        }

        return NSLocalizedString(@"Please enter the email password or verification code", @"请输入邮箱密码或验证码");
    };
    [weak_self.navigationController pushViewController:ctl animated:YES];
}

- (void)showInputHost {
    weakfy(self);
    ESInputNormalController * ctl = [[ESInputNormalController alloc] init];
    ctl.navigationItem.title = self.smtpModel.title;
    ctl.keyboardType = UIKeyboardTypeDefault;
    if (self.accountModel.value.length > 0) {
        ctl.defaultString = self.smtpModel.value;
    } else {
        ctl.placeholderString = self.smtpModel.placeholderValue;
    }
    ctl.doneBlock = ^(NSString * _Nonnull content) {
        weak_self.hostStr = content;
        weak_self.smtpModel.value = content;
        [weak_self.tableView reloadData];
    };
    ctl.checkInputBlock = ^NSString * _Nonnull(NSString * _Nonnull content) {
        if (content.length > 0) {
            return nil;
        }
        return NSLocalizedString(@"Please input content", @"请输入内容");
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showInputPort {
    weakfy(self);
    ESInputNormalController * ctl = [[ESInputNormalController alloc] init];
    ctl.navigationItem.title = self.portModel.title;
    ctl.keyboardType = UIKeyboardTypeNumberPad;
    if (self.accountModel.value.length > 0) {
        ctl.defaultString = self.portModel.value;
    } else {
        ctl.placeholderString = self.portModel.placeholderValue;
    }
    ctl.doneBlock = ^(NSString * _Nonnull content) {
        weak_self.portStr = content;
        weak_self.portModel.value = content;
        [weak_self.tableView reloadData];
    };
    ctl.checkInputBlock = ^NSString * _Nonnull(NSString * _Nonnull content) {
        if (content.length > 0) {
            return nil;
        }
        return NSLocalizedString(@"Please input content", @"请输入内容");
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    self.dataArr1 = [NSMutableArray array];
    
    weakfy(self)
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"Account", @"账号");
        model.value = self.accountStr ?: nil;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.placeholderValue = @"example@company.com";
        model.hasArrow = YES;
        self.accountModel = model;
        model.onClick = ^{
            [weak_self showInputAccount];
        };
        [self.dataArr addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.isCipher = YES;
        model.title = NSLocalizedString(@"Password", @"密码");
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        self.passwordModel = model;
        model.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email password/verification code", @"邮箱密码/验证码") attributes:@{
            NSForegroundColorAttributeName: [UIColor es_colorWithHexString:@"#DFE0E5"]}];
        model.hasArrow = YES;
        model.onClick = ^{
            [weak_self showInoutPassword];
        };
        [self.dataArr addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"SMTP Service", @"SMTP服务器");
        model.value = self.hostStr ?: nil;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.placeholderValue = @"smtp.company.com";
        self.smtpModel = model;
        model.hasArrow = YES;
        model.onClick = ^{
            [weak_self showInputHost];
        };
        [self.dataArr1 addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"Port", @"端口");
        model.hasArrow = YES;
        self.portModel = model;
        model.value = self.portStr ?: nil;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.onClick = ^{
            [weak_self showInputPort];
        };
        [self.dataArr1 addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"Security type", @"安全类型");
        model.hasArrow = YES;
        self.sslModel = model;
        model.value = self.enableSSL ? @"SSL" : NSLocalizedString(@"None", @"无");
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        weakfy(model);
        model.onClick = ^{
            [ESEmailSSLModifyController showSSLModifyView:weak_self ssl:weak_self.enableSSL done:^(BOOL enableSSL) {
                weak_self.enableSSL = enableSSL;
                weak_model.value = enableSSL ? @"SSL" : NSLocalizedString(@"None", @"无");
                [weak_self.tableView reloadData];
            }];
        };
        [self.dataArr1 addObject:model];
    }
}

- (void)onVerifyBtn {
    weakfy(self);
    BOOL check = [ESSecurityEmailMamager checkInput:self account:self.accountStr ps:self.emailPasswordStr host:self.hostStr port:self.portStr handle:^{
        weak_self.showManualSetting = YES;
        [weak_self.tableView reloadData];
    }];
    if (!check) {
        return;
    }
    
    
    [self sendReq];
}

- (void)sendReq {
    weakfy(self);
    [self.verfiryBtn startLoading:NSLocalizedString(@"verifying", @"正在验证...")];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    param[@"securityToken"] = self.securityToken;
    param[@"emailAccount"] = self.accountStr;
    param[@"emailPasswd"] = [self.emailPasswordStr toHexString];
    param[@"host"] = self.hostStr;
    param[@"port"] = self.portStr;
    param[@"sslEnable"] = @(self.enableSSL);

    NSString * apiName;
    if (self.authType == ESAuthenticationTypeBinderSetEmail) {
        apiName = security_email_set_binder;
    } else if (self.authType == ESAuthenticationTypeAutherSetEmail) {
        apiName = security_email_set_auther;
    } else if (self.authType == ESAuthenticationTypeAutherModifyEmail) {
        apiName = security_email_modify_auther;
    } else if (self.authType == ESAuthenticationTypeBinderModifyEmail) {
        apiName = security_email_modify_binder;
    } else {
        [ESToast toastInfo:@"类型不对"];
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:apiName queryParams:nil header:nil body:param modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        [weak_self bindResult:ESSecurityEmailResult_AUTHENTICATION_SUCCESS title:@"" msg:@""];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        long errCode = [error errorCode];
        NSString * title = NSLocalizedString(@"bind failed", @"绑定失败");
        NSString * content = [error errorMessage];
        ESDLog(@"[安保功能] 设置密保邮箱失败：%@", error);
        [weak_self bindResult:errCode title:title msg:content];
    }];
}

- (void)bindResult:(long)code title:(NSString *)title msg:(NSString *)msg {
    [self.verfiryBtn stopLoading:NSLocalizedString(@"verify", @"验证")];
    NSString * content = NSLocalizedString(@"Wrong account or password", @"账号或密码错误，请重新输入");;
    if (code == ESSecurityEmailResult_AUTHENTICATION_SUCCESS) {
        ESSecurityEmailBindSuccessController * ctl = [[ESSecurityEmailBindSuccessController alloc] init];
        ctl.email = self.accountStr;
        [self.navigationController pushViewController:ctl animated:YES];
        return;
    }
    // 根据是设置邮箱还是重置邮箱，来决定title的内容
    else if (code == ESSecurityEmailResult_AUTHENTICATION_FAIL) {
        // title:身份验证失败 或 绑定失败（老安全邮箱认证）
        content = NSLocalizedString(@"Wrong account or password", @"账号或密码错误，请重新输入");
    } else if (code == ESSecurityEmailResult_BOUNDED_MAILBOX) {
        content = NSLocalizedString(@"email already bind", @"您已绑定此邮箱，请输入新的邮箱账号");
    } else if (code == ESSecurityEmailResult_VERIFICATION_EXPIRE) {
        // title:绑定失败 or 身份验证失败
        content = NSLocalizedString(@"Mail server connection timeout", @"邮件服务器连接超时");
    } else if (code == ESSecurityEmailResult_SECURITY_TOKEN_EXPIRE) {
        ESToast.networkError(NSLocalizedString(@"", @"验证过期")).show();
        return;
    }
    
    [self showAlert:title message:content];
}

- (void)onManualBtn {
    self.showManualSetting = !self.showManualSetting;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 60;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] init];
    if (section == 1) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setTitle:NSLocalizedString(@"Manual setting", @"手动设置") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangMedium(14);
        [btn addTarget:self action:@selector(onManualBtn) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view).offset(26);
            make.bottom.mas_equalTo(view).mas_offset(-10);
        }];
    }
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArr.count;
    }
    
    if (section == 1) {
        return self.showManualSetting ? self.dataArr1.count : 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESMeSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell"];
    ESCellModel * model;
    if (indexPath.section == 0) {
        model = [self.dataArr getObject:indexPath.row];
    } else if (indexPath.section == 1) {
        model = [self.dataArr1 getObject:indexPath.row];
    }
    cell.model = model;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model;
    if (indexPath.section == 0) {
        model = [self.dataArr getObject:indexPath.row];
    } else if (indexPath.section == 1) {
        model = [self.dataArr1 getObject:indexPath.row];
    }
    if (model.onClick) {
        model.onClick();
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESMeSettingCell class] forCellReuseIdentifier:@"ESMeSettingCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.tapView.mas_bottom).mas_offset(20);
            make.bottom.mas_equalTo(self.verfiryBtn.mas_top).offset(-20);
        }];
    }
    return _tableView;
}

- (void)dealloc {
    
}

- (void)onHelpView {
    ESWebContainerViewController * ctl = [[ESWebContainerViewController alloc] init];
    ctl.notSetIphoneOffSet = YES;
    ctl.notSetNavigationBarBackgroundColor = YES;
    ctl.webTitle = NSLocalizedString(@"security email help", @"密保邮箱帮助");
    NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
    NSString * url = [[NSString alloc] initWithFormat:@"%@support/help/001005", baseUrl];
    if ([ESCommonToolManager isEnglish]) {
        url = [[NSString alloc] initWithFormat:@"%@/en/support/help/001005", baseUrl];
    }
    ctl.webUrl = url;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (ESTapTextView *)tapView {
    if (!_tapView) {
        UIView * bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
        [self.view addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.view);
            make.height.mas_greaterThanOrEqualTo(60);
        }];
        
        ESTapTextView * tapView = [[ESTapTextView alloc] init];
        [bgView addSubview:tapView];
        [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(20, 20, 20, 20));
        }];
        weakfy(self);
        NSMutableArray * tapList = [NSMutableArray array];
        ESTapModel * model = [[ESTapModel alloc] init];
        model.text = NSLocalizedString(@"view help", @"查看帮助");
        model.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.underlineColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.textFont = ESFontPingFangRegular(12);
        model.onTapTextBlock = ^{
            [weak_self onHelpView];
        };
        [tapList addObject:model];
        
        NSString * content = NSLocalizedString(@"please enter the email account and password to be bound for login verification. view help", @"请输入要绑定的邮箱账号、密码进行登录验证。查看帮助");
        [tapView setShowData:content tap:tapList];
        _tapView = tapView;
    }
    
    return _tapView;
}

- (ESGradientButton *)verfiryBtn {
    if (!_verfiryBtn) {
        ESGradientButton * btn = [[ESGradientButton alloc] init];
        [btn setCornerRadius:10];
        [self.view addSubview:btn];
        [btn stopLoading:NSLocalizedString(@"verify", @"验证")];
        [btn addTarget:self action:@selector(onVerifyBtn) forControlEvents:UIControlEventTouchUpInside];
        _verfiryBtn = btn;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
        }];
        
        UILabel * label = [[UILabel alloc] init];
        label.text = NSLocalizedString(@"wont store your email password information only for login verification", @"傲空间不会存储您的邮箱密码信息，仅用于登录验证");
        label.font = ESFontPingFangRegular(10);
        label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(btn.mas_bottom).mas_offset(20);
            make.left.mas_equalTo(self.view).offset(20);
            make.right.mas_equalTo(self.view).offset(-20);
            make.bottom.mas_equalTo(self.view).mas_offset(-kBottomHeight);
        }];
    }
    return _verfiryBtn;
}



@end
