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
//  ESWebBottomBtnView.m
//  EulixSpace
//
//  Created by qu on 2022/2/10.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESWebBottomBtnView.h"
#import "ESColor.h"
#import <Masonry/Masonry.h>

@interface ESWebBottomBtnView ()
@property (nonatomic, strong) UIButton *scanQRCodeBtn;
@end

@implementation ESWebBottomBtnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {

    [self.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(50.0f);
        make.width.mas_equalTo(50.0f);
    }];

    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.btnImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(56.0f);
    }];
}

- (UILabel *)btnLabel {
    if (!_btnLabel) {
        _btnLabel = [[UILabel alloc] init];
        _btnLabel.textColor = [ESColor labelColor];
        _btnLabel.textAlignment = NSTextAlignmentCenter;
        _btnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self addSubview:_btnLabel];
    }
    return _btnLabel;
}

- (UIImageView *)btnImageView {
    if (!_btnImageView) {
        _btnImageView = [[UIImageView alloc] init];
        [self addSubview:_btnImageView];
    }
    return _btnImageView;
}

@end
