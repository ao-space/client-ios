//
//  ESSecurityPasswordVerifyVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordVerifyVC.h"
#import "ESBindResultViewController.h"
#import "ESToast.h"
#import "NSString+ESTool.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"
#import "ESAccountInfoStorage.h"
#import "ESAuthenticationTypeController.h"
#import "ESSpaceGatewayAdminAuthingServiceApi.h"
#import "ESBoxManager.h"
#import "ESRSACenter.h"
#import "ESCache.h"
#import "ESSecurityEmailMamager.h"
#import "ESAuthenticationApplyForNewDeviceController.h"
#import "ESVerifySecurityEmailForNewDeviceController.h"
#import "ESSecurityPasswordResetByEmailController.h"
#import "ESHardwareVerificationController.h"
#import "ESGatewayClient.h"
#import "ESSapceWelcomeVC.h"
#import "ESCommonToolManager.h"
#import "ESPinCodeTextField.h"
#import "ESBoxBindViewModel.h"
#import "UIColor+ESHEXTransform.h"
#import "ESAccountInfoStorage.h"
#import "ESAuthenticationTypeController.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESReTransmissionManager.h"
#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "ESPinCodeTextField.h"
#import "ESThemeDefine.h"

@interface ESSecurityPasswordVerifyVC () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSTimeInterval failTimer;
@property (nonatomic, assign) NSInteger failCount;

@property (nonatomic, assign) BOOL isReceivedEmailInfo;
@property (nonatomic, strong) ESSecurityEmailModel * emailInfo;

@property (nonatomic, strong) UIButton *showPromptButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) ESPinCodeTextField *pinCodeTextField;

@property (nonatomic, strong) UIButton * forgetPasswordBtn;
@end

@implementation ESSecurityPasswordVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"Secure Password Authentication", @"安全密码验证");
    self.titleLabel.text = NSLocalizedString(@"security_password_placeholder", @"请输入安全密码");
    
    [self.pinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(26);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(50);
        make.height.mas_equalTo(56);
    }];
    [self.showPromptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pinCodeTextField.mas_bottom).inset(22);
        make.left.mas_equalTo(self.view).inset(44);
        make.height.width.mas_equalTo(14);
    }];
    
//    if ([ESAccountInfoStorage isAdminOrAuthAccount] || self.viewModel.boxStatus.infoResult.oldBox) {
//        [self.forgetPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(self.view).offset(-42);
//            make.centerY.mas_equalTo(self.showPromptButton);
//        }];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pinCodeTextField becomeFirstResponder];
}

- (void)editingChanged:(UITextField *)sender {
    if (sender.text.length < 6) {
        return;
    }

    [self verifyUnbindPassword:sender.text];
}

//- (void)onBindCommand:(ESBCCommandType)command resp:(id)response {
//    if (command == ESBCCommandTypeBindSpaceCreateReq) {
//        [ESToast dismiss];
//        if ([response[@"code"] isEqualToString:@"AG-200"]) {
//            NSString * btid = [self.viewModel getBtid];
//            ESBoxItem *box = [ESBoxManager onJustParing:self.viewModel.boxInfo
//                                              spaceName:self.viewModel.spaceName
//                                   enableInternetAccess:self.viewModel.enableInternetAccess
//                                              localHost:self.viewModel.localHost
//                                                   btid:btid
//                                             diskStatus:self.viewModel.diskInitialCode
//                                                   init:self.viewModel.boxStatus.infoResult];
//            ESSapceWelcomeVC * ctl = [[ESSapceWelcomeVC alloc] init];
//            ctl.paringBoxItem = box;
//            [self.navigationController pushViewController:ctl animated:YES];
//            return;
//        }
//        [self.pinCodeTextField clearText];
//        if ([response[@"code"] isEqualToString:@"AG-460"]) {
//            [ESToast toastError:@"不要重复绑定"];
//            return;
//        }
//        [ESToast toastError:@"绑定失败"];
//    }
//
//    if (command == ESBCCommandTypeBindRevokeReq) {
//        if (![response isKindOfClass:[NSDictionary class]]) {
//            return;
//        }
//
//        NSDictionary *res = (NSDictionary *)response;
//        if (![res.allKeys containsObject:@"results"] ||
//            ![res[@"results"] isKindOfClass:[NSDictionary class]]) {
//            return;
//        }
//        if ([res[@"code"] isEqualToString:@"AG-200"]) {
//            NSString *resultCode = res[@"results"][@"code"];
//            if ([resultCode isEqualToString:@"ACC-463"]) {
//                [ESToast dismiss];
//                [self passwordError];
//                return;
//            }
//
//            if ([resultCode isEqualToString:@"ACC-200"]) {
//                self.viewModel.agentToken = res[@"results"][@"agentToken"];
//                NSDictionary *req = @{@"clientPhoneModel" : ESSafeString([ESCommonToolManager judgeIphoneType:@""]),
//                                      @"clientUuid" : ESSafeString(ESBoxManager.clientUUID),
////                                      @"enableInternetAccess" : @(self.isInternetOn),
//                                      @"password" : ESSafeString(self.viewModel.securityPassword),
////                                      @"spaceName" : ESSafeString(self.viewModel.spaceName),
//                };
//                [self.viewModel sendSpaceCreate:req];
//                return;
//            }
//            [ESToast dismiss];
//            [ESToast toastError:@"绑定失败"];
//        }
//      }
//}

- (void)passwordError {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    self.errorLabel.hidden = NO;
    self.failCount++;
    if (self.failCount >= 3 &&
        self.failTimer > 0 &&
        (currentTime - self.failTimer) < 60) {
        self.failTimer = currentTime;
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        [self goBack];
        return;
    }
    self.errorLabel.text = [NSString stringWithFormat:@"密码错误，还剩下%lu次机会", MAX(3 - self.failCount, 1)];
    if (self.failCount == 1) {
        self.failTimer = [[NSDate date] timeIntervalSince1970];
    }
    
    [self.pinCodeTextField clearText];
}

- (void)verifyUnbindPassword:(NSString *)password {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if ( self.failTimer > 0 &&
        (currentTime - self.failTimer) > 60 ) {
        self.failTimer = 0;
        self.failCount = 0;
    }
    
    ESBoxItem *box = ESBoxManager.activeBox;
    ESRSAPair *pair = [ESRSACenter boxPair:box.boxUUID];
    
    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
    apiClient.timeoutInterval = 120;
    
    ESSpaceGatewayAdminAuthingServiceApi *api = [[ESSpaceGatewayAdminAuthingServiceApi alloc] initWithApiClient:apiClient];

    [api setDefaultHeaderValue:@"clientUuid" forKey:ESBoxManager.clientUUID];
    ESRevokeClientInfo *info = [ESRevokeClientInfo new];
    info.encryptedAuthKey = [pair publicEncrypt:box.info.authKey];
    info.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    info.encryptedPasscode = [pair publicEncrypt:password];
    
    ESToast.showLoading(TEXT_WAIT, self.view);
    [api spaceV1ApiGatewayAuthRevokePostWithBody:info
                               completionHandler:^(ESResponseBaseRevokeClientResult *output, NSError *error) {
                       [ESToast dismiss];
   
        ESBindResultViewController *vc = [ESBindResultViewController new];
        if (error == nil && [output.code isEqual:@"GW-200"]) {
            vc.success = YES;
            vc.type = ESBindResultTypeRevokeViaGateway;
            [self.navigationController pushViewController:vc animated:YES];
            self.errorLabel.hidden = YES;
            self.failTimer = 0;
            self.failCount = 0;
            return;
        }
        
        if ([output.code isEqual:@"GW-406"]) {
            self.errorLabel.hidden = NO;
            self.failCount++;
            if (self.failCount >= 3 &&
                self.failTimer > 0 &&
                (currentTime - self.failTimer) < 60) {
                self.failTimer = currentTime;
                ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
                [self goBack];
                return;
            }
            self.errorLabel.text = [NSString stringWithFormat:@"密码错误，还剩下%lu次机会", MAX(3 - self.failCount, 1)];
            if (self.failCount == 1) {
                self.failTimer = [[NSDate date] timeIntervalSince1970];
            }
            
            [self.pinCodeTextField clearText];
        } else if ([output.code isEqualToString:@"GW-5005"]) {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        }else {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onForgetPasswordBtn {
    NSString * key = [[NSString alloc] initWithFormat:@"ESNewDeviceApplyResetPs"];
    if ([[ESReTransmissionManager Instance] failedEventIsResume:key distance:60] == NO) {
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        return;
    }
}

- (void)showPrompt {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_SECURITY_PASSWORD_PROMPT_TITLE
                                                                   message:TEXT_SECURITY_PASSWORD_PROMPT_DETAIL
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attributedMessage = [TEXT_SECURITY_PASSWORD_PROMPT_DETAIL es_toAttr:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName: ESColor.labelColor,
        NSParagraphStyleAttributeName: paragraphStyle,

    }];
    [alert setValue:attributedMessage forKey:@"attributedMessage"];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_GOT_IT
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewModelOnRevoke:(ESBoxStatusItem *)boxStatus {
    self.pinCodeTextField.userInteractionEnabled = YES;
    [ESToast dismiss];
    ESPasswdTryInfo *results = boxStatus.revokeResult.results;
    ///解绑成功, 跳转设置 wifi 页面
    if (boxStatus.revokeResult.success) {
        [self nextStep];
        return;
    }
    if (results.leftTryTimes.integerValue == 0) {
//        self.killWhenPushed = YES;
//        ESBindResultViewController *next = [ESBindResultViewController new];
//        next.type = ESBindResultTypeUnbind;
//        next.success = NO;
//        next.prompt = TEXT_SECURITY_PASSWORD_ERROR_AND_RETRY_LATER_PROMPT;
//        next.viewModel = self.viewModel;
//        [self.navigationController pushViewController:next animated:YES];
//        return;
    }
    self.errorLabel.hidden = NO;
    self.errorLabel.text = [NSString stringWithFormat:TEXT_BOX_UNBIND_PASSWORD_ERROR_PROMPT, boxStatus.revokeResult.results.leftTryTimes];
}

- (void)nextStep {
    ESSapceWelcomeVC *vc = [ESSapceWelcomeVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ESViewBuilder.label(TEXT_SECURITY_PASSWORD_INPUT).fontSize(16).fontWeight(UIFontWeightMedium).textColor(ESColor.labelColor).build(self.view);
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).inset(66 + kTopHeight);
            make.left.right.mas_equalTo(self.view).inset(44);
            make.height.mas_equalTo(22);
        }];
    }
    return _titleLabel;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = ESViewBuilder.label(nil).fontSize(12).textColor(ESColor.redColor).build(self.view);
        [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(10);
            make.left.right.mas_equalTo(self.view).inset(44);
            make.height.mas_equalTo(17);
        }];
    }
    return _errorLabel;
}

- (ESPinCodeTextField *)pinCodeTextField {
    if (!_pinCodeTextField) {
        _pinCodeTextField = [ESPinCodeTextField new];
        _pinCodeTextField.digitsCount = 6;
        _pinCodeTextField.font = [UIFont systemFontOfSize:40 weight:(UIFontWeightMedium)];
        _pinCodeTextField.bordersSpacing = 18;
        _pinCodeTextField.borderHeight = 1;
        _pinCodeTextField.emptyDigitBorderColor = ESColor.labelColor;
        _pinCodeTextField.filledDigitBorderColor = ESColor.labelColor;
        _pinCodeTextField.secureTextEntry = YES;
        _pinCodeTextField.keyboardType = UIKeyboardTypePhonePad;
        [_pinCodeTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_pinCodeTextField];
    }
    return _pinCodeTextField;
}

- (UIButton *)showPromptButton {
    if (!_showPromptButton) {
        _showPromptButton = [UIButton new];
        [_showPromptButton setImage:IMAGE_FILE_BOTTOM_DETAILS forState:UIControlStateNormal];
        [_showPromptButton addTarget:self action:@selector(showPrompt) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_showPromptButton];
        UILabel *prompt = ESViewBuilder.label(TEXT_SECURITY_PASSWORD_INPUT_PROMPT).fontSize(14).textColor(ESColor.secondaryLabelColor).build(self.view);
        [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.pinCodeTextField.mas_bottom).inset(20);
            make.left.mas_equalTo(_showPromptButton.mas_right).inset(4);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(self.view.mas_right).inset(44);
        }];
    }
    return _showPromptButton;
}

- (UIButton *)forgetPasswordBtn {
    if (!_forgetPasswordBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setTitle:NSLocalizedString(@"Forgot password", @"忘记密码") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangRegular(14);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(onForgetPasswordBtn) forControlEvents:UIControlEventTouchUpInside];
        _forgetPasswordBtn = btn;
    }
    return _forgetPasswordBtn;
}

- (NSTimeInterval)failTimer {
   NSNumber *failTimerNumber = [[ESCache defaultCache] objectForKey:@"ESFailTimer"];
    if (failTimerNumber == nil) {
        return 0;
    }
    return [failTimerNumber doubleValue];
}

- (void)setFailTimer:(NSTimeInterval)failTimer {
    [[ESCache defaultCache] setObject:@(failTimer) forKey:@"ESFailTimer"];
}

- (NSInteger)failCount {
    NSNumber *failCount_ = [[ESCache defaultCache] objectForKey:@"ESFailCount"];
     if (failCount_ == nil) {
         return 0;
     }
     return [failCount_ intValue];
}

- (void)setFailCount:(NSInteger)failCount {
    if (failCount == 1) {
        weakfy(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            strongfy(self)
            if (self.isViewLoaded && self.view.window != nil) {
                self.errorLabel.hidden = YES;
            }
        });
    }
    [[ESCache defaultCache] setObject:@(failCount) forKey:@"ESFailCount"];
}

@end
