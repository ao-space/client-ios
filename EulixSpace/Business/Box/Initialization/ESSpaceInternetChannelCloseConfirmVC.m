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
//  ESSpaceInternetTunCloseConfirmVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInternetChannelCloseConfirmVC.h"
#import "ESGradientButton.h"
#import "ESCommonToolManager.h"

@interface ESSpaceInternetChannelCloseConfirmVC ()

@property (strong, nonatomic) UIView *contentView;
// 显示标题
@property (strong, nonatomic) UILabel *titleLabel;
// 显示子标题
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *messageLabel1;
@property (strong, nonatomic) UILabel *messageLabel2;

@property (nonatomic, strong) ESGradientButton *enterSpace;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation ESSpaceInternetChannelCloseConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.view setBackgroundColor:[ESColor colorWithHex:0x000000 alpha:0.5]];
}

- (void)setupView {
    [self.view addSubview:self.contentView];
    CGFloat contentHeight = [ESCommonToolManager isEnglish] ? (353 + 20 * 2 + 3 * 14 + 2 * 14) : 353;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-contentHeight);
        make.height.mas_equalTo(contentHeight);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];
    
    [self.contentView addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(28);
        make.left.right.mas_equalTo(self.contentView).inset(30);
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? 24 + 20 * 2 : 24);
    }];
    
    [self.contentView addSubview:self.messageLabel1];
    [self.messageLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(44);
        make.right.mas_equalTo(self.contentView).inset(30);
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? 40 + 3 * 14 : 40);
    }];
    
    UIView *dot1 = [UIView new];
    dot1.backgroundColor = ESColor.primaryColor;
    dot1.layer.cornerRadius = 3.0f;

    [self.contentView addSubview:dot1];
    [dot1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLabel1.mas_top).inset(8);
        make.right.mas_equalTo(self.messageLabel1.mas_left).inset(6);
        make.height.width.mas_equalTo(6);
    }];
    
    [self.contentView addSubview:self.messageLabel2];
    [self.messageLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLabel1.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(44);
        make.right.mas_equalTo(self.contentView).inset(30);
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? 40 + 2 * 14 : 40);
    }];
    
    UIView *dot2 = [UIView new];
    dot2.backgroundColor = ESColor.primaryColor;
    dot2.layer.cornerRadius = 3.0f;
    [self.contentView addSubview:dot2];
    [dot2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLabel2.mas_top).inset(8);
        make.right.mas_equalTo(self.messageLabel2.mas_left).inset(6);
        make.height.width.mas_equalTo(6);
    }];
    
    [self.contentView addSubview:self.enterSpace];
    [self.enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLabel2.mas_bottom).inset(40);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
    }];
    
    [self.contentView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.enterSpace.mas_bottom).inset(10);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentView.layer.mask = maskLayer;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = ESColor.systemBackgroundColor;
        
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = ESFontPingFangMedium(18);
        _titleLabel.text = NSLocalizedString(@"binding_closeInternetchannel", @"您是否确认关闭互联网通道？");
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.textColor = ESColor.labelColor;
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.font = ESFontPingFangMedium(14);
        _subtitleLabel.text = NSLocalizedString(@"binding_closeInternetchannel1", @"关闭互联网通道，将无法实现外网随时随地访问。");
    }
    return _subtitleLabel;
}

- (UILabel *)messageLabel1 {
    if (!_messageLabel1) {
        _messageLabel1 = [[UILabel alloc] init];
        _messageLabel1.textColor = ESColor.secondaryLabelColor;
        _messageLabel1.textAlignment = NSTextAlignmentLeft;
        _messageLabel1.font = ESFontPingFangRegular(14);
        _messageLabel1.numberOfLines = 0;
        _messageLabel1.text = NSLocalizedString(@"binding_Internetchanneltip", @"互联网通道由傲空间官方空间平台提供，基于端\n对端加密技术，实现平台无法解析个人数据。");
    }
    return _messageLabel1;
}

- (UILabel *)messageLabel2 {
    if (!_messageLabel2) {
        _messageLabel2 = [[UILabel alloc] init];
        _messageLabel2.textColor = ESColor.secondaryLabelColor;
        _messageLabel2.textAlignment = NSTextAlignmentLeft;
        _messageLabel2.font = ESFontPingFangRegular(14);
        _messageLabel2.numberOfLines = 0;
        _messageLabel2.text = NSLocalizedString(@"binding_deployprivateplatform", @"傲空间支持用户部署私有空间平台，您可按需切\n换到个人私有空间平台。");
    }
    return _messageLabel2;
}

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"common_close", @"关闭") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_enterSpace addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSpace;
}

- (UIButton *)cancelBtn {
    if (nil == _cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn.titleLabel setFont:ESFontPingFangMedium(16)];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    }
    return _cancelBtn;
}

- (void)closeAction {
    [self hidden];
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)cancelAction {
    [self hidden];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}


- (void)hidden {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
@end
