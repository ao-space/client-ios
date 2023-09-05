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

#import "ESFileProtocolView.h"

#import "ESAgreementWebVC.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import "ESGradientButton.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"
#import <Masonry/Masonry.h>
#import "ESThemeDefine.h"

@interface ESFileProtocolView () <UITextViewDelegate>

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UILabel *protocol;

@property (nonatomic, strong) ESGradientButton *delectCompleteBtn;

@property (nonatomic, strong) UIButton *delectCancelBtn;

@property (nonatomic, strong) UITextView *agreementTextView;

@end

@implementation ESFileProtocolView

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
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.mas_equalTo(self.mas_left).offset(0.0f);
        make.right.mas_equalTo(self.mas_right).offset(0.0f);
        make.height.mas_equalTo(430.0f);
    }];

    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(10);
        make.left.mas_equalTo(self.mas_left).offset(68.0f);
        make.right.mas_equalTo(self.mas_right).offset(-68.0f);
        make.height.mas_equalTo(42.0f);
    }];

    //    [self.pointt mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.programView.mas_top).offset(10);
    //        make.left.mas_equalTo(self.mas_left).offset(68.0f);
    //        make.right.mas_equalTo(self.mas_right).offset(-68.0f);
    //        make.height.mas_equalTo(42.0f);
    //    }];

    [self.delectCompleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(284.0f);
        make.left.mas_equalTo(self.mas_left).offset(88.0f);
        make.right.mas_equalTo(self.mas_right).offset(-88.0f);
        make.height.mas_equalTo(44.0f);
    }];

    [self.delectCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-36.0f);
        make.left.mas_equalTo(self.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.mas_right).offset(-10.0f);
        make.height.mas_equalTo(64.0f);
    }];

    self.agreementTextView = [[UITextView alloc] init];
    self.agreementTextView.delegate = self;
    self.agreementTextView.linkTextAttributes = @{};
    [self addSubview:self.agreementTextView];

    self.agreementTextView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

    if ([ESCommonToolManager isEnglish]) {
        [self.agreementTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(30.0f);
            make.right.mas_equalTo(self.mas_right).offset(-30.0);
            make.top.mas_equalTo(self.programView.mas_top).offset(73.0f);
            make.height.mas_equalTo(164.0f);
        }];
    }else{
        [self.agreementTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(30.0f);
            make.right.mas_equalTo(self.mas_right).offset(-30.0);
            make.top.mas_equalTo(self.programView.mas_top).offset(73.0f);
            make.height.mas_equalTo(144.0f);
        }];
    }
 
    [self agreementSetupHanle];
}

- (void)agreementSetupHanle {
    
    NSString *agreementMessage;
    if ([ESCommonToolManager isEnglish]) {
        agreementMessage = @"In order to protect your rights and interests, please read and understand the";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:agreementMessage];
        NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
        NSString *sagreementStr;
        NSString *privacyStr;
        if ([ESCommonToolManager isEnglish]) {
            sagreementStr = [NSString stringWithFormat:@"%@/en/agreement", baseUrl];
            privacyStr = [NSString stringWithFormat:@"%@/en/privacy", baseUrl];
        }else{
            sagreementStr = [NSString stringWithFormat:@"%@/agreement", baseUrl];
            privacyStr = [NSString stringWithFormat:@"%@/privacy", baseUrl];
        }
   
        NSAttributedString *registPolicyAttr = [[NSAttributedString alloc] initWithString:@"《AO.space user agreement》"
                                                                               attributes:@{
                                                                                   NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                   NSLinkAttributeName: sagreementStr
                                                                               }];

        NSAttributedString *strmiddlePolicyAttr = [[NSMutableAttributedString alloc] initWithString:@"and "];
        NSAttributedString *privacyPolicyAttr = [[NSAttributedString alloc] initWithString:@"《AO.space privacy agreement》"
                                                                                attributes:@{
                                                                                    NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                    NSLinkAttributeName: privacyStr
                                                                                }];
        NSAttributedString *strPolicyAttr = [[NSMutableAttributedString alloc] initWithString:TEXT_COMMON_AGREE_POINTOUT];
        
        [attributedString appendAttributedString:registPolicyAttr];
        [attributedString appendAttributedString:strmiddlePolicyAttr];
        [attributedString appendAttributedString:privacyPolicyAttr];
        [attributedString appendAttributedString:strPolicyAttr];

        // 设置间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5; // 字体的行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[[attributedString string] rangeOfString:agreementMessage]];
        self.agreementTextView.attributedText = attributedString;
        _agreementTextView.attributedText = attributedString.copy;
    }else{
        agreementMessage = @"为保障您的权益，请在使用过程中，阅读并理解";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:agreementMessage];
        NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
        NSString *sagreementStr = [NSString stringWithFormat:@"%@/agreement", baseUrl];
        NSString *privacyStr = [NSString stringWithFormat:@"%@/privacy", baseUrl];
        NSAttributedString *registPolicyAttr = [[NSAttributedString alloc] initWithString:@"《傲空间用户协议》"
                                                                               attributes:@{
                                                                                   NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                   NSLinkAttributeName: sagreementStr
                                                                               }];

        NSAttributedString *strmiddlePolicyAttr = [[NSMutableAttributedString alloc] initWithString:@"及"];
        NSAttributedString *privacyPolicyAttr = [[NSAttributedString alloc] initWithString:@"《傲空间隐私政策》"
                                                                                attributes:@{
                                                                                    NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                    NSLinkAttributeName: privacyStr
                                                                                }];
        NSAttributedString *strPolicyAttr = [[NSMutableAttributedString alloc] initWithString:TEXT_COMMON_AGREE_POINTOUT];
        
        [attributedString appendAttributedString:registPolicyAttr];
        [attributedString appendAttributedString:strmiddlePolicyAttr];
        [attributedString appendAttributedString:privacyPolicyAttr];
        [attributedString appendAttributedString:strPolicyAttr];

        // 设置间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5; // 字体的行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[[attributedString string] rangeOfString:agreementMessage]];
        self.agreementTextView.attributedText = attributedString;
        _agreementTextView.attributedText = attributedString.copy;
    }

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
        [_delectCompleteBtn setTitle:TEXT_COMMON_AGREE forState:UIControlStateNormal];
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
        [_delectCancelBtn setTitle:TEXT_COMMON_DISAGREE forState:UIControlStateNormal];
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
        _pointOutLabel.text = TEXT_COMMON_USER_AGREE;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (void)didClickCancelBtn {
    exit(0);
}

- (void)didClickDelectCompleteBtn {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
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

@end
