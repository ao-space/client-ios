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
//  ESFileBottomBtnView.m
//  EulixSpace
//
//  Created by qu on 2021/8/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileBottomBtnView.h"
#import "ESColor.h"
#import <Masonry/Masonry.h>

@implementation ESFileBottomBtnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.fileBottomBtnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(24.0f);
        make.width.mas_equalTo(24.0f);
    }];

    [self.fileBottomBtnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.fileBottomBtnImageView.mas_bottom).offset(7);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(14.0f);
    }];
}

- (UILabel *)fileBottomBtnLabel {
    if (!_fileBottomBtnLabel) {
        _fileBottomBtnLabel = [[UILabel alloc] init];
        _fileBottomBtnLabel.textColor = [ESColor labelColor];
        _fileBottomBtnLabel.textAlignment = NSTextAlignmentCenter;
        _fileBottomBtnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        [self addSubview:_fileBottomBtnLabel];
    }
    return _fileBottomBtnLabel;
}

- (UIImageView *)fileBottomBtnImageView {
    if (!_fileBottomBtnImageView) {
        _fileBottomBtnImageView = [[UIImageView alloc] init];
        [self addSubview:_fileBottomBtnImageView];
    }
    return _fileBottomBtnImageView;
}
@end
