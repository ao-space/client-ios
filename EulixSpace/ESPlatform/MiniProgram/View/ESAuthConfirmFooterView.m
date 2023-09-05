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
//  ESAuthConfirmFooterView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthConfirmFooterView.h"
#import "ESGradientUtil.h"

@interface ESAuthConfirmFooterView ()

@property (nonatomic, strong) UIButton *refuseBt;
@property (nonatomic, strong) UIButton *confirmBt;

@end

@implementation ESAuthConfirmFooterView

- (instancetype)initWithFrame:(CGRect)frame {

   self = [super initWithFrame:frame];
   if (self) {
       [self setupViews];
   }
   return self;
}

- (void)setupViews {
   self.backgroundColor = ESColor.systemBackgroundColor;
  
   [self addSubview:self.titleLabel];
   [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.mas_top).offset(20.0f);
       make.left.mas_equalTo(self.mas_left).offset(20.0f);
       make.right.mas_equalTo(self.mas_right).offset(-20.0f);
       make.height.mas_equalTo(20.0f);
   }];
   
   [self addSubview:self.refuseBt];
   [self.refuseBt mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(40.0f);
       make.centerX.mas_equalTo(self.mas_centerX).offset(- 65.0f);
       make.height.mas_equalTo(44.0f);
       make.width.mas_equalTo(110.0f);
   }];
   
   [self addSubview:self.confirmBt];
    [self.confirmBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.refuseBt.mas_top);
        make.centerX.mas_equalTo(self.mas_centerX).offset(65.0f);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(110.0f);
    }];
}

- (UILabel *)titleLabel {
   if (!_titleLabel) {
       _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
       _titleLabel.textColor = ESColor.labelColor;
       _titleLabel.font = ESFontPingFangMedium(14);
   }
   return _titleLabel;
}

- (UIButton *)refuseBt {
    if (!_refuseBt) {
        _refuseBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_refuseBt setTitle:NSLocalizedString(@"applet_auth_confirm_dialog_refuse_bt_title", @"拒绝") forState:UIControlStateNormal];
        [_refuseBt.titleLabel setFont:ESFontPingFangMedium(16)];
        [_refuseBt setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        _refuseBt.layer.cornerRadius = 10.0f;
        _refuseBt.clipsToBounds = YES;
        _refuseBt.backgroundColor = [ESColor colorWithHex:0xF5F6FA];
        [_refuseBt addTarget:self action:@selector(refuseAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _refuseBt;
}

- (UIButton *)confirmBt {
    if (!_confirmBt) {
        _confirmBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_confirmBt setTitle:NSLocalizedString(@"applet_auth_confirm_dialog_confirm_bt_title", @"允许") forState:UIControlStateNormal];
        [_confirmBt.titleLabel setFont: ESFontPingFangMedium(16)];
        _confirmBt.layer.cornerRadius = 10.0f;
        _confirmBt.clipsToBounds = YES;
        [_confirmBt setBackgroundImage:self.gradientImage forState:UIControlStateNormal];
        [_confirmBt setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_confirmBt addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBt;
}

- (UIImage *)gradientImage {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id)([ESColor colorWithHex:0x337AFF].CGColor)];
    [array addObject:(id)([ESColor colorWithHex:0x16B9FF].CGColor)];
    return [ESGradientUtil gradientImageWithCGColors:array rect:CGRectMake(0, 0, 110, 44)];
}


- (void)refuseAction:(UIButton *)sender {
    if (_refuseBlock) {
        _refuseBlock();
    }
}

- (void)confirmAction:(UIButton *)sender {
    if (_confirmBlock) {
        _confirmBlock();
    }
}

- (CGFloat)contentHeight {
    return 158.0f;
}

@end
