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
//  ESAuthenticationApplyController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationApplyController.h"
#import "ESGradientButton.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "ESBoxManager.h"
#import "ESDeviceInfoModel.h"
#import "ESCache.h"
#import "UIViewController+ESTool.h"
#import "NSError+ESTool.h"
#import "ESBoxManager.h"

// 10分钟内绑定端不确认，就超时提示
#define ESAdminApplyOptTime (10 * 60)

@interface ESAuthenticationApplyController ()
@property (nonatomic, assign) NSUInteger poolId;
@property (nonatomic, assign) NSTimeInterval beginApplyTime;
@property (nonatomic, strong) NSTimer * timer;
@end



@implementation ESAuthenticationApplyController


+ (void)showAuthApplyView:(UIViewController *)srcCtl
                     type:(ESAuthenticationType)authType
                    block:(void(^)(ESAuthApplyRsp * applyRsp))optBlock
                   cancel:(void(^)(void))cancelBlock {
    ESAuthenticationApplyController * dstCtl = [[ESAuthenticationApplyController alloc] init];
    dstCtl.optBlock = optBlock;
    dstCtl.cancelBlock = cancelBlock;
    dstCtl.authType = authType;
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);

    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor es_colorWithHexString:@"#00000050"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.beginApplyTime = -1;
    [self setupViews];
    [self sendReqForAuther];
}

- (void)sendReqForAuther {
    if (self.authType == ESAuthenticationTypeAutherModifyPassword || self.authType == ESAuthenticationTypeAutherResetPassword) {
        [self sendApplyReqForAuther];
        [self startSecurityMessagePollForAuther];
    }
}

- (void)onBecomeActiveNotification {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (self.beginApplyTime > 0 && now - self.beginApplyTime >= ESAdminApplyOptTime) {
        [self showAdminNotOptIntime];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ESNetworkRequestManager cancelRequestById:self.poolId];
    [self endTimer];
}

- (void)sendApplyReqForAuther {
    weakfy(self);
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"deviceInfo"] = [UIDevice currentDevice].name ?: @"No device Info";
    params[@"applyId"] = [NSString stringWithFormat:@"applyId_%f", [[NSDate date] timeIntervalSince1970]];
    NSString * apiName;
    if (self.authType == ESAuthenticationTypeAutherModifyPassword) {
        apiName = security_passwd_modify_auther_apply;
    } else if (self.authType == ESAuthenticationTypeAutherResetPassword) {
        apiName = security_passwd_reset_auther_apply;
    } else {
        ESDLog(@"[安保功能] 修改安全密码申请的类型不对");
        return;
    }
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:apiName queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESDLog(@"[安保功能] 修改安全密码申请的请求成功");
        strongfy(self);
        self.beginApplyTime = [[NSDate date] timeIntervalSince1970];
        [self startTimer];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[安保功能] 修改安全密码申请的请求失败:%@", error);
        strongfy(self);

        NSString * codeStr = [error codeString];
        if ([codeStr isEqualToString:@"ACC-410"]) {
            [self showAlert:NSLocalizedString(@"The request is too frequent, try again later", @"请求太过频繁，稍后重试！") handle:^{
                [self onCancelBtn];
            }];
            return;
        }

        [self showAlert:NSLocalizedString(@"Tips", @"提示")
                     message:NSLocalizedString(@"The request failed. Do you want to retry?", "请求失败，是否重试？")
                     optName:NSLocalizedString(@"cancel", @"取消")
                      handle:nil
                    optName1:NSLocalizedString(@"ok", @"确定")
                     handle1:^{
            [self sendApplyReqForAuther];
        }];
    }];
}

- (void)startTimer {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ESAdminApplyOptTime target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    } else {
        [self.timer fire];
    }
}

- (void)onTimer {
    ESDLog(@"[安保功能] 授权端申请权限页面超时检测");
    [ESNetworkRequestManager cancelRequestById:self.poolId];
    [self endTimer];
    [self showAdminNotOptIntime];
}

- (void)endTimer {
    ESDLog(@"[安保功能] 授权端申请权限页面-释放定时器");

    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startSecurityMessagePollForAuther {
    if (!(self.authType == ESAuthenticationTypeAutherModifyPassword || self.authType == ESAuthenticationTypeAutherResetPassword)) {
        return;
    }
    
    weakfy(self);
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"clientUuid"] = ESBoxManager.clientUUID;
    ESDLog(@"[安保功能] 发送security message poll");
    self.poolId = [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:security_message_poll queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESDLog(@"[安保功能] 收到security message poll成功回调：%@", response);
        strongfy(self);
        if ([response isKindOfClass:NSArray.class]) {
            NSArray * arr = [NSArray yy_modelArrayWithClass:ESAuthApplyRsp.class json:response];
            ESDLog(@"[安保功能] arr count：%ld", arr.count);

            if (arr.firstObject != nil) {
                [self endTimer];
                ESAuthApplyRsp * data = arr.firstObject;
                if (data.accept == NO) {
                    [self showRefuseView];
                    return;
                }
                
                ESDLog(@"[安保功能] self.presentingViewController：%@", self.presentingViewController);
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    ESDLog(@"[安保功能] self.optBlock：%@", self.optBlock);
                    if (self.optBlock) {
                        self.optBlock(data);
                    }
                }];
                return;
            }
        }
        [self startSecurityMessagePollForAuther];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[安保功能] 收到security message poll失败回调:%@", error);
        strongfy(self);
        [self startSecurityMessagePollForAuther];
    }];
}

- (void)onUnavailable {
    self.applyView.hidden = YES;
    [self.failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view).offset(53);
        make.trailing.mas_equalTo(self.view).offset(-53);
    }];
}

- (void)showRefuseView {
    self.applyView.hidden = YES;
    [self.failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view).offset(53);
        make.trailing.mas_equalTo(self.view).offset(-53);
    }];
    self.reasonLabel.text = NSLocalizedString(@"reason:admin refuse", @"原因：管理员在绑定端拒绝了此操作");
    self.reasonHintLabel.hidden = YES;
}

// 未及时操作
- (void)showAdminNotOptIntime {
    [self onUnavailable];
    self.reasonLabel.text = NSLocalizedString(@"reason:admin not opt in time", @"原因：管理员未在绑定端进行确认操作");
    self.reasonHintLabel.hidden = YES;
}

- (void)onCancelBtn {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupViews {
    [self.applyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view).offset(28);
        make.right.mas_equalTo(self.view).offset(-28);
    }];
}

- (UIView *)failedView {
    if (!_failedView) {
        UIView * containView = [[UIView alloc] init];
        containView.backgroundColor = [UIColor whiteColor];
        containView.layer.masksToBounds = YES;
        containView.layer.cornerRadius = 10;
        [self.view addSubview:containView];
        _failedView = containView;
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"auth_apply_failed"]];
        [containView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.top.mas_equalTo(containView).offset(20);
        }];
        self.failedHintImageView = iv;
        
        UILabel * label = [[UILabel alloc] init];
        self.reasonTitleLabel = label;
        label.numberOfLines = 0;
        label.font = ESFontPingFangMedium(18);
        label.textColor = [UIColor es_colorWithHexString:@"#333333"];
        label.text = NSLocalizedString(@"operation failed", @"操作失败");
        [containView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.leading.mas_greaterThanOrEqualTo(containView).offset(10);
            make.trailing.mas_lessThanOrEqualTo(containView).offset(-10);
            make.top.mas_equalTo(iv.mas_bottom).offset(30);
        }];
        
        UILabel * label1 = [[UILabel alloc] init];
        self.reasonLabel = label1;
        label1.numberOfLines = 0;
        label1.font = ESFontPingFangRegular(14);
        label1.textColor = [UIColor es_colorWithHexString:@"#333333"];
        label1.text = NSLocalizedString(@"auth_failed_reason", @"原因：管理员绑定端无法确认");
        [containView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(containView).offset(35);
            make.trailing.mas_equalTo(containView).offset(-35);
            make.top.mas_equalTo(label.mas_bottom).offset(20);
        }];
        
        UILabel * label2 = [[UILabel alloc] init];
        label2.numberOfLines = 0;
        label2.font = ESFontPingFangRegular(14);
        label2.textColor = [UIColor es_colorWithHexString:@"#85899C"];
        label2.text = NSLocalizedString(@"auth_failed_hint", @"请在新手机上完成【绑定设备】后再操作修改安全密码。");
        [containView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(containView).offset(35);
            make.trailing.mas_equalTo(containView).offset(-35);
            make.top.mas_equalTo(label1.mas_bottom).offset(10);
        }];
        self.reasonHintLabel = label2;
        
        ESGradientButton * btn = [[ESGradientButton alloc] init];
        [btn setCornerRadius:10];
        [btn addTarget:self action:@selector(onCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [containView addSubview:btn];
        [btn setTitle:NSLocalizedString(@"ok", @"确定") forState:UIControlStateNormal];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(containView);
            make.bottom.mas_equalTo(containView).offset(-43);
            make.top.mas_equalTo(label2.mas_bottom).offset(40);
        }];
    }
    return _failedView;
}

- (UIView *)applyView {
    if (!_applyView) {
        UIView * containView = [[UIView alloc] init];
        containView.backgroundColor = [UIColor whiteColor];
        containView.layer.masksToBounds = YES;
        containView.layer.cornerRadius = 10;
        [self.view addSubview:containView];
        _applyView = containView;
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"admin_apply"]];
        [containView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(100);
            make.centerX.mas_equalTo(containView);
            make.top.mas_equalTo(containView).offset(60);
        }];
        
        UILabel * label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.font = ESFontPingFangMedium(16);
        label.textColor = [UIColor es_colorWithHexString:@"#333333"];
        label.text = NSLocalizedString(@"needs to verify your administrator identity", @"傲空间需要验证您的管理员身份");
        [containView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.leading.mas_greaterThanOrEqualTo(containView).offset(10);
            make.trailing.mas_lessThanOrEqualTo(containView).offset(-10);
            make.top.mas_equalTo(iv.mas_bottom).offset(30);
        }];
        
        UILabel * label1 = [[UILabel alloc] init];
        label1.numberOfLines = 0;
        label1.font = ESFontPingFangMedium(18);
        label1.textColor = [UIColor es_colorWithHexString:@"#333333"];
        label1.text = NSLocalizedString(@"confirm on the bound phone", @"请在绑定手机上确认");
        [containView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.leading.mas_greaterThanOrEqualTo(containView).offset(10);
            make.trailing.mas_lessThanOrEqualTo(containView).offset(-10);
            make.top.mas_equalTo(label.mas_bottom).offset(20);
        }];
        
        UILabel * label2 = [[UILabel alloc] init];
        label2.numberOfLines = 0;
        label2.font = ESFontPingFangRegular(12);
        label2.textColor = [UIColor es_colorWithHexString:@"#F6222D"];
        label2.text = NSLocalizedString(@"es_auth_reset_password_hint", @"* 请先打开绑定手机的傲空间 App ，后执行此操作");
        [containView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(containView);
            make.leading.mas_greaterThanOrEqualTo(containView).offset(10);
            make.trailing.mas_lessThanOrEqualTo(containView).offset(-10);
            make.top.mas_equalTo(label1.mas_bottom).offset(10);
        }];
        
        ESTapTextView * tapView = [[ESTapTextView alloc] init];
        [containView addSubview:tapView];
        [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(label2.mas_bottom).offset(33);
            make.centerX.mas_equalTo(containView);
        }];
        weakfy(self);
        NSMutableArray * tapList = [NSMutableArray array];
        ESTapModel * model = [[ESTapModel alloc] init];
        model.text = NSLocalizedString(@"bound phone is unavailable", @"绑定手机不可用");
        model.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.underlineColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.textFont = ESFontPingFangRegular(14);
        model.onTapTextBlock = ^{
            strongfy(self);
            [self onUnavailable];
        };
        [tapList addObject:model];
        
        NSString * content = NSLocalizedString(@"bound phone is unavailable", @"绑定手机不可用");
        [tapView setShowData:content tap:tapList];
        
        UIButton * cancelBtn = [[UIButton alloc] init];
        [cancelBtn addTarget:self action:@selector(onCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [containView addSubview:cancelBtn];
        [cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor es_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = ESFontPingFangRegular(16);
        cancelBtn.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.layer.cornerRadius = 10;
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(containView);
            make.bottom.mas_equalTo(containView).offset(-60);
            make.top.mas_equalTo(tapView.mas_bottom).offset(50);
        }];
    }
    return _applyView;
}

- (UILabel *)getLabel:(UIView *)containView color:(UIColor *)color text:(NSString *)text font:(UIFont*)font {
    UILabel * label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.font = font;
    label.textColor = color;
    label.text = text;
    [containView addSubview:label];
    return label;
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
