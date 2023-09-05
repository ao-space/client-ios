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
//  ESSpaceInitializationFailView.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInitializationFailView.h"

@interface ESSpaceInitializationFailView () <UITextViewDelegate>

@property (nonatomic, strong) UIImageView *failIcon;
@property (nonatomic, strong) UILabel *failLabel;
@property (nonatomic, strong) UILabel *retryLabel;
@property (nonatomic, strong) UITextView *backTextView;

@end

@implementation ESSpaceInitializationFailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = [ESColor systemBackgroundColor];

    [self addSubview:self.failIcon];
    
    [self.failIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self).inset(kTopHeight + 129);
    }];
    
    [self addSubview:self.failLabel];
    [self.failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.failIcon.mas_bottom).inset(20);
    }];
    
    [self addSubview:self.retryLabel];
    [self.retryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.failLabel.mas_bottom).inset(10);
    }];
    
    [self addSubview:self.backTextView];
    [self.backTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.retryLabel.mas_bottom).inset(50);
    }];
}

- (UIImageView *)failIcon {
    if (!_failIcon) {
        _failIcon = [UIImageView new];
        _failIcon.image = [UIImage imageNamed:@"shibai"];
    }
    return _failIcon;
}

- (UILabel *)failLabel {
    if (!_failLabel) {
        _failLabel = [[UILabel alloc] init];
        _failLabel.textColor = ESColor.primaryColor;
        _failLabel.font = ESFontPingFangMedium(18);
        _failLabel.textAlignment = NSTextAlignmentCenter;
        _failLabel.text = NSLocalizedString(@"binding_initializationfailure",@"初始化失败");
    }
    return _failLabel;
}

- (UILabel *)retryLabel {
    if (!_retryLabel) {
        _retryLabel = [[UILabel alloc] init];
        _retryLabel.textColor = ESColor.primaryColor;
        _retryLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"binding_systemerror1", @"系统错误，请")
                                                                                        attributes:@{
                                                                                            NSForegroundColorAttributeName: ESColor.labelColor,
                                                                                            NSFontAttributeName : ESFontPingFangRegular(14)
                                                                                        }];
        NSAttributedString *attr2= [[NSAttributedString alloc] initWithString:NSLocalizedString(@"binding_systemerror2", @"重试")
                                                                                        attributes:@{
                                                                                            NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                            NSFontAttributeName : ESFontPingFangRegular(14)
                                                                                        }];
        [attr appendAttributedString:attr2];
        _retryLabel.attributedText = [attr copy];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryAction)];
        [_retryLabel addGestureRecognizer:tapGes];
        _retryLabel.userInteractionEnabled = YES;
    }
    return _retryLabel;
}

- (UITextView *)backTextView {
    if (!_backTextView) {
        _backTextView = [[UITextView alloc] init];
        _backTextView.delegate = self;
        _backTextView.linkTextAttributes = @{};
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"common_back","返回")
                                                                                        attributes:@{
                                                                                            NSForegroundColorAttributeName: ESColor.primaryColor,
                                                                                            NSLinkAttributeName: @"bindfailback",
                                                                                            NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                                                                            NSFontAttributeName : ESFontPingFangMedium(12),
                                                                                        }];
        _backTextView.attributedText = attr;
    }
    return _backTextView;
}

- (void)retryAction {
    if (self.retryBlock) {
        self.retryBlock();
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([URL.absoluteString isEqualToString:@"bindfailback"]) {
        if (self.gobackBlock) {
            self.gobackBlock();
        }
    }
    return YES;
}
@end
