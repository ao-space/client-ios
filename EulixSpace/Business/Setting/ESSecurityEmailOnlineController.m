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
//  ESSecurityEmailOnlineController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityEmailOnlineController.h"
#import "AAPLCustomPresentationController.h"
#import "UIFont+ESSize.h"
#import "UIColor+ESHEXTransform.h"
#import "ESGradientButton.h"
#import "ESAuthenticationTypeController.h"
#import "ESAccountInfoStorage.h"
#import "ESSecurityEmailMamager.h"

#define ESSecurityEmailOnlineShowKey @"ESSecurityEmailOnlineShowOnceKey"

@interface ESSecurityEmailOnlineController ()
@property (nonatomic, copy) void (^block)(void);
@property (nonatomic, weak) UIViewController * srcCtl;

@end

@implementation ESSecurityEmailOnlineController


+ (void)showSecurityEmailOnlineView:(UIViewController *)srcCtl {
    NSString * version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    if (![@"1.0.14" isEqualToString:version]) {
        return;
    }
    
    if (![ESAccountInfoStorage isAdminOrAuthAccount]) {
        return;
    }
    
    NSString * show = [[NSUserDefaults standardUserDefaults] objectForKey:ESSecurityEmailOnlineShowKey];
    if (show && show.length > 0) {
        return;
    }
    
    [ESSecurityEmailMamager reqSecurityEmailInfo:^(ESSecurityEmailSetModel * _Nonnull model) {
        
    } notSet:^{
        ESSecurityEmailOnlineController * dstCtl = [[ESSecurityEmailOnlineController alloc] init];
        
        dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        dstCtl.srcCtl = srcCtl;
        AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
        dstCtl.transitioningDelegate = presentationController;
        [srcCtl presentViewController:dstCtl animated:YES completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:ESSecurityEmailOnlineShowKey];

    self.view.backgroundColor = [UIColor es_colorWithHexString:@"#00000050"];
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"security_email_online"]];
    [self.view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).offset(-40);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(330);
    }];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"security email online", @"密保邮箱上线啦！");
    label.numberOfLines = 0;
    label.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
    label.font = ESFontPingFangSemibold(20);
    [iv addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(iv).offset(10);
        make.right.mas_lessThanOrEqualTo(iv).offset(-10);
        make.centerX.mas_equalTo(iv);
        make.top.mas_equalTo(iv).offset(220);
    }];
    
    UILabel * label1 = [[UILabel alloc] init];
    label1.text = NSLocalizedString(@"security email online hint", @"密保邮箱是管理员身份验证的工具，绑定后可以使用密保邮箱来重置安全密码");
    label1.numberOfLines = 0;
    label1.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label1.font = ESFontPingFangRegular(14);
    [iv addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iv).offset(30);
        make.right.mas_equalTo(iv).offset(-30);
        make.top.mas_equalTo(label.mas_bottom).offset(14);
    }];
    
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColor.whiteColor;
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 10;
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(iv);
        make.centerX.mas_equalTo(iv);
        make.height.mas_equalTo(112);
        make.top.mas_equalTo(iv.mas_bottom).offset(-11);
    }];
    
    ESGradientButton * btn = [[ESGradientButton alloc] init];
    [bgView addSubview:btn];
    [btn setCornerRadius:10];
    [btn setTitle:NSLocalizedString(@"to set security email", @"去设置") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onToSecutiryEmail) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(bgView).offset(20);
    }];
    
    UIButton * btn1 = [[UIButton alloc] init];
    [self.view addSubview:btn1];
    [btn1 setImage:[UIImage imageNamed:@"close_1"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(onCloseView) forControlEvents:UIControlEventTouchUpInside];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(bgView.mas_bottom).offset(30);
    }];
}

- (void)onToSecutiryEmail {
    ESAuthenticationTypeController * ctl = [[ESAuthenticationTypeController alloc] init];
    if ([ESAccountInfoStorage isAdminAccount]) {
        ctl.authType = ESAuthenticationTypeBinderSetEmail;
    } else if ([ESAccountInfoStorage isAuthAccount]) {
        ctl.authType = ESAuthenticationTypeAutherSetEmail;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.srcCtl.navigationController pushViewController:ctl animated:YES];
    }];
}

- (void)onCloseView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
