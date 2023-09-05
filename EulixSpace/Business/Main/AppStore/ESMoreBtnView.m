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
//  ESMoreBtnView.m
//  EulixSpace
//
//  Created by danjiang on 2023/3/24.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESMoreBtnView.h"

@implementation ESMoreBtnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {

    [self.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(20.0f);
        make.right.mas_equalTo(self.mas_right).offset(-46);
    }];

    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(0);
        make.width.mas_equalTo(40.0f);
        make.left.mas_equalTo(self.btnImageView.mas_right).offset(-4);
        make.height.mas_equalTo(20.0f);
    }];
}

- (UILabel *)btnLabel {
    if (!_btnLabel) {
        _btnLabel = [[UILabel alloc] init];
        _btnLabel.textColor = [ESColor labelColor];
        _btnLabel.text = NSLocalizedString(@"home_add", @"添加");
        _btnLabel.textAlignment = NSTextAlignmentCenter;
        _btnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self addSubview:_btnLabel];
    }
    return _btnLabel;
}

- (UIImageView *)btnImageView {
    if (!_btnImageView) {
        _btnImageView = [[UIImageView alloc] init];
        _btnImageView.image = [UIImage imageNamed:@"add_more"];
        [self addSubview:_btnImageView];
    }
    return _btnImageView;
}


@end
