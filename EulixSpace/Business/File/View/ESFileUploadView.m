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
//  ESFileUploadView.m
//  EulixSpace
//
//  Created by qu on 2021/8/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileUploadView.h"
#import "ESImageDefine.h"

@interface ESFileUploadView ()

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UIButton *delectBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ESFileUploadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        self.programView.hidden = NO;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    self.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickUploadDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

/// 取消
- (void)didClickUploadDelectBtn:(UIButton *)detailDelectBtn {
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDetailView:didClickDelectBtn:)]) {
    //        [self.delegate fileBottomDetailView:self didClickDelectBtn:detailDelectBtn];
    //    }
}

@end
