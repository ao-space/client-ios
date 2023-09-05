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
//  ESAppletMoreOperateFooterView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletMoreOperateFooterView.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"

@interface ESAppletMoreOperateFooterView ()

@property (nonatomic, strong) UIButton *cancelBt;
@property (nonatomic, strong) UIView *line;

@end

@implementation ESAppletMoreOperateFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = ESColor.systemBackgroundColor;

    [self addSubview:self.cancelBt];
    [self.cancelBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(15.0f);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(65.0f);
    }];
    
    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(6.0f);
    }];
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = [ESColor colorWithHex:0xF5F6FA];
    }
    return _line;
}

- (UIButton *)cancelBt {
    if (!_cancelBt) {
        _cancelBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_cancelBt setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_cancelBt.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:18]];
        [_cancelBt setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_cancelBt addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cancelBt;
}

- (void)cancelAction:(UIButton *)sender {
    if (_cancelBlock) {
        _cancelBlock();
    }
}

@end
