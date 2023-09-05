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
//  ESFileProtocolView.m
//  EulixSpace
//
//  Created by qu on 2021/12/21.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTryUseProtocolView.h"
#import "ESBoxManager.h"
#import "ESAgreementWebVC.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import "ESGradientButton.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "ESPlatformQuestionnaireManagementServiceApi.h"

@interface ESTryUseProtocolView () <UITextViewDelegate>

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UILabel *protocol;

@property (nonatomic, strong) ESGradientButton *delectCompleteBtn;

@property (nonatomic, strong) UIButton *delectCancelBtn;

@property (nonatomic, strong) UITextView *agreementTextView;

@property (nonatomic, strong) UIImageView *iconImageView;

//IMAGE_TRY_HEADIMAGEVIEW

@end

@implementation ESTryUseProtocolView

#pragma mark - Lazy Load

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(270.0f);
        make.height.mas_equalTo(356.0f);
    }];

    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(105);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(108.0f);
        make.height.mas_equalTo(25.0f);
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(97.0f);
        make.height.mas_equalTo(73.0f);
    }];

    [self.delectCompleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-72.0f);
        make.left.mas_equalTo(self.mas_left).offset(88.0f);
        make.right.mas_equalTo(self.mas_right).offset(-88.0f);
        make.height.mas_equalTo(44.0f);
    }];

    [self.delectCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-25.0f);
        make.left.mas_equalTo(self.programView.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-10.0f);
        make.height.mas_equalTo(44.0f);
    }];

    self.agreementTextView = [[UITextView alloc] init];
    self.agreementTextView.delegate = self;
    self.agreementTextView.linkTextAttributes = @{};
    [self.programView addSubview:self.agreementTextView];

    self.agreementTextView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

    [self.agreementTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(30.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-30.0);
        make.top.mas_equalTo(self.programView.mas_top).offset(146.0f);
        make.height.mas_equalTo(64.0f);
    }];
    [self agreementSetupHanle];
}

- (void)agreementSetupHanle {
    [self getManagementServiceApi];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([URL.absoluteString isEqualToString:@"2"]) {
        [self userAgreementAction];
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    UITextView *textView = (UITextView *)tap.view;
    CGPoint tapLocation = [tap locationInView:textView];
    UITextPosition *position = [textView closestPositionToPoint:tapLocation];
    NSDictionary *attr = [textView textStylingAtPosition:position inDirection:UITextStorageDirectionForward];
    if ([attr.allKeys containsObject:NSLinkAttributeName]) {
        NSLog(@"%@", attr[NSLinkAttributeName]);
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 430, ScreenWidth, 430)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        _programView.layer.masksToBounds = YES;
        _programView.layer.cornerRadius = 10;

        [self addSubview:_programView];
    }
    return _programView;
}

- (ESGradientButton *)delectCompleteBtn {
    if (!_delectCompleteBtn) {
        _delectCompleteBtn = [ESGradientButton buttonWithType:UIButtonTypeCustom];
        [_delectCompleteBtn addTarget:self action:@selector(didClickDelectCompleteBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.programView addSubview:_delectCompleteBtn];
        [_delectCompleteBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_delectCompleteBtn setTitle:@"立即填写" forState:UIControlStateNormal];
        [_delectCompleteBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_delectCompleteBtn setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_delectCompleteBtn setCornerRadius:10];
    }
    return _delectCompleteBtn;
}

- (UIButton *)delectCancelBtn {
    if (!_delectCancelBtn) {
        _delectCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectCancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [_delectCancelBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        [_delectCancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_delectCancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_delectCancelBtn setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [self.programView addSubview:_delectCancelBtn];
    }
    return _delectCancelBtn;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = [ESColor labelColor];
        _pointOutLabel.numberOfLines = 0;
        _pointOutLabel.textAlignment = NSTextAlignmentCenter;
        _pointOutLabel.text = @"试用反馈问卷";
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (void)didClickCancelBtn {
    if (self.isKillApp) {
        exit(0);
    }else{
        self.hidden = YES;
    }
}

- (void)didClickDelectCompleteBtn {
    if (self.actionBlock) {
        self.actionBlock(@(1));
    }
    self.hidden = YES;
}

- (void)setPointOutStr:(NSString *)pointOutStr {
    self.pointOutLabel.text = pointOutStr;
}

- (void)concealAction {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESConcealtAgreement;
    UITabBarController *rootVC = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigation = (UINavigationController *)rootVC.selectedViewController;
    [navigation pushViewController:vc animated:YES];
}

- (void)userAgreementAction {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESConcealtAgreement;
    UITabBarController *rootVC = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigation = (UINavigationController *)rootVC.selectedViewController;
    [navigation pushViewController:vc animated:YES];
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_TRY_HEAD_IMAGE;
        [self.programView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (void)getManagementServiceApi {
    NSURL *requesetUrl = [NSURL URLWithString:ESPlatformClient.platformClient.platformUrl];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    ESPlatformQuestionnaireManagementServiceApi *api = [[ESPlatformQuestionnaireManagementServiceApi alloc] initWithApiClient:ESPlatformClient.platformClient];
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userId = dic[@"aoId"];
    [api questionnaireListWithCurrentPage:@(1)
                                 pageSize:@(100)
                                 userId:  userId
                                 boxUuid: ESBoxManager.activeBox.boxUUID
                        completionHandler:^(ESPageListResultQuestionnaireRes *output, NSError *error) {
        ;
        if (output.list.count > 0) {
            int inProcessNum = 0;
            for (ESQuestionnaireRes *questionnaireRes in output.list) {
                if([questionnaireRes.state isEqual:@"in_process"]){
                    inProcessNum =  inProcessNum + 1;
                }
            }
            NSString *agreementMessage = [NSString stringWithFormat: @"您有%d份试用反馈待填写",inProcessNum];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:agreementMessage];
            NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
            NSString *sagreementStr = [NSString stringWithFormat:@"%@agreement", baseUrl];
            NSAttributedString *registPolicyAttr = [[NSAttributedString alloc] initWithString:@"，若不及时填写，可能会影响您的后续使用哦！"
                                                                                   attributes:@{
                NSForegroundColorAttributeName: ESColor.primaryColor,
                NSLinkAttributeName: sagreementStr
            }];
            [attributedString appendAttributedString:registPolicyAttr];
            // 设置间距
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5; // 字体的行间距
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[[attributedString string] rangeOfString:agreementMessage]];
            self.agreementTextView.attributedText = attributedString;
            self.agreementTextView.attributedText = attributedString.copy;
            [self.agreementTextView setFont:[UIFont systemFontOfSize:13]];
        }else{
            if(error){
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }
    }];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }else{
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}
@end
